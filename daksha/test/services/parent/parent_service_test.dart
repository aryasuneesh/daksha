import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/services/parent/parent_service.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeInferenceEngine implements InferenceEngine {
  final List<InferenceRequest> requests = [];
  final List<InferenceResponse> _responses;
  int _callCount = 0;

  _FakeInferenceEngine(this._responses);

  @override
  Future<void> load() async {}

  @override
  Future<void> dispose() async {}

  @override
  bool get isLoaded => true;

  @override
  bool get supportsVision => false;

  @override
  Future<InferenceResponse> generate(InferenceRequest request) async {
    requests.add(request);
    final response = _responses[_callCount % _responses.length];
    _callCount++;
    return response;
  }
}

class _FakeStore implements ParentQaStore {
  final List<Map<String, dynamic>> insertions = [];

  @override
  Future<String> insertQa({
    required String question,
    required String? plan,
    required String answer,
    required DateTime askedAt,
  }) async {
    insertions.add({
      'question': question,
      'plan': plan,
      'answer': answer,
      'askedAt': askedAt,
    });
    return 'fake-uuid';
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const testQuestion = 'How is my child doing in math?';
  const planText = 'Step 1: mention progress. Step 2: give encouragement.';
  const answerText = 'Your child is making great progress!';

  group('ParentService.ask — happy path', () {
    test('calls engine twice: PLAN then SPEAK', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      expect(engine.requests.length, 2);
    });

    test('PLAN pass uses lower temperature (0.3) and larger token budget (256)',
        () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      final planReq = engine.requests[0];
      expect(planReq.temperature, closeTo(0.3, 0.01));
      expect(planReq.maxTokens, greaterThanOrEqualTo(200));
    });

    test('SPEAK pass uses higher temperature (0.7) and shorter token budget',
        () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      final speakReq = engine.requests[1];
      expect(speakReq.temperature, closeTo(0.7, 0.01));
      expect(speakReq.maxTokens, lessThan(engine.requests[0].maxTokens));
    });

    test('SPEAK prompt includes the plan output', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      expect(engine.requests[1].prompt, contains(planText));
    });

    test('PLAN prompt includes the question', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      expect(engine.requests[0].prompt, contains(testQuestion));
    });

    test('returns ParentResponse with correct fields', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      final response = await service.ask(testQuestion);

      expect(response.question, testQuestion);
      expect(response.plan, planText);
      expect(response.answer, answerText);
    });

    test('persists Q&A to store after both passes', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await service.ask(testQuestion);

      expect(store.insertions.length, 1);
      expect(store.insertions.first['question'], testQuestion);
      expect(store.insertions.first['plan'], planText);
      expect(store.insertions.first['answer'], answerText);
    });

    test('persists with the injected clock time', () async {
      final fixedTime = DateTime(2025, 6, 15, 10, 30);
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(
        engine: engine,
        store: store,
        clock: () => fixedTime,
      );

      await service.ask(testQuestion);

      expect(store.insertions.first['askedAt'], fixedTime);
    });

    test('trims whitespace from plan and answer', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: '  $planText  \n'),
        InferenceSuccess(text: '\n  $answerText  '),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      final response = await service.ask(testQuestion);

      expect(response.plan, planText);
      expect(response.answer, answerText);
    });
  });

  group('ParentService.ask — failure cases', () {
    test('throws ParentServiceException if PLAN pass fails', () async {
      final engine = _FakeInferenceEngine([
        const InferenceFailure(error: 'model error'),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      expect(
        () => service.ask(testQuestion),
        throwsA(isA<ParentServiceException>()),
      );
    });

    test('PLAN failure message mentions PLAN pass', () async {
      final engine = _FakeInferenceEngine([
        const InferenceFailure(error: 'timeout'),
        InferenceSuccess(text: answerText),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await expectLater(
        service.ask(testQuestion),
        throwsA(
          isA<ParentServiceException>().having(
            (e) => e.message,
            'message',
            contains('PLAN'),
          ),
        ),
      );
    });

    test('throws ParentServiceException if SPEAK pass fails', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        const InferenceFailure(error: 'out of memory'),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      expect(
        () => service.ask(testQuestion),
        throwsA(isA<ParentServiceException>()),
      );
    });

    test('SPEAK failure message mentions SPEAK pass', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        const InferenceFailure(error: 'out of memory'),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      await expectLater(
        service.ask(testQuestion),
        throwsA(
          isA<ParentServiceException>().having(
            (e) => e.message,
            'message',
            contains('SPEAK'),
          ),
        ),
      );
    });

    test('does not persist to store when PLAN pass fails', () async {
      final engine = _FakeInferenceEngine([
        const InferenceFailure(error: 'model error'),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      try {
        await service.ask(testQuestion);
      } on ParentServiceException {
        // expected
      }

      expect(store.insertions, isEmpty);
    });

    test('does not persist to store when SPEAK pass fails', () async {
      final engine = _FakeInferenceEngine([
        InferenceSuccess(text: planText),
        const InferenceFailure(error: 'model error'),
      ]);
      final store = _FakeStore();
      final service = ParentService(engine: engine, store: store);

      try {
        await service.ask(testQuestion);
      } on ParentServiceException {
        // expected
      }

      expect(store.insertions, isEmpty);
    });
  });

  group('ParentServiceException', () {
    test('toString includes the message', () {
      const ex = ParentServiceException('PLAN pass failed: timeout');
      expect(ex.toString(), contains('PLAN pass failed: timeout'));
    });
  });
}
