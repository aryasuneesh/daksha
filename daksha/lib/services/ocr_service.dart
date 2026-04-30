import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'package:daksha/inference/inference_engine.dart';

class OcrService {
  OcrService(this._engine);

  final InferenceEngine _engine;

  /// Preprocess: decode bytes → resize long edge to 1024 px → strip EXIF.
  /// Returns the processed bytes (JPEG, quality 90).
  /// EXIF is stripped implicitly because the image package does not preserve
  /// metadata when re-encoding.
  static Uint8List preprocessImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw ArgumentError('Cannot decode image');
    final resized = _resizeLongEdge(decoded, 1024);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 90));
  }

  static img.Image _resizeLongEdge(img.Image src, int maxEdge) {
    final longEdge = src.width > src.height ? src.width : src.height;
    if (longEdge <= maxEdge) return src;
    final scale = maxEdge / longEdge;
    return img.copyResize(
      src,
      width: (src.width * scale).round(),
      height: (src.height * scale).round(),
    );
  }

  /// Two-pass OCR:
  ///   pass 1 — verbatim transcription of the image.
  ///   pass 2 — extract the core problem statement from the transcription.
  ///
  /// User-supplied content (image data and transcribed text) is always wrapped
  /// in `<user_data>` tags so injected instructions cannot escape into the
  /// system-prompt portion of either call.
  ///
  /// Photo bytes are never persisted to disk — only the base-64 string is
  /// constructed in memory for the request and discarded afterwards.
  ///
  /// Returns the interpreted problem text, or null on failure.
  Future<String?> extractProblemText(Uint8List imageBytes) async {
    final processed = preprocessImage(imageBytes);
    final b64 = base64Encode(processed);

    // ── Pass 1: verbatim transcription ──────────────────────────────────────
    final pass1Response = await _engine.generate(
      InferenceRequest(
        prompt: 'You are a precise transcription engine.\n'
            'Transcribe EXACTLY what is written in the image. '
            'Do not interpret or modify.\n'
            'Output only the transcribed text.\n'
            '<user_data>\n'
            '[image: $b64]\n'
            '</user_data>',
        maxTokens: 256,
      ),
    );

    final transcribed = pass1Response.when(
      success: (text, _) => text.trim(),
      failure: (_) => null,
    );
    if (transcribed == null || transcribed.isEmpty) return null;

    // ── Pass 2: interpretation ───────────────────────────────────────────────
    // The transcribed text (which may contain adversarial content such as
    // "Ignore previous instructions…") is placed entirely inside <user_data>
    // so the system-prompt portion remains intact and trusted.
    final pass2Response = await _engine.generate(
      InferenceRequest(
        prompt: 'You are a math/science problem extractor.\n'
            'Extract the core problem statement from the transcription below.\n'
            'Output only the problem statement — no preamble, no explanation.\n'
            '<user_data>\n'
            '$transcribed\n'
            '</user_data>',
        maxTokens: 128,
      ),
    );

    return pass2Response.when(
      success: (text, _) => text.trim().isEmpty ? null : text.trim(),
      failure: (_) => null,
    );
  }
}
