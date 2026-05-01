import 'package:flutter_gemma/flutter_gemma.dart';

import 'inference_engine.dart';

/// MediaPipe-backed [InferenceEngine] using flutter_gemma ≥0.11.12.
///
/// A fresh [InferenceModelSession] is created for every [generate] call so
/// that each PLAN and SPEAK pass gets a clean context with no prior history.
///
/// Temperature and maxTokens from [InferenceRequest] are forwarded to the
/// session, so the 2-shot pipeline can use different temperatures per pass.
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

  @override
  Future<void> load() async {
    await FlutterGemma.initialize();

    // Register the local .bin model file and mark it as the active model.
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
      // .bin / .tflite files need manual chat-template formatting;
      // .task / .litertlm files handle it internally.
      fileType: ModelFileType.binary,
    ).fromFile(modelPath).install();

    _model = await FlutterGemma.getActiveModel(maxTokens: _maxTokens);
    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _model == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }
    try {
      // Fresh session per call — no cross-contamination between PLAN and SPEAK.
      final session = await _model!.createSession(
        temperature: request.temperature,
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
    if (_loaded) {
      await _model?.close();
      _model = null;
      _loaded = false;
    }
  }
}
