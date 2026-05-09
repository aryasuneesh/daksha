import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/inference/inference_engine.dart';

class MockInferenceEngine extends Mock implements InferenceEngine {}

void main() {
  late MockInferenceEngine mockEngine;
  late SocraticService service;

  setUpAll(() {
    registerFallbackValue(InferenceRequest(prompt: 'test'));
  });

  setUp(() {
    mockEngine = MockInferenceEngine();
    service = SocraticService(mockEngine);
  });

  group('generateSocraticOpener', () {
    test('parses valid JSON response to SocraticOpener', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse =
          '{"question":"What is x?","hint":"Think about balance."}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final opener = await service.generateSocraticOpener(
        problemText: problemText,
        topic: topic,
      );

      expect(opener, isNotNull);
      expect(opener!.question, 'What is x?');
      expect(opener.hint, 'Think about balance.');
    });

    test('returns null on engine failure', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.failure(error: 'Model error'),
      );

      final opener = await service.generateSocraticOpener(
        problemText: problemText,
        topic: topic,
      );

      expect(opener, isNull);
    });

    test('returns null on malformed JSON', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: '{invalid json}'),
      );

      final opener = await service.generateSocraticOpener(
        problemText: problemText,
        topic: topic,
      );

      expect(opener, isNull);
    });

    test('returns null if question field is missing', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"hint":"Think about balance."}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final opener = await service.generateSocraticOpener(
        problemText: problemText,
        topic: topic,
      );

      expect(opener, isNull);
    });

    test('returns null if hint field is missing', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"question":"What is x?"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final opener = await service.generateSocraticOpener(
        problemText: problemText,
        topic: topic,
      );

      expect(opener, isNull);
    });
  });

  group('checkAttempt', () {
    test('parses verdict "correct" to AttemptVerdict.correct', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      // Updated to the new judgeOrReply schema — checkAttempt is now a thin
      // wrapper around it, so the engine must produce the combined
      // {kind, verdict, reply} shape.
      const jsonResponse =
          '{"kind":"attempt","verdict":"correct","reply":"x = 2 is correct!"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNotNull);
      expect(feedback!.verdict, AttemptVerdict.correct);
      expect(feedback.explanation, 'x = 2 is correct!');
    });

    test('parses verdict "close" to AttemptVerdict.close', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2.5';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse =
          '{"kind":"attempt","verdict":"close","reply":"Very close!"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNotNull);
      expect(feedback!.verdict, AttemptVerdict.close);
      expect(feedback.explanation, 'Very close!');
    });

    test('parses verdict "incorrect" to AttemptVerdict.incorrect', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 5';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse =
          '{"kind":"attempt","verdict":"incorrect","reply":"Not quite right."}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNotNull);
      expect(feedback!.verdict, AttemptVerdict.incorrect);
      expect(feedback.explanation, 'Not quite right.');
    });

    test('returns null for unknown verdict string', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse =
          '{"verdict":"unknown","explanation":"Something went wrong"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNull);
    });

    test('returns null on engine failure', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.failure(error: 'Model error'),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNull);
    });

    test('returns null on malformed JSON', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: '{bad json}'),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNull);
    });

    test('returns null if verdict field is missing', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"explanation":"Some explanation"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNull);
    });

    test('returns null if explanation field is missing', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      const studentAttempt = 'x = 2';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"verdict":"correct"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final feedback = await service.checkAttempt(
        problemText: problemText,
        studentAttempt: studentAttempt,
        topic: topic,
      );

      expect(feedback, isNull);
    });
  });

  group('generateHint', () {
    test('parses valid JSON response to hint string', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"hint":"Consider the left side."}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
        hintLevel: 1,
      );

      expect(hint, 'Consider the left side.');
    });

    test('respects hintLevel parameter', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"hint":"x = 2"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
        hintLevel: 3,
      );

      expect(hint, 'x = 2');
      verify(() => mockEngine.generate(any())).called(1);
    });

    test('returns null on engine failure', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.failure(error: 'Model error'),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
      );

      expect(hint, isNull);
    });

    test('returns null on malformed JSON', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: '{invalid}'),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
      );

      expect(hint, isNull);
    });

    test('returns null if hint field is missing', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
      );

      expect(hint, isNull);
    });

    test('defaults to hintLevel 1', () async {
      const problemText = 'Solve: 2x + 3 = 7';
      final topic = Topic(
        subject: 'Math',
        slug: 'algebra',
        displayName: 'Algebra',
      );

      const jsonResponse = '{"hint":"Think carefully"}';
      when(() => mockEngine.generate(any())).thenAnswer(
        (_) async => InferenceResponse.success(text: jsonResponse),
      );

      final hint = await service.generateHint(
        problemText: problemText,
        topic: topic,
      );

      expect(hint, 'Think carefully');
    });
  });
}
