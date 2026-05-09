import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/tutor_state.dart';

/// Roles used in the persisted conversation log. The chat UI reads these to
/// decide which side of the screen to render the bubble on.
class TurnRole {
  static const daksha = 'daksha';
  static const student = 'student';
}

/// One persisted conversation turn — what we read back from the DB to
/// rehydrate the chat when the student re-opens a problem from history.
class StoredTurn {
  final String role;
  final String content;
  final DateTime createdAt;
  const StoredTurn({
    required this.role,
    required this.content,
    required this.createdAt,
  });
}

/// Exception thrown when requesting a REVEAL-level hint too soon.
class HintGateException implements Exception {
  final String message;
  const HintGateException(this.message);
  @override
  String toString() => 'HintGateException: $message';
}

/// Storage interface used by [TutorService].
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

  /// Marks a problem as solved.
  Future<void> updateProblem(String id, {bool? solved});

  /// Records one conversation turn.
  Future<void> insertTurn({
    required String problemId,
    required String role,
    required String content,
    required DateTime createdAt,
  });

  /// Reads back all turns for a problem, ordered oldest-first. Used by
  /// [TutorService.resumeProblem] to rebuild conversation context for
  /// the model and let the chat replay past content.
  Future<List<StoredTurn>> readTurns(String problemId);
}

/// Sink the service uses to publish fire-once verdict events.
///
/// Wired in providers.dart to a [StateProvider] so the UI can listen for
/// pop-up triggers without coupling to [TutorState] (which fires on every
/// rebuild — wrong for one-shot dialogs).
typedef VerdictEventSink = void Function(TutorVerdictEvent event);

class TutorService extends StateNotifier<TutorState> {
  final TopicClassifier _classifier;
  final SocraticService _socratic;
  final ProblemStore _store;
  final DateTime Function() _clock;
  final VerdictEventSink? _onVerdict;

  /// Conversation history kept in memory for the model's context window.
  /// We rebuild this on [resumeProblem] from [ProblemStore.readTurns] so the
  /// LLM can see what's already been said when the student types follow-ups.
  final List<({String role, String content})> _history = [];

  static DateTime _defaultClock() => DateTime.now();

  TutorService({
    required TopicClassifier classifier,
    required SocraticService socratic,
    required ProblemStore store,
    DateTime Function() clock = _defaultClock,
    VerdictEventSink? onVerdict,
  })  : _classifier = classifier,
        _socratic = socratic,
        _store = store,
        _clock = clock,
        _onVerdict = onVerdict,
        super(const TutorState.idle());

  /// Starts a brand-new problem. Inserts the problem row, classifies its
  /// topic, generates the Socratic opener, and persists the opener as the
  /// first daksha turn so it survives a history → resume round trip.
  Future<void> startProblem(String problemText) async {
    state = TutorState.classifying(problemText);
    _history.clear();

    final classification = await _classifier.classify(problemText);
    final topic = classification?.topic ??
        const Topic(subject: 'general', slug: 'general', displayName: 'General');

    final opener = await _socratic.generateSocraticOpener(
      problemText: problemText,
      topic: topic,
    );
    final openerText = opener?.question ??
        // Inference failed or response was unparseable — fall back to a
        // default opener so the student isn't stuck on the classifying
        // spinner.
        'What do you think the first step to solving this is?';

    final problemId = await _store.insertProblem(
      text: problemText,
      subject: topic.subject,
      topicSlug: topic.slug,
      createdAt: _clock(),
    );

    // Persist the opener so re-opening this problem from history shows the
    // same conversation thread instead of a fresh classifier run.
    await _appendTurn(problemId, TurnRole.daksha, openerText);

    state = TutorState.asking(
      problemText: problemText,
      topic: topic,
      opener: openerText,
      problemId: problemId,
    );
  }

  /// Re-enters an existing problem with its conversation already on disk.
  /// Avoids the duplicate INSERT and the unnecessary re-classification +
  /// re-opener generation that the previous "history just calls
  /// startProblem" flow produced.
  Future<void> resumeProblem({
    required String problemId,
    required String problemText,
    required Topic topic,
  }) async {
    final turns = await _store.readTurns(problemId);

    _history
      ..clear()
      ..addAll(turns.map((t) => (role: t.role, content: t.content)));

    // The first daksha turn (if any) is the original opener. We surface it
    // as the [TutorAsking.opener] so the existing UI elements that key off
    // the opener (header label, fallback display) keep working — but the
    // chat list comes from the DB stream, not from this string.
    final firstDakshaContent = turns
        .firstWhere(
          (t) => t.role == TurnRole.daksha,
          orElse: () => StoredTurn(role: '', content: '', createdAt: _kEpoch),
        )
        .content;

    state = TutorState.asking(
      problemText: problemText,
      topic: topic,
      opener: firstDakshaContent,
      problemId: problemId,
    );
  }

