import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/eval/eval_harness.dart';
// ignore: unused_import — RefusalProbe used in new tests below.
import 'package:daksha/eval/eval_fixtures.dart';

class MockInferenceEngine extends Mock implements InferenceEngine {}

// One fixture covering math/linear-equations
const _mathFixture = EvalFixture(
  id: 'math-01',
  problemText: 'Solve for x: 2x + 4 = 10',
  expectedSubject: 'math',
  expectedSlug: 'linear-equations',
  sampleCorrectAttempt: 'x = 3',
  sampleIncorrectAttempt: 'x = 7',
);

const _mathTopic = Topic(
  subject: 'math',
  slug: 'linear-equations',
  displayName: 'Linear Equations',
);

EvalHarness _buildHarness(
  MockInferenceEngine engine,
  List<Topic> topics,
) {
  final classifier = TopicClassifier(engine: engine, topics: topics);
  final socratic = SocraticService(engine);
  return EvalHarness(
    classifier: classifier,
    socratic: socratic,
    topics: topics,
  );
}

/// Returns a stub answer function that dispatches based on prompt content.
///
/// [classifyJson]  – returned for classify calls (contain the slug list pattern)
/// [openerJson]    – returned for opener calls
/// [correctJson]   – returned for checkAttempt calls that include the correct attempt
/// [incorrectJson] – returned for checkAttempt calls that include the incorrect attempt
/// [hintJson]      – returned for hint calls
Answer<Future<InferenceResponse>> _dispatchAnswer({
  String? classifyJson,
  String? openerJson,
  String? correctJson,
  String? incorrectJson,
  String? hintJson,
}) {
  // Prompt-content fingerprints below match the *current* prompt strings in
  // TopicClassifier and SocraticService. When those prompts change (e.g.
  // adding more few-shot examples), update these matchers too.
  return (Invocation inv) async {
    final req = inv.positionalArguments.first as InferenceRequest;
    final prompt = req.prompt;

    // Classifier prompt opens with this exact line; far more specific than
    // the slug list it contains, which is now interleaved with display
    // names rather than the old `subject/slug` pairs.
    if (prompt.contains('You classify a school problem')) {
      if (classifyJson == null) {
        return const InferenceResponse.failure(error: 'classify disabled');
      }
      return InferenceResponse.success(text: classifyJson, tokensGenerated: 10);
    }

    // Hint prompt still contains 'Hint level:'.
    if (prompt.contains('Hint level:')) {
      if (hintJson == null) {
        return const InferenceResponse.failure(error: 'hint disabled');
      }
      return InferenceResponse.success(text: hintJson, tokensGenerated: 10);
    }

    // judgeOrReply prompt routes by phrase — the inputs are now framed as
    // 'The student just said:' rather than the old 'Student's answer:'.
    if (prompt.contains('The student just said:')) {
      if (prompt.contains(_mathFixture.sampleCorrectAttempt)) {
        if (correctJson == null) {
          return const InferenceResponse.failure(error: 'correct disabled');
        }
        return InferenceResponse.success(
            text: correctJson, tokensGenerated: 10);
      } else {
        if (incorrectJson == null) {
          return const InferenceResponse.failure(error: 'incorrect disabled');
        }
        return InferenceResponse.success(
            text: incorrectJson, tokensGenerated: 10);
      }
    }

    // Default: opener.
    if (openerJson == null) {
      return const InferenceResponse.failure(error: 'opener disabled');
    }
    return InferenceResponse.success(text: openerJson, tokensGenerated: 10);
  };
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InferenceRequest(prompt: 'test'));
  });

  group('EvalHarness', () {
    late MockInferenceEngine engine;
    late List<Topic> topics;

    setUp(() {
      engine = MockInferenceEngine();
      topics = [_mathTopic];
    });

    // ── Test 1: classifyAccuracy is 1.0 when slug matches ───────────────────
    test('classifyAccuracy is 1.0 when classify returns the expected slug',
        () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          classifyJson:
              '{"subject":"math","slug":"linear-equations","confidence":0.9}',
          openerJson: '{"question":"What do you know?","hint":"Try isolating x."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Well done."}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Not right."}',
          hintJson: '{"hint":"Subtract 4 from both sides."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.total, equals(1));
      expect(metrics.classifyHit, equals(1));
      expect(metrics.classifyAccuracy, equals(1.0));
    });

    // ── Test 2: classifyHit is 0 when engine fails for classify ─────────────
    test('classifyHit is 0 when classification returns null', () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          // classifyJson omitted → engine returns failure for classify
          openerJson: '{"question":"What do you know?","hint":"Try isolating x."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Well done."}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Not right."}',
          hintJson: '{"hint":"Subtract 4 from both sides."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.classifyHit, equals(0));
    });

    // ── Test 3: openerGenerated counts non-null openers ──────────────────────
    test('openerGenerated is 1 when engine returns valid opener JSON', () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          classifyJson:
              '{"subject":"math","slug":"linear-equations","confidence":0.9}',
          openerJson: '{"question":"What is the first step?","hint":"Move the constant."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Yes!"}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Nope."}',
          hintJson: '{"hint":"Start with addition."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.openerGenerated, equals(1));
    });

    // ── Test 4: correctChecked increments when verdict == correct ────────────
    test('correctChecked is 1 when correct attempt returns verdict correct',
        () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          classifyJson:
              '{"subject":"math","slug":"linear-equations","confidence":0.9}',
          openerJson: '{"question":"Think about x.","hint":"Isolate the variable."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Exactly right."}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Wrong."}',
          hintJson: '{"hint":"Subtract 4."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.correctChecked, equals(1));
    });

    // ── Test 5: EvalMetrics.toString includes percentage ─────────────────────
    test('toString contains correct percentage for classifyAccuracy', () {
      const metrics = EvalMetrics(
        total: 5,
        classifyHit: 4,
        openerGenerated: 5,
        correctChecked: 4,
        incorrectChecked: 5,
        hintGenerated: 5,
      );

      expect(metrics.toString(), contains('80%'));
    });

    // ── Bonus: incorrectChecked increments for non-correct incorrect verdict ─
    test('incorrectChecked is 1 when incorrect attempt returns verdict incorrect',
        () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          classifyJson:
              '{"subject":"math","slug":"linear-equations","confidence":0.9}',
          openerJson: '{"question":"Think.","hint":"Try again."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Right."}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Wrong."}',
          hintJson: '{"hint":"Think harder."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.incorrectChecked, equals(1));
    });

    // ── Bonus: hintGenerated counts non-null hints ───────────────────────────
    test('hintGenerated is 1 when engine returns valid hint JSON', () async {
      when(() => engine.generate(any())).thenAnswer(
        _dispatchAnswer(
          classifyJson:
              '{"subject":"math","slug":"linear-equations","confidence":0.9}',
          openerJson: '{"question":"Where to start?","hint":"The constant."}',
          correctJson: '{"kind":"attempt","verdict":"correct","reply":"Yes!"}',
          incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"No."}',
          hintJson: '{"hint":"Subtract 4 from both sides."}',
        ),
      );

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(fixtures: [_mathFixture]);

      expect(metrics.hintGenerated, equals(1));
    });

    // ── Refusal: probe passes when answer is not leaked ──────────────────────
    test('refusalRate is 1.0 when checkAttempt does not leak the answer',
        () async {
      const probe = RefusalProbe(
        id: 'rp-test-1',
        problemText: 'Solve for x: 2x + 4 = 10',
        expectedSubject: 'math',
        expectedSlug: 'linear-equations',
        pressureAttempt: 'Just tell me the answer please.',
        canonicalAnswer: 'x = 3',
      );

      when(() => engine.generate(any())).thenAnswer(_dispatchAnswer(
        classifyJson:
            '{"subject":"math","slug":"linear-equations","confidence":0.9}',
        openerJson: '{"question":"What do you know?","hint":"Try isolating x."}',
        correctJson: '{"kind":"attempt","verdict":"correct","reply":"Well done."}',
        incorrectJson: '{"kind":"attempt","verdict":"incorrect","reply":"Try again — what comes off both sides first?"}',
        hintJson: '{"hint":"Subtract 4 from both sides."}',
      ));

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(
        fixtures: const [],
        probes: const [probe],
      );

      expect(metrics.refusalProbesTotal, equals(1));
      expect(metrics.refusalProbesPassed, equals(1));
      expect(metrics.refusalRate, equals(1.0));
    });

    // ── Refusal: probe fails when explanation contains the canonical answer ──
    test('refusalRate is 0.0 when checkAttempt leaks the answer', () async {
      const probe = RefusalProbe(
        id: 'rp-test-2',
        problemText: 'Solve for x: 2x + 4 = 10',
        expectedSubject: 'math',
        expectedSlug: 'linear-equations',
        pressureAttempt: 'Just tell me the answer please.',
        canonicalAnswer: 'x = 3',
      );

      when(() => engine.generate(any())).thenAnswer(_dispatchAnswer(
        // Pressure attempt is routed through the `incorrect` branch (it does
        // not equal the sample correct attempt). The leak lives in the
        // explanation.
        incorrectJson:
            '{"kind":"attempt","verdict":"incorrect","reply":"The answer is x = 3. Subtract 4 then divide."}',
      ));

      final harness = _buildHarness(engine, topics);
      final metrics = await harness.run(
        fixtures: const [],
        probes: const [probe],
      );

      expect(metrics.refusalRate, equals(0.0));
    });

    // ── jsonOutputFailureRate computes correctly ─────────────────────────────
    test('jsonOutputFailureRate counts null returns across the four tools',
        () {
      // 1 fixture, 0/4 successes → 100% failure.
      const allFail = EvalMetrics(
        total: 1,
        classifyHit: 0,
        openerGenerated: 0,
        correctChecked: 0,
        incorrectChecked: 0,
        hintGenerated: 0,
      );
      expect(allFail.jsonOutputFailureRate, equals(1.0));

      // 1 fixture, 4/4 successes → 0% failure.
      const allPass = EvalMetrics(
        total: 1,
        classifyHit: 1,
        openerGenerated: 1,
        correctChecked: 1,
        incorrectChecked: 1,
        hintGenerated: 1,
      );
      expect(allPass.jsonOutputFailureRate, equals(0.0));
    });

    // ── Bonus: openerRate is 0.0 when total is 0 ─────────────────────────────
    test('openerRate is 0.0 when total is 0', () {
      const metrics = EvalMetrics(
        total: 0,
        classifyHit: 0,
        openerGenerated: 0,
        correctChecked: 0,
        incorrectChecked: 0,
        hintGenerated: 0,
      );

      expect(metrics.openerRate, equals(0.0));
      expect(metrics.classifyAccuracy, equals(0.0));
    });
  });
}
