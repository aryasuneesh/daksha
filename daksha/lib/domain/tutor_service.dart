import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/tutor_state.dart';

/// Exception thrown when requesting a REVEAL-level hint too soon.
class HintGateException implements Exception {
  final String message;
  const HintGateException(this.message);
  @override
  String toString() => 'HintGateException: $message';
}

/// Minimal storage interface used by [TutorService].
///
/// [AppDatabase] implements this; tests use a hand-rolled fake.
abstract interface class ProblemStore {
  /// Inserts a new problem and returns its generated UUID.
  Future<String> insertProblem({
    required String text,
    required String subject,
    required String topicSlug,
    required DateTime createdAt,
  });

  /// Marks a problem solved or updates its hint metadata.
  Future<void> updateProblem(
    String id, {
    bool? solved,
    int? hintLevel,
    DateTime? firstHintAt,
  });

  /// Records one conversation turn.
  Future<void> insertTurn({
    required String problemId,
    required String role,
    required String content,
    required DateTime createdAt,
  });
}

class TutorService extends StateNotifier<TutorState> {
  final TopicClassifier _classifier;
  final SocraticService _socratic;
  final ProblemStore _store;
  final DateTime Function() _clock;

  static DateTime _defaultClock() => DateTime.now();

  TutorService({
    required TopicClassifier classifier,
    required SocraticService socratic,
    required ProblemStore store,
    DateTime Function() clock = _defaultClock,
  })  : _classifier = classifier,
        _socratic = socratic,
        _store = store,
        _clock = clock,
        super(const TutorState.idle());

  Future<void> startProblem(String problemText) async {
    state = TutorState.classifying(problemText);

    final classification = await _classifier.classify(problemText);
    final topic = classification?.topic ??
        const Topic(subject: 'general', slug: 'general', displayName: 'General');

    final problemId = await _store.insertProblem(
      text: problemText,
      subject: topic.subject,
      topicSlug: topic.slug,
      createdAt: _clock(),
    );

    final opener = await _socratic.generateSocraticOpener(
      problemText: problemText,
      topic: topic,
    );
    if (opener == null) return; // stay in classifying on inference failure

    state = TutorState.asking(
      problemText: problemText,
      topic: topic,
      opener: opener.question,
      problemId: problemId,
    );
  }

  Future<void> submitAttempt(String attempt) async {
    final current = state;
    final (problemText, topic, problemId) = switch (current) {
      TutorAsking(:final problemText, :final topic, :final problemId) =>
        (problemText, topic, problemId),
      TutorHinting(:final problemText, :final topic, :final problemId) =>
        (problemText, topic, problemId),
      _ => throw StateError('Cannot submit attempt from state $current'),
    };

    state = TutorState.checking(
      problemText: problemText,
      topic: topic,
      attempt: attempt,
      problemId: problemId,
    );

    final feedback = await _socratic.checkAttempt(
      problemText: problemText,
      studentAttempt: attempt,
      topic: topic,
    );
    if (feedback == null) {
      _revertToPrevious(current);
      return;
    }

    await _store.insertTurn(
      problemId: problemId,
      role: 'student',
      content: attempt,
      createdAt: _clock(),
    );

    if (feedback.verdict == AttemptVerdict.correct) {
      await _store.updateProblem(problemId, solved: true);
      state = TutorState.solved(problemId: problemId);
    } else {
      _revertToPrevious(current);
    }
  }

  void _revertToPrevious(TutorState previous) {
    // Return to whichever non-checking state we came from.
    if (previous is TutorHinting || previous is TutorAsking) {
      state = previous;
    } else {
      // Shouldn't happen, but idle is a safe fallback.
      state = const TutorState.idle();
    }
  }

  Future<void> requestHint() async {
    final current = state;
    final (problemText, topic, currentLevel, problemId, firstHintAt) =
        switch (current) {
      TutorAsking(:final problemText, :final topic, :final problemId) =>
        (problemText, topic, 0, problemId, null as DateTime?),
      TutorHinting(
        :final problemText,
        :final topic,
        :final level,
        :final problemId,
        :final firstHintAt,
      ) =>
        (problemText, topic, level, problemId, firstHintAt as DateTime?),
      _ => throw StateError('Cannot request hint from state $current'),
    };

    // REVEAL gate: once at level 3, only proceed if ≥3 min have elapsed.
    if (currentLevel >= 3) {
      final elapsed = _clock().difference(firstHintAt!);
      if (elapsed < const Duration(minutes: 3)) {
        final remaining = const Duration(minutes: 3) - elapsed;
        throw HintGateException('Not yet: wait ${remaining.inSeconds}s');
      }
    }

    final newLevel = (currentLevel + 1).clamp(1, 3);
    final now = _clock();
    final newFirstHintAt = firstHintAt ?? now;

    final hint = await _socratic.generateHint(
      problemText: problemText,
      topic: topic,
      hintLevel: newLevel,
    );
    if (hint == null) return; // stay in current state on inference failure

    await _store.updateProblem(
      problemId,
      hintLevel: newLevel,
      firstHintAt: newFirstHintAt,
    );

    state = TutorState.hinting(
      problemText: problemText,
      topic: topic,
      level: newLevel,
      hint: hint,
      problemId: problemId,
      firstHintAt: newFirstHintAt,
    );
  }

  void reset() => state = const TutorState.idle();
}
