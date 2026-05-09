import 'package:flutter_gemma/flutter_gemma.dart';

import 'package:daksha/core/constants/model.dart';
import 'inference_engine.dart';

/// Gemma 4 inference engine backed by flutter_gemma ≥0.14.1 (LiteRT-LM).
///
/// Supports both text-only and vision (image + text) inference:
/// - Text-only: [InferenceRequest.imagePath] is null → [Message.text]
/// - Vision:    [InferenceRequest.imagePath] is set  → [Message.withImage]
///
/// A fresh [InferenceModelSession] is created for every [generate] call so
/// that each PLAN and SPEAK pass gets a clean context with no prior history.
class MediaPipeEngine implements InferenceEngine {
  MediaPipeEngine({
    required this.modelPath,
    int maxTokens = kModelMaxTokens,
  }) : _maxTokens = maxTokens;

  final String modelPath;
  final int _maxTokens;

  bool _loaded = false;
  InferenceModel? _model;

  @override
  bool get isLoaded => _loaded;

  /// Vision support requires the LiteRT-LM native SDK to support the vision
  /// encoder format bundled in the active model file.  The HuggingFace
  /// gemma-4-E4B-it.litertlm was updated to LiteRT-LM v1.5 (3 vision
  /// signatures) which is not yet supported by flutter_gemma ≤0.14.5.
  /// We load in text-only mode to avoid the "Vision Encoder must have exactly
  /// one signature" crash; OCR still works via ML Kit on the capture screen.
  @override
  bool get supportsVision => false;

  @override
  Future<void> load() async {
    // [main.dart] already calls FlutterGemma.initialize() at startup. Calling
    // it a second time has caused double-allocation of native resources in
    // some plugin versions, so we skip it here.

    if (!FlutterGemma.hasActiveModel()) {
      // Model wasn't installed via the onboarding screen (e.g. manual adb push).
      // Fall back to registering from the file at [modelPath].
      // Gemma 4 uses the LiteRT-LM format (.litertlm); the SDK handles
      // chat-template formatting internally for this file type.
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(modelPath).install();
    }

    // Load in text-only mode: the LiteRT-LM v1.5 vision encoder format
    // (3 signatures: vision_70/140/280) is not yet supported by the native
    // SDK bundled in flutter_gemma ≤0.14.5.  supportImage: false causes the
    // engine to skip vision-encoder initialisation, avoiding the
    // "must have exactly one signature but got 3" native crash.
    // When flutter_gemma is updated to support v1.5, flip this back to true.
    final model = await FlutterGemma.getActiveModel(
      maxTokens: _maxTokens,
      supportImage: false,
    );
    // Assign + flip _loaded together so dispose() is correct even if a future
    // post-assignment step throws.
    _model = model;
    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _model == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }
    try {
      // Fresh session per call — no cross-contamination between PLAN / SPEAK /
      // OCR passes.
      // Vision modality is disabled (supportImage: false at load time) due to
      // LiteRT-LM v1.5 multi-signature incompatibility in flutter_gemma ≤0.14.5.
      final session = await _model!.createSession(
        temperature: request.temperature,
        enableVisionModality: false,
      );

      try {
        await session.addQueryChunk(
          Message.text(text: request.prompt, isUser: true),
        );

        final text = await session.getResponse();
        return InferenceResponse.success(text: text);
      } finally {
        await session.close();
      }
    } catch (e) {
      return InferenceResponse.failure(error: e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    // Always attempt to close the model — even if [load] failed mid-flight,
    // [_model] may hold a half-initialised native handle that still needs
    // releasing to avoid leaking GPU/OpenCL memory.
    final model = _model;
    _model = null;
    _loaded = false;
    if (model != null) {
      try {
        await model.close();
      } catch (_) {
        // Best-effort: a close after a failed load can throw on the native
        // side. Swallow so dispose is idempotent.
      }
    }
  }
}
