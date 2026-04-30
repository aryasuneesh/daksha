import 'package:llama_cpp_dart/llama_cpp_dart.dart';

import 'inference_engine.dart';

/// [InferenceEngine] backed by llama_cpp_dart. [Llama] construction is
/// synchronous/blocking; all engine creation is wrapped in [Future] to avoid
/// blocking the UI thread.
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
  Future<void> load() async {
    final contextParams = ContextParams()..nPredict = defaultMaxTokens;

    final samplerParams = SamplerParams()..temp = defaultTemperature;

    // [Llama] constructor is synchronous but CPU-bound and blocking;
    // wrapping it in a Future lets callers await without blocking the UI.
    await Future<void>(() {
      _llama = Llama(
        modelPath,
        contextParams: contextParams,
        samplerParams: samplerParams,
      );
    });

    _loaded = true;
  }

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _llama == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }

    try {
      Llama engine;
      Llama? ephemeral; // grammar-scoped instance to dispose after generation

      if (request.grammarBnf != null && request.grammarBnf!.isNotEmpty) {
        final sp = SamplerParams()
          ..temp = request.temperature
          ..grammarStr = request.grammarBnf!
          ..grammarRoot = 'root';

        final cp = ContextParams()..nPredict = request.maxTokens;

        // Llama constructor is blocking — run off the UI thread.
        await Future<void>(() {
          ephemeral = Llama(modelPath, contextParams: cp, samplerParams: sp);
        });
        engine = ephemeral!;
      } else {
        engine = _llama!;
      }

      try {
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
      } finally {
        ephemeral?.dispose();
      }
    } catch (e) {
      return InferenceResponse.failure(error: e.toString());
    }
  }

  @override
  Future<void> dispose() async {
    if (_loaded && _llama != null) {
      _llama!.dispose();
      _llama = null;
      _loaded = false;
    }
  }
}
