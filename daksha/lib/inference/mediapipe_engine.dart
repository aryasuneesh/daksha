import 'dart:io';

import 'package:flutter_gemma/flutter_gemma.dart';

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
    int maxTokens = 512,
  }) : _maxTokens = maxTokens;

  final String modelPath;
  final int _maxTokens;

  bool _loaded = false;
  InferenceModel? _model;

  @override
  bool get isLoaded => _loaded;

  /// Gemma 4 natively understands images — vision is always available once
  /// [load] completes.
  @override
  bool get supportsVision => true;

  @override
  Future<void> load() async {
    await FlutterGemma.initialize();

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

    // Declare vision capability so the underlying LiteRT-LM session
    // allocates the vision encoder — required even for text-only requests.
    _model = await FlutterGemma.getActiveModel(
      maxTokens: _maxTokens,
      supportImage: true,
    );
    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _model == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }
    try {
      final isVision = request.imagePath != null;

      // Fresh session per call — no cross-contamination between PLAN / SPEAK /
      // OCR passes.
      final session = await _model!.createSession(
        temperature: request.temperature,
        // Vision modality must also be enabled at the session level.
        enableVisionModality: isVision,
      );

      try {
        if (isVision) {
          // flutter_gemma requires raw bytes, not a file path.
          final bytes = await File(request.imagePath!).readAsBytes();
          await session.addQueryChunk(
            Message.withImage(
              text: request.prompt,
              imageBytes: bytes,
              isUser: true,
            ),
          );
        } else {
          await session.addQueryChunk(
            Message.text(text: request.prompt, isUser: true),
          );
        }

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
    if (_loaded) {
      await _model?.close();
      _model = null;
      _loaded = false;
    }
  }
}
