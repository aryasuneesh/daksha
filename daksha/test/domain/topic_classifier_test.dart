import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/inference/inference_engine.dart';

class MockInferenceEngine extends Mock implements InferenceEngine {}

void main() {
  setUpAll(() {
    registerFallbackValue(InferenceRequest(prompt: 'test'));
  });

  group('TopicClassifier', () {
    late MockInferenceEngine mockEngine;
    late List<Topic> topics;

    setUp(() {
      mockEngine = MockInferenceEngine();
      topics = [
        const Topic(
          subject: 'math',
          slug: 'linear-equations',
          displayName: 'Linear Equations',
        ),
        const Topic(
          subject: 'math',
          slug: 'fractions',
          displayName: 'Fractions & Decimals',
        ),
        const Topic(
          subject: 'physics',
          slug: 'motion',
          displayName: 'Motion & Speed',
        ),
      ];
    });

    test('returns ClassificationResult with correct topic on well-formed response',
        () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.success(
        text: '{"subject":"math","slug":"linear-equations","confidence":0.9}',
        tokensGenerated: 10,
      );
      when(() => mockEngine.generate(any())).thenAnswer((_) async => response);

      final result = await classifier.classify('Solve 2x + 3 = 7');

      expect(result, isNotNull);
      expect(result!.topic.slug, equals('linear-equations'));
      expect(result.topic.subject, equals('math'));
      expect(result.confidence, equals(0.9));
    });

    test('returns null on engine failure', () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.failure(error: 'timeout');
      when(() => mockEngine.generate(any())).thenAnswer((_) async => response);

      final result = await classifier.classify('some problem');

      expect(result, isNull);
    });

    test('returns null when JSON has unknown slug', () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.success(
        text: '{"subject":"math","slug":"nonexistent-slug","confidence":0.8}',
        tokensGenerated: 10,
      );
      when(() => mockEngine.generate(any())).thenAnswer((_) async => response);

      final result = await classifier.classify('some problem');

      expect(result, isNull);
    });

    test('returns null on malformed JSON', () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.success(
        text: 'not json at all',
        tokensGenerated: 10,
      );
      when(() => mockEngine.generate(any())).thenAnswer((_) async => response);

      final result = await classifier.classify('some problem');

      expect(result, isNull);
    });

    test('subject mismatch returns null', () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.success(
        text: '{"subject":"physics","slug":"linear-equations","confidence":0.7}',
        tokensGenerated: 10,
      );
      when(() => mockEngine.generate(any())).thenAnswer((_) async => response);

      final result = await classifier.classify('some problem');

      expect(result, isNull);
    });

    test('calls engine.generate with correct request structure', () async {
      final classifier = TopicClassifier(engine: mockEngine, topics: topics);

      final response = InferenceResponse.success(
        text: '{"subject":"math","slug":"fractions","confidence":0.8}',
        tokensGenerated: 10,
      );

      late InferenceRequest capturedRequest;
      when(() => mockEngine.generate(any())).thenAnswer((invocation) {
        capturedRequest = invocation.positionalArguments.first as InferenceRequest;
        return Future.value(response);
      });

      await classifier.classify('test problem text');

      expect(capturedRequest.maxTokens, equals(64));
      expect(capturedRequest.grammarBnf, isNotNull);
      expect(capturedRequest.prompt, contains('test problem text'));
      expect(capturedRequest.prompt, contains('math/linear-equations'));
      expect(capturedRequest.prompt, contains('physics/motion'));
    });
  });
}
