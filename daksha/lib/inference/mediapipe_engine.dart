import 'package:flutter_gemma/flutter_gemma.dart';

import 'inference_engine.dart';

// maxTokens/temperature from InferenceRequest are not forwarded; the plugin
// fixes them at load() time. Pass constructor params to configure them.
class MediaPipeEngine implements InferenceEngine {
  final String modelPath;
  final int _maxTokens;
  final double _temperature;

  bool _loaded = false;

  MediaPipeEngine({
    required this.modelPath,
    int maxTokens = 512,
    double temperature = 0.7,
  })  : _maxTokens = maxTokens,
        _temperature = temperature;

  FlutterGemmaPlugin get _plugin => FlutterGemmaPlugin.instance;

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> load() async {
    await _plugin.loadNetworkModel(url: 'file://$modelPath');
    await _plugin.init(
      maxTokens: _maxTokens,
      temperature: _temperature,
    );
    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }
    try {
      final buffer = StringBuffer();
      await for (final chunk in _plugin.getResponseAsync(prompt: request.prompt)) {
        if (chunk != null) buffer.write(chunk);
      }
      return InferenceResponse.success(text: buffer.toString());
    } catch (e) {
      return InferenceResponse.failure(error: e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    if (_loaded) {
      await _plugin.close();
      _loaded = false;
    }
  }
}
