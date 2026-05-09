import 'package:llama_cpp_dart/llama_cpp_dart.dart';

import 'inference_engine.dart';

/// [InferenceEngine] backed by llama_cpp_dart.
///
/// The [Llama] constructor is synchronous and CPU-bound (it mmaps and
/// dequantises the model). It cannot be moved to a background isolate because
/// llama_cpp_dart's FFI handles are not isolate-safe — passing them across
/// `Isolate.run` would crash on first use. So construction does block the UI
/// thread; this is acceptable here because [LlamaCppEngine] is only the
/// fallback path (the production app forces [EnginePreference.mediaPipe]).
class LlamaCppEngine implements InferenceEngine {
  final String modelPath;
  final int defaultMaxTokens;
  final double defaultTemperature;

  Llama? _llama;
  bool _loaded = false;

  LlamaCppEngine({
    required this.modelPath,
    this.defaultMaxTokens = 512,
    this.defaultTemperature = 0.7,
  });

  @override
  bool get isLoaded => _loaded;

  @override
  bool get supportsVision => false;

  @override
  Future<void> load() async {
    final contextParams = ContextParams()..nPredict = defaultMaxTokens;
    final samplerParams = SamplerParams()..temp = defaultTemperature;

    _llama = Llama(
      modelPath,
      contextParams: contextParams,
      samplerParams: samplerParams,
    );
    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _llama == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }

    Llama? ephemeral; // grammar-scoped instance to dispose after generation
    try {
      Llama engine;

      if (request.grammarBnf != null && request.grammarBnf!.isNotEmpty) {
        final sp = SamplerParams()
          ..temp = request.temperature
          ..grammarStr = request.grammarBnf!
          ..grammarRoot = 'root';

        final cp = ContextParams()..nPredict = request.maxTokens;

        ephemeral = Llama(modelPath, contextParams: cp, samplerParams: sp);
        engine = ephemeral;
      } else {
        engine = _llama!;
      }

      engine.setPrompt(request.prompt);

      final buffer = StringBuffer();
      int tokenCount = 0;
      await for (final chunk in engine.generateText()) {
        buffer.write(chunk);
        tokenCount++;
        if (tokenCount >= request.maxTokens) break;
      }

      return InferenceResponse.success(
        text: buffer.toString(),
        tokensGenerated: tokenCount,
      );
    } catch (e) {
      return InferenceResponse.failure(error: e.toString());
    } finally {
      // Dispose the ephemeral grammar-scoped instance whether generation
      // succeeded, threw, or short-circuited — moving this out of the inner
      // try/finally also covers the case where [Llama] construction itself
      // throws after partial native allocation.
      ephemeral?.dispose();
    }
  }

  @override
  Future<void> dispose() async {
    final llama = _llama;
    _llama = null;
    _loaded = false;
    llama?.dispose();
  }
}
