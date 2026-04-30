import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/inference/inference_engine.dart';

void main() {
  group('InferenceRequest', () {
    test('uses default values for maxTokens and temperature', () {
      final request = InferenceRequest(prompt: 'hello');
      expect(request.prompt, 'hello');
      expect(request.maxTokens, 512);
      expect(request.temperature, 0.7);
      expect(request.grammarBnf, null);
    });

    test('JSON round-trip preserves all fields', () {
      final original = InferenceRequest(
        prompt: 'Explain quantum computing',
        maxTokens: 1024,
        temperature: 0.5,
        grammarBnf: 'root ::= "yes" | "no"',
      );

      final json = original.toJson();
      final deserialized = InferenceRequest.fromJson(json);

      expect(deserialized, original);
    });

    test('equality works for identical requests', () {
      final request1 = InferenceRequest(prompt: 'test');
      final request2 = InferenceRequest(prompt: 'test');
      expect(request1, request2);
    });

    test('JSON includes null grammarBnf as null when not provided', () {
      final request = InferenceRequest(prompt: 'hello');
      final json = request.toJson();
      expect(json['grammarBnf'], null);
    });
  });

  group('InferenceResponse', () {
    test('success responses with same fields are equal', () {
      final response1 = InferenceResponse.success(
        text: 'Generated text',
        tokensGenerated: 42,
      );
      final response2 = InferenceResponse.success(
        text: 'Generated text',
        tokensGenerated: 42,
      );
      expect(response1, response2);
    });

    test('failure responses with same error are equal', () {
      final response1 = InferenceResponse.failure(error: 'Model not loaded');
      final response2 = InferenceResponse.failure(error: 'Model not loaded');
      expect(response1, response2);
    });

    test('success is not equal to failure', () {
      final success = InferenceResponse.success(text: 'hello');
      final failure = InferenceResponse.failure(error: 'error');
      expect(success, isNot(failure));
    });

    test('success response uses default tokensGenerated of 0', () {
      final response = InferenceResponse.success(text: 'hello');
      response.when(
        success: (text, tokensGenerated) {
          expect(tokensGenerated, 0);
        },
        failure: (error) {
          fail('Expected success, got failure');
        },
      );
    });

    test('success response can be pattern-matched with when', () {
      final response = InferenceResponse.success(
        text: 'hello world',
        tokensGenerated: 10,
      );

      final result = response.when(
        success: (text, tokensGenerated) => 'Success: $tokensGenerated tokens',
        failure: (error) => 'Failure: $error',
      );

      expect(result, 'Success: 10 tokens');
    });

    test('failure response can be pattern-matched with when', () {
      final response = InferenceResponse.failure(error: 'Model error');

      final result = response.when(
        success: (text, tokensGenerated) => 'Success',
        failure: (error) => 'Error: $error',
      );

      expect(result, 'Error: Model error');
    });
  });
}