  Future<void> submitAttempt(String input) async {
    final current = state;
    // TutorSolved is now accepted: after the student gets it right they may
    // still want to ask follow-ups ("why does that work?"). Without this,
    // the input field is left enabled by the UI but every send throws
    // `Cannot submit input from state TutorState.solved(...)`.
    final (problemText, topic, problemId, opener) = switch (current) {
      TutorAsking(:final problemText, :final topic, :final problemId, :final opener) =>
        (problemText, topic, problemId, opener),
      TutorHinting(:final problemText, :final topic, :final problemId, :final opener) =>
        (problemText, topic, problemId, opener),
      TutorSolved(:final problemText, :final topic, :final problemId, :final opener) =>
        (problemText, topic, problemId, opener),
      _ => throw StateError('Cannot submit input from state $current'),
    };

    // Track whether we entered this call already in the post-solve regime
    // so verdict pop-ups stay suppressed for casual follow-ups even if the
    // model accidentally judges them as "incorrect attempts".
    final alreadySolved = current is TutorSolved;

    // Persist the student's input immediately so it shows in the chat as
    // soon as they hit send (the daksha reply will follow once inference
    // completes).
    await _appendTurn(problemId, TurnRole.student, input);

    state = TutorState.checking(
      problemText: problemText,
      topic: topic,
      attempt: input,
      problemId: problemId,
      opener: opener,
    );

    final outcome = await _socratic.judgeOrReply(
      problemText: problemText,
      studentInput: input,
      topic: topic,
      // Send the prior history (excluding the just-written student turn,
      // which is at the tail) so the model can interpret short follow-ups
      // in context.
      history: List.unmodifiable(_history.take(_history.length - 1)),
    );

    if (outcome == null) {
      _revertToPrevious(current);
      return;
    }

    switch (outcome) {
      case StudentDoubt(:final reply):
        // The student asked a question — record the tutor reply but keep
        // the problem open. The student can keep talking.
        await _appendTurn(problemId, TurnRole.daksha, reply);
        _revertToPrevious(current);
      case StudentAttempt(:final feedback):
        await _appendTurn(problemId, TurnRole.daksha, feedback.explanation);

        // Emit verdict pop-ups only for first-time correct/incorrect. The
        // "close" verdict means "almost there, keep trying" — popping a
        // dialog there would interrupt the rhythm of guided practice.
        // Post-solve verdicts are also suppressed: once solved, follow-up
        // chatter that the model misjudges as a wrong attempt shouldn't
        // un-celebrate the win.
        final shouldEmit = !alreadySolved &&
            (feedback.verdict == AttemptVerdict.correct ||
                feedback.verdict == AttemptVerdict.incorrect);
        if (shouldEmit) {
          _onVerdict?.call(TutorVerdictEvent(
            verdict: feedback.verdict,
            explanation: feedback.explanation,
            at: _clock(),
          ));
        }

        if (feedback.verdict == AttemptVerdict.correct && !alreadySolved) {
          await _store.updateProblem(problemId, solved: true);
          state = TutorState.solved(
            problemId: problemId,
            problemText: problemText,
            topic: topic,
            opener: opener,
          );
        } else if (alreadySolved) {
          // Already solved: stay solved regardless of how the model graded
          // the follow-up. The student is past the answer; this is chat.
          state = current;
        } else {
          // Wrong / close — stay in the conversation so the student can
          // try again, ask a follow-up, or request a hint.
          _revertToPrevious(current);
        }
    }
  }

  void _revertToPrevious(TutorState previous) {
    // TutorSolved is included so a post-solve follow-up that gets routed to
    // the doubt path doesn't drop us back to idle (which would clear the
    // solved badge and orphan the chat).
    if (previous is TutorHinting ||
        previous is TutorAsking ||
        previous is TutorSolved) {
      state = previous;
    } else {
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
    if (hint == null) return;

    // Persist hints with a level prefix so the resumed chat still shows
    // "Hint 2: …" months later, even after the in-memory level counter
    // is gone.
    await _appendTurn(problemId, TurnRole.daksha, 'Hint $newLevel: $hint');

    final opener = switch (current) {
      TutorAsking(:final opener)  => opener,
      TutorHinting(:final opener) => opener,
      _ => '',
    };

    state = TutorState.hinting(
      problemText: problemText,
      topic: topic,
      level: newLevel,
      hint: hint,
      problemId: problemId,
      firstHintAt: newFirstHintAt,
      opener: opener,
    );
  }

  void reset() {
    _history.clear();
    state = const TutorState.idle();
  }

  Future<void> _appendTurn(String problemId, String role, String content) async {
    final at = _clock();
    await _store.insertTurn(
      problemId: problemId,
      role: role,
      content: content,
      createdAt: at,
    );
    _history.add((role: role, content: content));
  }
}

// Sentinel timestamp used by [resumeProblem]'s firstWhere fallback. The
// orElse path means the problem has no daksha turns at all (corrupt or
// pre-fix history row), so this value is read only for its non-null-ness;
// 1970-01-01 is fine.
final DateTime _kEpoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
