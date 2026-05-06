import 'dart:convert';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/inference/gbnf_compiler.dart';
import 'package:daksha/inference/inference_engine.dart';

/// Represents the output of a Socratic opening question.
class SocraticOpener {
  /// The Socratic opening question to prompt thinking.
  final String question;

  /// A gentle hint if the student is stuck.
  final String hint;

  const SocraticOpener({
    required this.question,
    required this.hint,
  });

  @override
  bool operator ==(Object other) =>
      other is SocraticOpener &&
      other.question == question &&
      other.hint == hint;

  @override
  int get hashCode => Object.hash(question, hint);
}

/// Enum representing how correct a student's attempt is.
enum AttemptVerdict {
  /// The answer is fully correct.
  correct,

  /// The answer is partially correct or very close.
  close,

  /// The answer is incorrect.
  incorrect,
}

/// Feedback on a student's attempt at solving a problem.
class AttemptFeedback {
  /// Whether the attempt is correct, close, or incorrect.
  final AttemptVerdict verdict;

  /// A brief explanation of the verdict.
  final String explanation;

  const AttemptFeedback({
    required this.verdict,
    required this.explanation,
  });

  @override
  bool operator ==(Object other) =>
      other is AttemptFeedback &&
      other.verdict == verdict &&
      other.explanation == explanation;

  @override
  int get hashCode => Object.hash(verdict, explanation);
}

/// A stateless service for Socratic tutoring tools.
///
/// Uses an inference engine with GBNF grammars to generate constrained JSON
/// outputs for three core tutoring operations: generating opening questions,
/// checking student attempts, and providing hints.
class SocraticService {
  final InferenceEngine _engine;

  SocraticService(this._engine);

  // Schema for generateSocraticOpener: {"question": string, "hint": string}
  static const _openerSchema = {
    'type': 'object',
    'properties': {
      'question': {'type': 'string'},
      'hint': {'type': 'string'},
    },
  };

  /// Generates a Socratic opening question for a problem.
  ///
  /// Returns null if the inference engine fails or the response is malformed.
  Future<SocraticOpener?> generateSocraticOpener({
    required String problemText,
    required Topic topic,
  }) async {
    final grammar = GbnfCompiler.compile(_openerSchema);
    final prompt = '''You are Daksha, a Socratic tutor for grades 5–8.
Subject: ${topic.subject}, Topic: ${topic.displayName}
Problem: $problemText

Ask one focused Socratic question to help the student think, and provide a gentle hint.
Respond with JSON only: {"question": "...", "hint": "..."}''';

    final response = await _engine.generate(InferenceRequest(
      prompt: prompt,
      maxTokens: 128,
      grammarBnf: grammar,
    ));

    return response.when(
      success: (text, _) => _parseOpener(text),
      failure: (_) => null,
    );
  }

  /// Parses a JSON response into a SocraticOpener.
  ///
  /// Returns null if the JSON is malformed or missing required fields.
  SocraticOpener? _parseOpener(String raw) {
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      final question = json['question'] as String?;
      final hint = json['hint'] as String?;
      if (question == null || hint == null) return null;
      return SocraticOpener(question: question, hint: hint);
    } catch (_) {
      return null;
    }
  }

  // Schema for checkAttempt: {"verdict": string, "explanation": string}
  static const _checkSchema = {
    'type': 'object',
    'properties': {
      'verdict': {'type': 'string'},
      'explanation': {'type': 'string'},
    },
  };

  /// Checks a student's attempt at solving a problem.
  ///
  /// Returns null if the inference engine fails or the response is malformed.
  Future<AttemptFeedback?> checkAttempt({
    required String problemText,
    required String studentAttempt,
    required Topic topic,
  }) async {
    final grammar = GbnfCompiler.compile(_checkSchema);
    final prompt = '''You are Daksha, a Socratic tutor.
Subject: ${topic.subject}, Topic: ${topic.displayName}
Problem: $problemText
Student's answer: $studentAttempt

Is the student correct? Respond with JSON only: {"verdict": "correct|close|incorrect", "explanation": "..."}''';

    final response = await _engine.generate(InferenceRequest(
      prompt: prompt,
      maxTokens: 96,
      grammarBnf: grammar,
    ));

    return response.when(
      success: (text, _) => _parseFeedback(text),
      failure: (_) => null,
    );
  }

  /// Parses a JSON response into AttemptFeedback.
  ///
  /// Returns null if the JSON is malformed, missing required fields,
  /// or contains an unknown verdict string.
  AttemptFeedback? _parseFeedback(String raw) {
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      final verdictStr = json['verdict'] as String?;
      final explanation = json['explanation'] as String?;
      if (verdictStr == null || explanation == null) return null;

      final verdict = switch (verdictStr) {
        'correct' => AttemptVerdict.correct,
        'close' => AttemptVerdict.close,
        'incorrect' => AttemptVerdict.incorrect,
        _ => null,
      };
      if (verdict == null) return null;

      return AttemptFeedback(verdict: verdict, explanation: explanation);
    } catch (_) {
      return null;
    }
  }

  // Schema for generateHint: {"hint": string}
  static const _hintSchema = {
    'type': 'object',
    'properties': {
      'hint': {'type': 'string'},
    },
  };

  /// Generates a hint for a problem at a specified level.
  ///
  /// [hintLevel] controls the specificity:
  /// - 1 (default): gentle nudge
  /// - 2: more explicit guidance
  /// - 3: near-answer
  ///
  /// Returns null if the inference engine fails or the response is malformed.
  Future<String?> generateHint({
    required String problemText,
    required Topic topic,
    int hintLevel = 1,
  }) async {
    final grammar = GbnfCompiler.compile(_hintSchema);
    final prompt = '''You are Daksha, a Socratic tutor.
Subject: ${topic.subject}, Topic: ${topic.displayName}
Problem: $problemText
Hint level: $hintLevel (1=gentle, 3=near-answer)

Give a hint at level $hintLevel. Respond with JSON only: {"hint": "..."}''';

    final response = await _engine.generate(InferenceRequest(
      prompt: prompt,
      maxTokens: 80,
      grammarBnf: grammar,
    ));

    return response.when(
      success: (text, _) => _parseHint(text),
      failure: (_) => null,
    );
  }

  /// Parses a JSON response into a hint string.
  ///
  /// Returns null if the JSON is malformed or missing the hint field.
  String? _parseHint(String raw) {
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      return json['hint'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Extracts a JSON object from free-form model output.
  ///
  /// The MediaPipe LiteRT-LM engine does not support grammar-constrained
  /// decoding, so Gemma 4 may wrap its JSON in:
  ///   - markdown code fences: ```json { … } ```
  ///   - a preamble: "Here is the response: { … }"
  ///   - trailing text after the closing brace
  ///
  /// This helper strips fences and finds the first '{' … last '}' span so
  /// [jsonDecode] receives a clean object string regardless of wrapping.
  static String _extractJson(String raw) {
    // Strip markdown code fences (```json … ``` or ``` … ```)
    final stripped = raw
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    final start = stripped.indexOf('{');
    final end = stripped.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return raw;
    return stripped.substring(start, end + 1);
  }
}
