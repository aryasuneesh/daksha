import 'package:flutter_test/flutter_test.dart';

import 'package:daksha/inference/gbnf_compiler.dart';

void main() {
  group('GbnfCompiler', () {
    test('single string property produces root rule with key and string rule',
        () {
      final schema = {
        'type': 'object',
        'properties': {
          'hint': {'type': 'string'},
        },
      };

      final grammar = GbnfCompiler.compile(schema);

      expect(grammar, contains('root'));
      expect(grammar, contains('"hint"'));
      expect(grammar, contains('string'));
    });

    test('two properties (string + number) produces correct keys and rules',
        () {
      final schema = {
        'type': 'object',
        'properties': {
          'question': {'type': 'string'},
          'difficulty': {'type': 'number'},
        },
      };

      final grammar = GbnfCompiler.compile(schema);

      expect(grammar, contains('"question"'));
      expect(grammar, contains('"difficulty"'));
      expect(grammar, contains('number'));
    });

    test('boolean property produces key and true/false literals', () {
      final schema = {
        'type': 'object',
        'properties': {
          'correct': {'type': 'boolean'},
        },
      };

      final grammar = GbnfCompiler.compile(schema);

      expect(grammar, contains('"correct"'));
      expect(grammar, contains('"true"'));
    });

    test('integer property produces key and number/integer rule', () {
      final schema = {
        'type': 'object',
        'properties': {
          'score': {'type': 'integer'},
        },
      };

      final grammar = GbnfCompiler.compile(schema);

      expect(grammar, contains('"score"'));
      // integer should map to a number-like rule
      final hasNumberRule =
          grammar.contains('number') || grammar.contains('integer');
      expect(hasNumberRule, isTrue);
    });

    test('unsupported top-level type throws ArgumentError', () {
      final schema = {'type': 'array'};

      expect(() => GbnfCompiler.compile(schema), throwsArgumentError);
    });

    test('round-trip: result is a non-empty string', () {
      final schema = {
        'type': 'object',
        'properties': {
          'x': {'type': 'string'},
        },
      };

      final result = GbnfCompiler.compile(schema);

      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });
  });
}
