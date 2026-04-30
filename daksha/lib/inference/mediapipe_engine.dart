import 'package:flutter_gemma/flutter_gemma.dart';

import 'inference_engine.dart';

/// [InferenceEngine] implementation backed by the flutter_gemma plugin
/// (MediaPipe LLM Inference API).
///
/// [modelPath] must be an absolute path to a `.bin` model file that already
/// exists on the device (e.g. downloaded by a separate model-management step).
/// On [load], the file is registered with the plugin via a `file://` URI and
/// the inference engine is initialised.
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
    // Copy the on-device file into the plugin's managed app-documents location,
    // then initialise the native inference engine.
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
