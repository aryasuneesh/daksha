import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:daksha/inference/inference_engine.dart';

// ── Text-recognition engine abstraction ──────────────────────────────────────

/// Abstracts on-device text recognition so [OcrService] can be tested without
/// the native ML Kit stack.
abstract class TextRecognitionEngine {
  /// Return the recognised text from the image at [imagePath], or null if
  /// nothing legible was found.
  Future<String?> recognizeText(String imagePath);

  /// Release native resources. Call once after the engine is no longer needed.
  Future<void> close();
}

/// Production implementation backed by ML Kit Latin-script text recognition.
///
/// The underlying model is bundled in the APK via the
/// `com.google.mlkit.vision.DEPENDENCIES` meta-data in AndroidManifest.xml,
/// so no network access is required at runtime.
class MlKitTextRecognitionEngine implements TextRecognitionEngine {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String?> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);
    final text = result.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Future<void> close() => _recognizer.close();
}

// ── OcrService ────────────────────────────────────────────────────────────────

/// Two-pass on-device OCR service.
///
/// **Pass 1 — ML Kit text recognition** (mandatory):
///   Reads the image file and returns raw OCR text.  Always works; requires
///   no downloaded model.
///
/// **Pass 2 — LLM cleanup** (optional):
///   If an [InferenceEngine] is supplied, the raw OCR text is sent to the LLM
///   to extract the core problem statement.  If the engine is absent or the
///   LLM call fails, Pass 1's raw text is returned unchanged.
///
/// Raw OCR text (which may contain adversarial content) is always wrapped in
/// `<user_data>` tags for the LLM prompt so injected instructions cannot
/// escape into the trusted system-prompt portion.
class OcrService {
  OcrService({
    required TextRecognitionEngine recognitionEngine,
    InferenceEngine? inferenceEngine,
  })  : _recognition = recognitionEngine,
        _inference = inferenceEngine;

  final TextRecognitionEngine _recognition;
  final InferenceEngine? _inference;

  /// Extract the problem text from the image at [imagePath].
  ///
  /// Returns the cleaned problem statement, or the raw OCR text if no LLM
  /// engine is available, or null if no text could be recognised at all.
  Future<String?> extractProblemText(String imagePath) async {
    // ── Pass 1: ML Kit OCR ───────────────────────────────────────────────────
    final rawText = await _recognition.recognizeText(imagePath);
    if (rawText == null || rawText.isEmpty) return null;

    // ── Pass 2: LLM cleanup (optional) ──────────────────────────────────────
    final engine = _inference;
    if (engine == null) return rawText;

    if (!engine.isLoaded) {
      await engine.load();
    }

    final response = await engine.generate(
      InferenceRequest(
        prompt: 'You are a math/science problem extractor.\n'
            'Extract the core problem statement from the transcription below.\n'
            'Output only the problem statement — no preamble, no explanation.\n'
            '<user_data>\n'
            '$rawText\n'
            '</user_data>',
        maxTokens: 128,
      ),
    );

    // Fall back to raw OCR text on LLM failure rather than returning null.
    return response.when(
      success: (text, _) => text.trim().isEmpty ? rawText : text.trim(),
      failure: (_) => rawText,
    );
  }
}
