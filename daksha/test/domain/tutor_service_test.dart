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
class FakeSocratic extends SocraticService {
  SocraticOpener? _opener;
  AttemptFeedback? _feedback;
  String? _hint;

  FakeSocratic() : super(_FakeEngine());

  void setOpener(SocraticOpener? o) => _opener = o;
  void setFeedback(AttemptFeedback? f) => _feedback = f;
  void setHint(String? h) => _hint = h;

  @override
  Future<SocraticOpener?> generateSocraticOpener({
    required String problemText,
    required Topic topic,
  }) async =>
      _opener;

  @override
  Future<AttemptFeedback?> checkAttempt({
    required String problemText,
    required String studentAttempt,
    required Topic topic,
  }) async =>
      _feedback;

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
    });
  }

  bool? solvedFor(String id) => _solved[id];
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
}) {
  final c = classifier ?? FakeClassifier();
  final s = socratic ?? FakeSocratic();
  final st = store ?? FakeStore();
  return TutorService(
    classifier: c,
    socratic: s,
    store: st,
    clock: clock ?? DateTime.now,
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
            const ClassificationResult(topic: _kTopic, confidence: 0.9));
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

    test('stays in classifying when opener is null', () async {
      final socratic = FakeSocratic()..setOpener(null);
      final svc = _makeService(socratic: socratic);

      await svc.startProblem(_kProblemText);

      expect(svc.state, isA<TutorClassifying>());
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

      expect(store.turns, hasLength(1));
      expect(store.turns[0]['role'], 'student');
      expect(store.turns[0]['content'], 'x = 3');
    });

    test('records student turn on incorrect attempt', () async {
      socratic.setFeedback(const AttemptFeedback(
          verdict: AttemptVerdict.incorrect, explanation: 'Wrong'));

      await svc.submitAttempt('x = 99');

      expect(store.turns, hasLength(1));
      expect(store.turns[0]['role'], 'student');
      expect(store.turns[0]['content'], 'x = 99');
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
