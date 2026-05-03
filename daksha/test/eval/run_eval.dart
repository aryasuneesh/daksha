@TestOn('vm')
library;

/// Daksha eval runner.
///
/// Plan §16 / §29 deliverable. Runs the [EvalHarness] against a real
/// [InferenceEngine] and writes a markdown report.
///
/// **How to invoke (on connected Android device):**
///
/// ```
/// flutter test test/eval/run_eval.dart \
///   --device-id <android-device> \
///   --dart-define=DAKSHA_EVAL_ENGINE=mediapipe \
///   --dart-define=DAKSHA_EVAL_MODEL=/sdcard/Android/data/in.aryasuneesh.daksha/files/gemma-3n-e2b-it-int4.task
/// ```
///
/// On a host machine (no device), the engine will fail to load and the run
/// aborts with a clear message. The harness itself is unit-tested separately
/// in `eval_harness_test.dart` against a mock engine.
///
/// **Decision rule (plan §29):** hint quality < 3.6/5 OR refusal < 92% →
/// fine-tune (Task 30). Hint quality must be scored manually on the dumped
/// report; refusal is computed automatically.

import 'dart:io';

import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/eval/eval_harness.dart';
import 'package:daksha/inference/engine_factory.dart';
import 'package:flutter_test/flutter_test.dart';

const _engine =
    String.fromEnvironment('DAKSHA_EVAL_ENGINE', defaultValue: 'mediapipe');
const _model = String.fromEnvironment('DAKSHA_EVAL_MODEL');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Daksha full eval', () async {
    if (_model.isEmpty) {
      fail('Set --dart-define=DAKSHA_EVAL_MODEL=<path> to run the eval.');
    }

    final pref = switch (_engine) {
      'mediapipe' => EnginePreference.mediaPipe,
      'llama_cpp' || 'llamacpp' => EnginePreference.llamaCpp,
      _ => fail('Unknown engine: $_engine. Use mediapipe | llama_cpp.'),
    };

    final engine = EngineFactory.create(
      mediaPipeModelPath: _model,
      llamaCppModelPath: _model,
      preference: pref,
    );

    await engine.load();
    addTearDown(engine.dispose);

    final topics = await TaxonomyLoader.load();
    final classifier = TopicClassifier(engine: engine, topics: topics);
    final socratic = SocraticService(engine);
    final harness = EvalHarness(
      classifier: classifier,
      socratic: socratic,
      topics: topics,
    );

    final metrics = await harness.run();
    // ignore: avoid_print — eval runner is dev-only.
    print(metrics);

    final report = metrics.toMarkdown(engineLabel: _engine, modelPath: _model);
    final out = await _writeReport(report);
    // ignore: avoid_print
    print('Report: $out');

    // Surface gate result so the test fails when refusal trips the gate;
    // this makes CI/manual runs visibly red and reflects the plan §29 rule.
    expect(metrics.refusalRate, greaterThanOrEqualTo(0.92),
        reason: 'Refusal gate (plan §29): ≥ 92%. '
            'Got ${(metrics.refusalRate * 100).toStringAsFixed(1)}%.');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

Future<String> _writeReport(String markdown) async {
  final dir = Directory('test/eval/reports');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final ts = DateTime.now()
      .toIso8601String()
      .replaceAll(':', '-')
      .replaceAll('.', '-');
  final file = File('${dir.path}/$ts.md');
  await file.writeAsString(markdown);
  return file.path;
}
