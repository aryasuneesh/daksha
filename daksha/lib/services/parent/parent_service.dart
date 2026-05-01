import 'package:daksha/inference/inference_engine.dart';

// ---------------------------------------------------------------------------
// Storage interface (AppDatabase implements this; tests use a fake)
// ---------------------------------------------------------------------------

abstract interface class ParentQaStore {
  /// Persists a Q&A exchange and returns the generated UUID.
  Future<String> insertQa({
    required String question,
    required String? plan,
    required String answer,
    required DateTime askedAt,
  });
}

// ---------------------------------------------------------------------------
// Value object
// ---------------------------------------------------------------------------

class ParentResponse {
  const ParentResponse({
    required this.question,
    required this.plan,
    required this.answer,
  });

  /// The parent's original question.
  final String question;

  /// Internal reasoning from the PLAN pass.
  final String plan;

  /// The answer shown to the parent from the SPEAK pass.
  final String answer;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ParentService {
  const ParentService({
    required InferenceEngine engine,
    required ParentQaStore store,
    DateTime Function()? clock,
  })  : _engine = engine,
        _store = store,
        _clock = clock ?? _defaultClock;

  final InferenceEngine _engine;
  final ParentQaStore _store;
  final DateTime Function() _clock;

  static DateTime _defaultClock() => DateTime.now();

  // ── Prompt templates ───────────────────────────────────────────────────────

  static String _planPrompt(String question) =>
      'You are helping a parent understand their child\'s learning. '
      'A parent asks: "$question"\n\n'
      'Think step by step and write a brief plan for how to answer this '
      'question in a clear, warm, and informative way. '
      'Focus on what matters most to the parent.';

  static String _speakPrompt(String question, String plan) =>
      'Plan: $plan\n\n'
      'Now write a concise, warm answer to the parent\'s question: '
      '"$question"\n\n'
      'Speak directly to the parent. Use plain language. '
      'Keep the answer under 100 words.';

  // ── Main pipeline ──────────────────────────────────────────────────────────

  /// Runs the PLAN → SPEAK 2-shot pipeline for the parent's [question].
  ///
  /// Returns a [ParentResponse] containing the question, internal plan, and
  /// the parent-facing answer.
  ///
  /// Throws [ParentServiceException] if either inference pass fails.
  Future<ParentResponse> ask(String question) async {
    // Pass 1: PLAN
    final planResponse = await _engine.generate(
      InferenceRequest(
        prompt: _planPrompt(question),
        maxTokens: 256,
        temperature: 0.3,
      ),
    );
    final plan = switch (planResponse) {
      InferenceSuccess(:final text) => text.trim(),
      InferenceFailure(:final error) =>
        throw ParentServiceException('PLAN pass failed: $error'),
      _ => throw ParentServiceException('PLAN pass: unexpected response type'),
    };

    // Pass 2: SPEAK
    final speakResponse = await _engine.generate(
      InferenceRequest(
        prompt: _speakPrompt(question, plan),
        maxTokens: 192,
        temperature: 0.7,
      ),
    );
    final answer = switch (speakResponse) {
      InferenceSuccess(:final text) => text.trim(),
      InferenceFailure(:final error) =>
        throw ParentServiceException('SPEAK pass failed: $error'),
      _ => throw ParentServiceException('SPEAK pass: unexpected response type'),
    };

    // Persist
    await _store.insertQa(
      question: question,
      plan: plan,
      answer: answer,
      askedAt: _clock(),
    );

    return ParentResponse(question: question, plan: plan, answer: answer);
  }
}

// ---------------------------------------------------------------------------
// Exception
// ---------------------------------------------------------------------------

class ParentServiceException implements Exception {
  const ParentServiceException(this.message);
  final String message;

  @override
  String toString() => 'ParentServiceException: $message';
}
