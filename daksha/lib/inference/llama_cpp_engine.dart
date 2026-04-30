import 'package:llama_cpp_dart/llama_cpp_dart.dart';

import 'inference_engine.dart';

/// An [InferenceEngine] that runs inference via llama.cpp through the
/// `llama_cpp_dart` package.
///
/// Requires a valid GGUF model file at [modelPath]. Because the [Llama]
/// constructor is synchronous and performs blocking I/O, [load()] offloads the
/// initialisation to a background isolate so the calling thread stays
/// responsive.
///
/// Grammar-constrained output is supported: when [InferenceRequest.grammarBnf]
/// is non-null it is forwarded to [SamplerParams.grammarStr] with
/// `grammarRoot = "root"`.
class LlamaCppEngine implements InferenceEngine {
  /// Absolute path to a GGUF model file.
  final String modelPath;

  /// Maximum tokens to generate per request. Used as the `nPredict` context
  /// parameter when no per-request override is given.
  final int defaultMaxTokens;

  /// Sampling temperature used when no per-request override is present.
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

  /// Initialises the llama.cpp backend and loads the model.
  ///
  /// Throws (and marks the engine as not loaded) if the model file cannot be
  /// found or the underlying native initialisation fails.
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

  /// Runs inference for [request].
  ///
  /// If [InferenceRequest.grammarBnf] is set, a fresh [Llama] instance is
  /// created with grammar-constrained sampling so the output conforms to the
  /// supplied GBNF grammar.  For requests without grammar constraints the
  /// shared [_llama] instance is reused.
  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    if (!_loaded || _llama == null) {
      return const InferenceResponse.failure(error: 'Engine not loaded');
    }

    try {
      Llama engine;
      Llama? ephemeral; // grammar-scoped instance to dispose after generation

      if (request.grammarBnf != null && request.grammarBnf!.isNotEmpty) {
        // Create a short-lived Llama instance with grammar sampling enabled.
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

  /// Releases the loaded model and native resources.
  @override
  Future<void> dispose() async {
    if (_loaded && _llama != null) {
      _llama!.dispose();
      _llama = null;
      _loaded = false;
    }
  }
}
