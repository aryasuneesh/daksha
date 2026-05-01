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
///
/// ## Reading-order reconstruction
/// ML Kit returns [TextBlock]s in *detection* order (highest-contrast region
/// first), not in top-to-bottom reading order.  We re-sort by bounding-box
/// top-Y (then left-X for blocks on the same visual row) before joining lines,
/// so questions always appear before answers and headers appear before body text.
class MlKitTextRecognitionEngine implements TextRecognitionEngine {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String?> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);

    if (result.blocks.isEmpty) return null;

    // Sort blocks into reading order: top-to-bottom, then left-to-right
    // for blocks whose top edges are within 20 px of each other (same row).
    final sortedBlocks = List.of(result.blocks)
      ..sort((a, b) {
        final aTop = a.boundingBox?.top ?? 0.0;
        final bTop = b.boundingBox?.top ?? 0.0;
        if ((aTop - bTop).abs() < 20) {
          final aLeft = a.boundingBox?.left ?? 0.0;
          final bLeft = b.boundingBox?.left ?? 0.0;
          return aLeft.compareTo(bLeft);
        }
        return aTop.compareTo(bTop);
      });

    final lines = <String>[];
    for (final block in sortedBlocks) {
      // Sort individual lines within each block top-to-bottom as well.
      final sortedLines = List.of(block.lines)
        ..sort((a, b) {
          final aTop = a.boundingBox?.top ?? 0.0;
          final bTop = b.boundingBox?.top ?? 0.0;
          return aTop.compareTo(bTop);
        });

      for (final line in sortedLines) {
        final lineText = line.text.trim();
        if (lineText.isNotEmpty) lines.add(lineText);
      }
    }

    return lines.isEmpty ? null : lines.join('\n');
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
        prompt: 'You are correcting OCR scan errors in a printed mathematics '
            'or science textbook problem.\n'
            'OCR makes these predictable mistakes on printed math — fix them:\n'
            '  • Minus/negative signs: "--" or missing → "−"; '
            '"--b)" or "b)=" → "(−b) ="\n'
            '  • Roman numerals misread: (l)/(1) → (i), '
            '(ll)/(O)/(0) → (ii), (m)/(lll) → (iii)\n'
            '  • Letter/digit swaps: l↔1, O↔0, S↔5, Z↔2, I↔1\n'
            '  • Spaces dropped around =, +, −: '
            '"a=b" → "a = b", "4+bfor" → "a + b for"\n'
            '  • Merged/garbled words: reconstruct from context '
            '("vaiues" → "values", "lollowing" → "following")\n'
            '  • Missing parentheses around negatives: '
            '"−b" → "(−b)" when the formula requires it\n'
            'Output ONLY the corrected problem text, preserving all '
            'numbered sub-parts (i), (ii), (iii), (iv).\n'
            'Do not add any explanation or commentary.\n'
            '<user_data>\n'
            '$rawText\n'
            '</user_data>',
        maxTokens: 256,
      ),
    );

    // Fall back to raw OCR text on LLM failure rather than returning null.
    return response.when(
      success: (text, _) => text.trim().isEmpty ? rawText : text.trim(),
      failure: (_) => rawText,
    );
  }
}
