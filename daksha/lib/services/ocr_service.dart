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

/// Production implementation backed by ML Kit text recognition.
///
/// Runs both the Latin and Devanagari script recognizers in parallel so the
/// app can read English and Hindi printed problems with no UI-level switch.
/// Each script-specific model is bundled in the APK via the
/// `com.google.mlkit.vision.DEPENDENCIES` meta-data in AndroidManifest.xml,
/// so no network access is required at runtime.
///
/// ## Reading-order reconstruction
/// ML Kit returns [TextBlock]s in *detection* order (highest-contrast region
/// first), not in top-to-bottom reading order.  We re-sort by bounding-box
/// top-Y (then left-X for blocks on the same visual row) before joining lines,
/// so questions always appear before answers and headers appear before body text.
///
/// ## Malayalam (and other Indic scripts beyond Devanagari)
// TODO(vision): ML Kit ships no Malayalam script pack — Latin + Devanagari are
// the only options here. The strategically clean fix for Malayalam (and a
// quality boost for printed math generally) is the Gemma multimodal vision
// path: see [MediaPipeEngine.supportsVision] in
// `lib/inference/mediapipe_engine.dart:36`, currently forced to `false`
// pending a `flutter_gemma` release newer than 0.14.5. Once that ships, flip
// `supportsVision => true` and [OcrService.extractProblemText] will route
// images directly to the LLM, bypassing ML Kit entirely.
class MlKitTextRecognitionEngine implements TextRecognitionEngine {
  final TextRecognizer _latinRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final TextRecognizer _devanagariRecognizer =
      // Note: the upstream enum value is misspelled `devanagiri` (sic) in
      // google_mlkit_text_recognition. It still selects the Devanagari model.
      TextRecognizer(script: TextRecognitionScript.devanagiri);

  @override
  Future<String?> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Run both recognizers in parallel — each loads a separate on-device
    // model, so they can process the same image concurrently.
    final results = await Future.wait([
      _latinRecognizer.processImage(inputImage),
      _devanagariRecognizer.processImage(inputImage),
    ]);
    final latinResult = results[0];
    final devanagariResult = results[1];

    // Merge strategy: pick the recognizer with more total characters of
    // output. A typed Devanagari problem will dominate the Devanagari
    // recognizer; a Latin problem will dominate the Latin recognizer.
    // Concatenating both produces garbage when the same glyphs are partially
    // recognised by both models, so we choose one wholesale.
    final latinText = _reconstructReadingOrder(latinResult);
    final devanagariText = _reconstructReadingOrder(devanagariResult);

    if (latinText == null && devanagariText == null) return null;
    if (latinText == null) return devanagariText;
    if (devanagariText == null) return latinText;

    return devanagariText.length > latinText.length
        ? devanagariText
        : latinText;
  }

  /// Sort [result]'s blocks into reading order (top-to-bottom, then
  /// left-to-right for blocks on the same visual row) and join their lines
  /// with newlines. Returns null when no non-empty lines are present.
  String? _reconstructReadingOrder(RecognizedText result) {
    if (result.blocks.isEmpty) return null;

    // Sort blocks into reading order: top-to-bottom, then left-to-right
    // for blocks whose top edges are within 20 px of each other (same row).
    final sortedBlocks = List.of(result.blocks)
      ..sort((a, b) {
        final aTop = a.boundingBox.top;
        final bTop = b.boundingBox.top;
        if ((aTop - bTop).abs() < 20) {
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        }
        return aTop.compareTo(bTop);
      });

    final lines = <String>[];
    for (final block in sortedBlocks) {
      // Sort individual lines within each block top-to-bottom as well.
      final sortedLines = List.of(block.lines)
        ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      for (final line in sortedLines) {
        final lineText = line.text.trim();
        if (lineText.isNotEmpty) lines.add(lineText);
      }
    }

    return lines.isEmpty ? null : lines.join('\n');
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _latinRecognizer.close(),
      _devanagariRecognizer.close(),
    ]);
  }
}

// ── OcrService ────────────────────────────────────────────────────────────────

/// On-device OCR service with two execution paths.
///
/// ## Gemma 4 vision path (preferred)
/// When [inferenceEngine] is provided and `inferenceEngine.supportsVision`
/// is true, the image is passed directly to the vision-capable LLM.
/// This produces far better results for printed mathematics because Gemma 4
/// understands mathematical notation natively.
///
/// ## ML Kit fallback path
/// Used when no vision-capable engine is available.
///
/// **Pass 1 — ML Kit text recognition** (mandatory):
///   Reads the image file and returns raw OCR text.  Always works; requires
///   no downloaded model.
///
/// **Pass 2 — LLM cleanup** (optional):
///   If an [InferenceEngine] is supplied (text-only), the raw OCR text is
///   sent to the LLM to fix OCR errors specific to printed mathematics.
///   Falls back to raw ML Kit text on failure.
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
  /// Returns the cleaned problem statement, or null if no text could be
  /// extracted.
  Future<String?> extractProblemText(String imagePath) async {
    final engine = _inference;

    // ── Gemma 4 vision fast path ─────────────────────────────────────────────
    // When the engine understands images, skip ML Kit entirely and let the
    // multimodal LLM read the textbook page directly.  This handles fractions,
    // exponents, Roman numerals, and negative signs that ML Kit mangles.
    if (engine != null && engine.supportsVision) {
      if (!engine.isLoaded) await engine.load();

      final response = await engine.generate(
        InferenceRequest(
          prompt: 'Read the mathematics or science textbook problem shown in '
              'this image.\n'
              'Extract ONLY the exact problem text, including all numbered '
              'sub-parts: (i), (ii), (iii), (a), (b), etc.\n'
              'Preserve all mathematical notation exactly as printed, '
              'including fractions, exponents, square roots, and '
              'minus/negative signs.\n'
              'Output ONLY the problem text. '
              'Do not explain, summarise, or add commentary.',
          imagePath: imagePath,
          maxTokens: 512,
        ),
      );

      return response.when(
        success: (text, _) {
          if (text.trim().isNotEmpty) return text.trim();
          // Vision returned empty — fall through to ML Kit.
          return null;
        },
        failure: (_) => null, // fall through to ML Kit below
      );
    }

    // ── ML Kit path ──────────────────────────────────────────────────────────

    // Pass 1: ML Kit OCR
    final rawText = await _recognition.recognizeText(imagePath);
    if (rawText == null || rawText.isEmpty) return null;

    // Pass 2: LLM cleanup (optional — only for text-only engines)
    if (engine == null) return rawText;

    if (!engine.isLoaded) await engine.load();

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
