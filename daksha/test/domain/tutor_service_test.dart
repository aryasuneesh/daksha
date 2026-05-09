import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/tutor_service.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/inference/inference_engine.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Fake [InferenceEngine] — never used directly in tests but required to
/// construct the real TopicClassifier / SocraticService.
class _FakeEngine implements InferenceEngine {
  @override
  Future<InferenceResponse> generate(InferenceRequest request) async =>
      const InferenceResponse.failure(error: 'fake engine — not used');

  @override
  bool get isLoaded => false;

  @override
  bool get supportsVision => false;

  @override
  Future<void> load() async {}

  @override
  Future<void> dispose() async {}
}

/// Fake [TopicClassifier] that returns a fixed result or null.
class FakeClassifier extends TopicClassifier {
  ClassificationResult? _result;

  FakeClassifier()
      : super(engine: _FakeEngine(), topics: [
          const Topic(
              subject: 'math', slug: 'algebra', displayName: 'Algebra'),
        ]);

  void setResult(ClassificationResult? r) => _result = r;

  @override
  Future<ClassificationResult?> classify(String problemText) async => _result;
}

/// Fake [SocraticService] with controllable responses.
///
/// `setFeedback` controls the attempt-grading branch of [judgeOrReply].
/// `setDoubtReply` lets tests exercise the question / doubt branch — set
/// non-null to force the next `judgeOrReply` call to take the doubt path.
class FakeSocratic extends SocraticService {
  SocraticOpener? _opener;
  AttemptFeedback? _feedback;
  String? _doubtReply;
  String? _hint;

  FakeSocratic() : super(_FakeEngine());

  void setOpener(SocraticOpener? o) => _opener = o;
  void setFeedback(AttemptFeedback? f) => _feedback = f;
  void setDoubtReply(String? r) => _doubtReply = r;
  void setHint(String? h) => _hint = h;

  @override
  Future<SocraticOpener?> generateSocraticOpener({
    required String problemText,
    required Topic topic,
  }) async =>
      _opener;

  @override
  Future<StudentResponseOutcome?> judgeOrReply({
    required String problemText,
    required String studentInput,
    required Topic topic,
    List<({String role, String content})> history = const [],
  }) async {
    if (_doubtReply != null) return StudentDoubt(_doubtReply!);
    if (_feedback == null) return null;
    return StudentAttempt(_feedback!);
  }

  @override
  Future<String?> generateHint({
    required String problemText,
    required Topic topic,
    int hintLevel = 1,
  }) async =>
      _hint;
}

/// Fake [ProblemStore] — in-memory, no SQLite.
class FakeStore implements ProblemStore {
  int _counter = 0;
  final Map<String, bool> _solved = {};
  final List<Map<String, dynamic>> turns = [];

  @override
  Future<String> insertProblem({
    required String text,
    required String subject,
    required String topicSlug,
    required DateTime createdAt,
  }) async {
    final id = 'problem-${_counter++}';
    _solved[id] = false;
    return id;
  }

  @override
  Future<void> updateProblem(String id, {bool? solved}) async {
    if (solved != null) _solved[id] = solved;
  }

  @override
  Future<void> insertTurn({
    required String problemId,
    required String role,
    required String content,
    required DateTime createdAt,
  }) async {
    turns.add({
      'problemId': problemId,
      'role': role,
      'content': content,
      'createdAt': createdAt,
    });
  }

  @override
  Future<List<StoredTurn>> readTurns(String problemId) async {
    return turns
        .where((t) => t['problemId'] == problemId)
        .map((t) => StoredTurn(
              role: t['role'] as String,
              content: t['content'] as String,
              createdAt: t['createdAt'] as DateTime,
            ))
        .toList();
  }

  bool? solvedFor(String id) => _solved[id];

  @override
  Future<void> recordActivity(DateTime now) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kTopic =
    Topic(subject: 'math', slug: 'algebra', displayName: 'Algebra');
const _kProblemText = 'Solve x + 2 = 5';

TutorService _makeService({
  FakeClassifier? classifier,
  FakeSocratic? socratic,
  FakeStore? store,
  DateTime Function()? clock,
  void Function(TutorVerdictEvent)? onVerdict,
}) {
  final c = classifier ?? FakeClassifier();
  final s = socratic ?? FakeSocratic();
  final st = store ?? FakeStore();
  return TutorService(
    classifier: c,
    socratic: s,
    store: st,
    clock: clock ?? DateTime.now,
    onVerdict: onVerdict,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TutorService initial state', () {
    test('starts as idle', () {
      final svc = _makeService();
      expect(svc.state, isA<TutorIdle>());
    });
  });

