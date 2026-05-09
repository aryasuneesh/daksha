import 'dart:convert';
import 'package:daksha/core/constants/model.dart';
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

/// Outcome of [SocraticService.judgeOrReply].
///
/// The student's input may be either an attempt at the answer (graded with
/// [AttemptFeedback]) or a question / doubt about the problem ([DoubtReply]).
/// Treating every input as an attempt was producing false-positive "correct"
/// verdicts on inputs like "I don't get it" — this sealed type makes the
/// branch explicit.
sealed class StudentResponseOutcome {
  const StudentResponseOutcome();
}

class StudentAttempt extends StudentResponseOutcome {
  final AttemptFeedback feedback;
  const StudentAttempt(this.feedback);
}

class StudentDoubt extends StudentResponseOutcome {
  final String reply;
  const StudentDoubt(this.reply);
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

  // Schema for judgeOrReply: routes intent and (if applicable) verdict in
  // one inference call. The MediaPipe LiteRT-LM backend doesn't actually
  // enforce GBNF (see _extractJson note), so the schema is mostly hint —
  // the prompt does the real work.
  static const _judgeOrReplySchema = {
    'type': 'object',
    'properties': {
      'kind': {'type': 'string'},      // "attempt" | "question"
      'verdict': {'type': 'string'},   // "correct" | "close" | "incorrect" | "n/a"
      'reply': {'type': 'string'},     // tutor-facing message
    },
  };

  /// Routes the student's input to either grading (an attempted answer) or
  /// answering (a question / doubt about the problem).
  ///
  /// Replaces the older `checkAttempt`, which assumed every student message
  /// was an attempt and routinely returned `verdict: "correct"` on inputs
  /// like "I don't understand" — auto-completing the problem incorrectly.
  ///
  /// [history] is the running conversation context (oldest first), used so
  /// that the model can interpret short attempts in context (e.g. "x = 4"
  /// after the tutor asked "what is x?").
  ///
  /// Returns null on engine failure or malformed JSON.
  Future<StudentResponseOutcome?> judgeOrReply({
    required String problemText,
    required String studentInput,
    required Topic topic,
    List<({String role, String content})> history = const [],
  }) async {
    final grammar = GbnfCompiler.compile(_judgeOrReplySchema);

    // Slide a window over the most recent turns so the prompt stays inside
    // [kModelMaxTokens]. Keeping the *tail* (not the head) preserves the
    // immediate back-and-forth context the model needs to interpret short
    // follow-ups; older turns add little signal per token.
    final recentHistory = history.length > kJudgeReplyHistoryTurns
        ? history.sublist(history.length - kJudgeReplyHistoryTurns)
        : history;

    final historyBlock = recentHistory.isEmpty
        ? '(no prior turns)'
        : recentHistory
            .map((t) => '${t.role == 'student' ? 'Student' : 'Daksha'}: ${t.content}')
            .join('\n');

    final prompt = '''You are Daksha, a Socratic tutor for grades 5–8.
Subject: ${topic.subject}. Topic: ${topic.displayName}.
Problem: $problemText

Conversation so far:
$historyBlock

The student just said: "$studentInput"

Decide what kind of message that is.
- If the student is trying to give the answer or a step toward it, set "kind" to "attempt".
- If the student is asking a question, expressing confusion, or making a comment, set "kind" to "question".

Then:
- If kind is "attempt": set "verdict" to one of "correct", "close", "incorrect" based on whether their answer solves the original problem. Be strict — only mark "correct" when the answer actually solves the problem. Vague replies, restating the question, or off-topic text are NOT correct. Then write a short, friendly "reply" that points the student toward the next step without revealing the full answer (unless verdict is "correct", in which case briefly congratulate them).
- If kind is "question": set "verdict" to "n/a". In "reply", answer the student's question or address their confusion in plain words a 10-year-old would understand. Do NOT solve the original problem for them — guide them with a question or a small clue.

Respond with JSON only:
{"kind": "...", "verdict": "...", "reply": "..."}''';

    final response = await _engine.generate(InferenceRequest(
      prompt: prompt,
      maxTokens: 192,
      grammarBnf: grammar,
    ));

    return response.when(
      success: (text, _) => _parseJudgeOrReply(text),
      failure: (_) => null,
    );
  }

  /// Backwards-compatible wrapper that grades [studentAttempt] as if it
  /// were definitely an answer (no question / doubt branching).
  ///
  /// Used by [eval_harness] and the unit tests, which feed canonical
  /// "this is an answer" payloads. Production code should prefer
  /// [judgeOrReply] so that questions get answered instead of graded.
  Future<AttemptFeedback?> checkAttempt({
    required String problemText,
    required String studentAttempt,
    required Topic topic,
  }) async {
    final outcome = await judgeOrReply(
      problemText: problemText,
      studentInput: studentAttempt,
      topic: topic,
    );
    return switch (outcome) {
      StudentAttempt(:final feedback) => feedback,
      // The model interpreted the input as a question — surface as
      // `incorrect` so eval probes don't accidentally count those as wins.
      StudentDoubt(:final reply) =>
        AttemptFeedback(verdict: AttemptVerdict.incorrect, explanation: reply),
      null => null,
    };
  }

  StudentResponseOutcome? _parseJudgeOrReply(String raw) {
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      final kind = (json['kind'] as String?)?.trim().toLowerCase();
      final reply = (json['reply'] as String?)?.trim();
      if (reply == null || reply.isEmpty) return null;

      if (kind == 'question' || kind == 'doubt' || kind == 'comment') {
        return StudentDoubt(reply);
      }
      if (kind == 'attempt' || kind == 'answer') {
        final verdictStr = (json['verdict'] as String?)?.trim().toLowerCase();
        final verdict = switch (verdictStr) {
          'correct' => AttemptVerdict.correct,
          'close' => AttemptVerdict.close,
          'incorrect' => AttemptVerdict.incorrect,
          // Defensive default — the model occasionally emits "n/a" for an
          // attempt. Treat ambiguous self-reports as "close" rather than
          // "correct" so the student isn't falsely solved out.
          _ => AttemptVerdict.close,
        };
        return StudentAttempt(
          AttemptFeedback(verdict: verdict, explanation: reply),
        );
      }
      // Unknown kind — fall back to doubt so we don't auto-solve.
      return StudentDoubt(reply);
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