  group('startProblem', () {
    test('transitions idle → classifying → asking on success', () async {
      final socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(
            question: 'What is x?', hint: 'Think about subtraction'));
      final classifier = FakeClassifier()
        ..setResult(
            const ClassificationResult(topic: _kTopic));
      final svc = _makeService(classifier: classifier, socratic: socratic);

      // addListener fires immediately with the current state, so we skip the
      // initial idle emission and only track changes from startProblem.
      final states = <TutorState>[];
      svc.addListener((s) {
        if (s is! TutorIdle) states.add(s);
      });

      await svc.startProblem(_kProblemText);

      expect(states.length, 2,
          reason: 'should emit classifying then asking');
      expect(states[0], isA<TutorClassifying>());
      expect(states[1], isA<TutorAsking>());
      final asking = states[1] as TutorAsking;
      expect(asking.problemText, _kProblemText);
      expect(asking.topic, _kTopic);
      expect(asking.opener, 'What is x?');
    });

    test('falls back to a default opener when socratic returns null', () async {
      // Production behaviour: instead of stranding the student on a
      // classifying spinner forever, [TutorService.startProblem] inserts
      // the problem with a hard-coded fallback opener so the conversation
      // can begin. This regression-tests that fallback path.
      final socratic = FakeSocratic()..setOpener(null);
      final svc = _makeService(socratic: socratic);

      await svc.startProblem(_kProblemText);

      expect(svc.state, isA<TutorAsking>());
      final asking = svc.state as TutorAsking;
      expect(asking.opener, isNotEmpty);
    });

    test('uses fallback topic when classifier returns null', () async {
      final socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'));
      final classifier = FakeClassifier()..setResult(null);
      final svc = _makeService(classifier: classifier, socratic: socratic);

      await svc.startProblem(_kProblemText);

      final asking = svc.state as TutorAsking;
      expect(asking.topic.slug, 'general');
    });
  });

  group('submitAttempt', () {
    late FakeSocratic socratic;
    late FakeStore store;
    late TutorService svc;

    setUp(() async {
      socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'));
      store = FakeStore();
      svc = _makeService(socratic: socratic, store: store);
      await svc.startProblem(_kProblemText);
    });

    test('correct attempt → TutorSolved', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.correct, explanation: 'Right!'));

      await svc.submitAttempt('x = 3');

      expect(svc.state, isA<TutorSolved>());
      final asking = (svc.state as TutorSolved);
      expect(store.solvedFor(asking.problemId), isTrue);
    });

    test('incorrect attempt → reverts to TutorAsking', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));

      final prevState = svc.state as TutorAsking;
      await svc.submitAttempt('x = 99');

      expect(svc.state, isA<TutorAsking>());
      expect((svc.state as TutorAsking).problemId, prevState.problemId);
    });

    test('close verdict → reverts to TutorAsking', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.close, explanation: 'Almost'));

      await svc.submitAttempt('x = 2.9');

      expect(svc.state, isA<TutorAsking>());
    });

    test('null feedback → reverts to TutorAsking', () async {
      socratic.setFeedback(null);

      await svc.submitAttempt('x = 3');

      expect(svc.state, isA<TutorAsking>());
    });

    test('records student turn in store on correct attempt', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.correct, explanation: 'Yes'));

      await svc.submitAttempt('x = 3');

      // The store now also holds the persisted opener and the daksha
      // feedback turn (so resumed conversations show the full thread),
      // so we no longer assert exact length — just that the student
      // attempt is recorded with the right role and content.
      final studentTurns =
          store.turns.where((t) => t['role'] == 'student').toList();
      expect(studentTurns, hasLength(1));
      expect(studentTurns[0]['content'], 'x = 3');
    });

    test('records student turn on incorrect attempt', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));

      await svc.submitAttempt('x = 99');

      final studentTurns =
          store.turns.where((t) => t['role'] == 'student').toList();
      expect(studentTurns, hasLength(1));
      expect(studentTurns[0]['content'], 'x = 99');
    });

    test('persists daksha opener and feedback so chat can be resumed',
        () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));

      await svc.submitAttempt('x = 99');

      // The full conversation must reach the store: opener, then student
      // attempt, then daksha feedback. Without this a history → resume
      // round trip would render an empty chat.
      final dakshaTurns =
          store.turns.where((t) => t['role'] == 'daksha').toList();
      expect(dakshaTurns.map((t) => t['content']),
          containsAll(<String>['q', 'Wrong']));
    });

    test('routes a student doubt through StudentDoubt → reverts, not solved',
        () async {
      // The model decided the input was a question, not an attempt.
      // The service must NOT mark the problem solved and must NOT exit
      // the conversation; it should record the tutor's reply and stay.
      socratic.setDoubtReply('Think about what addition does.');

      final prev = svc.state as TutorAsking;
      await svc.submitAttempt('I do not understand the question');

      expect(svc.state, isA<TutorAsking>());
      expect((svc.state as TutorAsking).problemId, prev.problemId);
      expect(store.solvedFor(prev.problemId), isFalse);
      final dakshaTurns =
          store.turns.where((t) => t['role'] == 'daksha').toList();
      expect(dakshaTurns.map((t) => t['content']),
          contains('Think about what addition does.'));
    });

    test('throws StateError from idle', () async {
      final s = _makeService();
      expect(() => s.submitAttempt('x = 3'), throwsStateError);
    });
  });

  group('requestHint', () {
    late FakeSocratic socratic;
    late FakeStore store;
    late TutorService svc;

    setUp(() async {
      socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'))
        ..setHint('Try substituting');
      store = FakeStore();
      svc = _makeService(socratic: socratic, store: store);
      await svc.startProblem(_kProblemText);
    });

    test('asking → hinting level 1', () async {
      await svc.requestHint();

      expect(svc.state, isA<TutorHinting>());
      expect((svc.state as TutorHinting).level, 1);
      expect((svc.state as TutorHinting).hint, 'Try substituting');
    });

    test('level monotonically non-decreasing: 1 → 2 → 3', () async {
      await svc.requestHint(); // 1
      final l1 = (svc.state as TutorHinting).level;

      await svc.requestHint(); // 2
      final l2 = (svc.state as TutorHinting).level;

      expect(l2, greaterThanOrEqualTo(l1));
      expect(l1, 1);
      expect(l2, 2);
    });

    test('level caps at 3', () async {
      await svc.requestHint(); // 1
      await svc.requestHint(); // 2
      await svc.requestHint(); // 3

      expect((svc.state as TutorHinting).level, 3);
    });

    test('REVEAL gate: requestHint at level 3 within 3 min throws HintGateException',
        () async {
      final base = DateTime(2025, 1, 1, 12, 0, 0);
      var tick = 0;
      // Clock advances 1 second per call.
      final svc2 = TutorService(
        classifier: FakeClassifier(),
        socratic: socratic,
        store: store,
        clock: () => base.add(Duration(seconds: tick++)),
      );

      // Advance to Asking state
      await svc2.startProblem(_kProblemText);
      await svc2.requestHint(); // → level 1
      await svc2.requestHint(); // → level 2
      await svc2.requestHint(); // → level 3  (tick ~3s)

      // Now try to request again (level already 3, only ~3s elapsed << 3 min)
      await expectLater(
        svc2.requestHint(),
        throwsA(isA<HintGateException>()),
      );
    });

    test('REVEAL gate: requestHint at level 3 after 3 min succeeds', () async {
      final base = DateTime(2025, 1, 1, 12, 0, 0);
      // We'll provide a clock we can jump forward.
      var currentTime = base;
      final svc2 = TutorService(
        classifier: FakeClassifier(),
        socratic: socratic..setHint('big hint'),
        store: store,
        clock: () => currentTime,
      );

      await svc2.startProblem(_kProblemText);
      await svc2.requestHint(); // → level 1
      await svc2.requestHint(); // → level 2
      await svc2.requestHint(); // → level 3

      // Jump clock past 3 minutes
      currentTime = base.add(const Duration(minutes: 4));

      // Should succeed without throwing
      await svc2.requestHint(); // still level 3 (capped)

      expect((svc2.state as TutorHinting).level, 3);
    });

    test('null hint → stays in current state', () async {
      socratic.setHint(null);
      final prevState = svc.state;

      await svc.requestHint();

      expect(svc.state, prevState);
    });

    test('throws StateError from idle', () async {
      final s = _makeService();
      expect(() => s.requestHint(), throwsStateError);
    });

    test('hint level never decreases', () async {
      // Get to hinting level 2, then submitAttempt incorrect reverts to hinting,
      // then request another hint – level must stay >= 2.
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));
      socratic.setHint('more help');

      await svc.requestHint(); // level 1
      await svc.requestHint(); // level 2
      final levelBefore = (svc.state as TutorHinting).level;

      await svc.submitAttempt('bad answer'); // reverts to TutorHinting
      expect(svc.state, isA<TutorHinting>());
      final levelAfterRevert = (svc.state as TutorHinting).level;

      await svc.requestHint(); // level 3
      final levelFinal = (svc.state as TutorHinting).level;

      expect(levelAfterRevert, greaterThanOrEqualTo(levelBefore));
      expect(levelFinal, greaterThanOrEqualTo(levelAfterRevert));
    });
  });

  group('verdict events', () {
    late FakeSocratic socratic;
    late FakeStore store;
    late List<TutorVerdictEvent> events;
    late TutorService svc;

    setUp(() async {
      socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'));
      store = FakeStore();
      events = [];
      svc = _makeService(
        socratic: socratic,
        store: store,
        onVerdict: events.add,
      );
      await svc.startProblem(_kProblemText);
    });

    test('correct attempt fires a verdict event', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.correct, explanation: 'Right!'));

      await svc.submitAttempt('x = 3');

      expect(events, hasLength(1));
      expect(events.single.verdict, AttemptVerdict.correct);
      expect(events.single.explanation, 'Right!');
    });

    test('incorrect attempt fires a verdict event', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));

      await svc.submitAttempt('x = 99');

      expect(events, hasLength(1));
      expect(events.single.verdict, AttemptVerdict.incorrect);
    });

    test('"close" verdict does NOT fire a pop-up', () async {
      // "close" means "almost there" — popping a dialog would interrupt
      // the rhythm of guided practice. The chat reply alone is the cue.
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.close, explanation: 'Almost'));

      await svc.submitAttempt('x = 2.9');

      expect(events, isEmpty);
    });

    test('student doubt does NOT fire a verdict event', () async {
      socratic.setDoubtReply('think about subtraction');

      await svc.submitAttempt('I am confused');

      expect(events, isEmpty);
    });

    test('post-solve follow-up does NOT fire a verdict event', () async {
      // Bug fix: once solved, casual follow-ups the model misjudges as
      // "incorrect attempts" should not pop up "Not quite!" dialogs.
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.correct, explanation: 'Right!'));
      await svc.submitAttempt('x = 3');
      expect(svc.state, isA<TutorSolved>());
      events.clear();

      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Hmm'));
      await svc.submitAttempt('what about 5+3?');

      expect(events, isEmpty,
          reason: 'post-solve verdicts should be suppressed');
    });
  });

  group('post-solve follow-ups', () {
    late FakeSocratic socratic;
    late FakeStore store;
    late TutorService svc;

    setUp(() async {
      socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'));
      store = FakeStore();
      svc = _makeService(socratic: socratic, store: store);
      await svc.startProblem(_kProblemText);
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.correct, explanation: 'Right!'));
      await svc.submitAttempt('x = 3');
      assert(svc.state is TutorSolved);
    });

    test('submitAttempt from solved state does NOT throw', () async {
      // Bug fix: previously threw `Cannot submit input from state
      // TutorState.solved(...)`. The input field was left enabled by the
      // UI ("never disable just because the problem is solved" — see
      // problem_screen.dart) but every send crashed.
      socratic.setDoubtReply('Great question!');

      await expectLater(svc.submitAttempt('why does that work?'),
          completes);
      expect(svc.state, isA<TutorSolved>());
    });

    test('post-solve doubt routes the reply into the chat', () async {
      socratic.setDoubtReply('Because 25% is 1/4.');

      await svc.submitAttempt('why 4?');

      final dakshaTurns =
          store.turns.where((t) => t['role'] == 'daksha').toList();
      expect(dakshaTurns.map((t) => t['content']),
          contains('Because 25% is 1/4.'));
    });

    test('post-solve attempt judged "incorrect" stays in TutorSolved',
        () async {
      // The student already solved it. A model misjudgement on a follow-up
      // shouldn't un-solve the problem.
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'No'));

      await svc.submitAttempt('something random');

      expect(svc.state, isA<TutorSolved>());
    });
  });

  group('reset', () {
    test('resets to idle from any state', () async {
      final socratic = FakeSocratic()
        ..setOpener(const SocraticOpener(question: 'q', hint: 'h'));
      final svc = _makeService(socratic: socratic);

      await svc.startProblem(_kProblemText);
      expect(svc.state, isA<TutorAsking>());

      svc.reset();
      expect(svc.state, isA<TutorIdle>());
    });
  });
}
