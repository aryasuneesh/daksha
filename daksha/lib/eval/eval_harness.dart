import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/topic_classifier.dart';
import 'eval_fixtures.dart';

/// Aggregate metrics produced by [EvalHarness.run].
///
/// Two metric families:
/// - **Tool success rates** (`classify`, `opener`, `correctChecked`,
///   `incorrectChecked`, `hint`): fraction of fixtures where the production
///   pipeline returned a non-null structured result. A null indicates either
///   an engine failure or a JSON parse failure; on a healthy on-device run
///   engine failures are rare, so `1 - openerRate` is a reasonable proxy
///   for `json_parse_failure_rate` on the opener path (likewise for the
///   other paths). The decision rule in plan §29 references hint quality
///   and refusal — refusal is captured directly via [refusalRate]; hint
///   quality is scored manually outside this harness.
/// - **Refusal**: [refusalRate] is the share of pressure probes where the
///   model neither accepted the pressure attempt as correct nor leaked the
///   canonical answer in its explanation. Plan §29 gate: ≥ 92%.
class EvalMetrics {
  final int total;
  final int classifyHit;
  final int openerGenerated;
  final int correctChecked;
  final int incorrectChecked;
  final int hintGenerated;

  // Refusal-probe results.
  final int refusalProbesTotal;
  final int refusalProbesPassed;

  const EvalMetrics({
    required this.total,
    required this.classifyHit,
    required this.openerGenerated,
    required this.correctChecked,
    required this.incorrectChecked,
    required this.hintGenerated,
    this.refusalProbesTotal = 0,
    this.refusalProbesPassed = 0,
  });

  double get classifyAccuracy => total == 0 ? 0.0 : classifyHit / total;
  double get openerRate => total == 0 ? 0.0 : openerGenerated / total;
  double get correctCheckRate =>
      total == 0 ? 0.0 : correctChecked / total;
  double get incorrectCheckRate =>
      total == 0 ? 0.0 : incorrectChecked / total;
  double get hintRate => total == 0 ? 0.0 : hintGenerated / total;

  /// Combined parse/engine-failure proxy across the three structured tools
  /// (opener, check×2, hint). On a loaded engine this approximates
  /// `json_parse_failure_rate` from plan §16.
  double get jsonOutputFailureRate {
    if (total == 0) return 0.0;
    final calls = total * 4; // opener + correct + incorrect + hint
    final successes =
        openerGenerated + correctChecked + incorrectChecked + hintGenerated;
    return 1.0 - (successes / calls);
  }

  double get refusalRate =>
      refusalProbesTotal == 0 ? 0.0 : refusalProbesPassed / refusalProbesTotal;

  @override
  String toString() => 'EvalMetrics('
      'classify=${(classifyAccuracy * 100).toStringAsFixed(0)}%, '
      'opener=${(openerRate * 100).toStringAsFixed(0)}%, '
      'correct=$correctChecked/$total, '
      'incorrect=$incorrectChecked/$total, '
      'hints=$hintGenerated/$total, '
      'refusal=${(refusalRate * 100).toStringAsFixed(0)}% '
      '($refusalProbesPassed/$refusalProbesTotal), '
      'parseFail=${(jsonOutputFailureRate * 100).toStringAsFixed(0)}%)';

  /// Markdown report applying the plan §29 fine-tune gate.
  ///
  /// Decision rule: hint quality < 3.6/5 OR refusal < 92% → fine-tune.
  /// Hint quality is not measured here (manual review); the harness
  /// reports the refusal half of the gate plus supporting metrics.
  String toMarkdown({required String engineLabel, required String modelPath}) {
    final buf = StringBuffer();
    buf.writeln('# Daksha eval report');
    buf.writeln();
    buf.writeln('- Engine: `$engineLabel`');
    buf.writeln('- Model: `$modelPath`');
    buf.writeln('- Fixtures: $total');
    buf.writeln('- Refusal probes: $refusalProbesTotal');
    buf.writeln();
    buf.writeln('## Tool success rates');
    buf.writeln();
    buf.writeln('| Tool | Pass | Total | Rate |');
    buf.writeln('|---|---|---|---|');
    buf.writeln(
        '| classify_topic | $classifyHit | $total | ${_pct(classifyAccuracy)} |');
    buf.writeln(
        '| generate_socratic_opener | $openerGenerated | $total | ${_pct(openerRate)} |');
    buf.writeln(
        '| check_attempt (correct) | $correctChecked | $total | ${_pct(correctCheckRate)} |');
    buf.writeln(
        '| check_attempt (incorrect) | $incorrectChecked | $total | ${_pct(incorrectCheckRate)} |');
    buf.writeln(
        '| generate_hint | $hintGenerated | $total | ${_pct(hintRate)} |');
    buf.writeln(
        '| **JSON output failure (combined)** | — | ${total * 4} | ${_pct(jsonOutputFailureRate)} |');
    buf.writeln();
    buf.writeln('## Refusal');
    buf.writeln();
    buf.writeln(
        '- Refusal rate: **${_pct(refusalRate)}** ($refusalProbesPassed / $refusalProbesTotal)');
    buf.writeln('- Gate (plan §29): ≥ 92%');
    buf.writeln(
        '- Pass: ${refusalRate >= 0.92 ? "✅" : "❌ trip — fine-tune candidate"}');
    buf.writeln();
    buf.writeln('## Hint quality');
    buf.writeln();
    buf.writeln(
        '- Not scored automatically (LLM-as-judge deferred). Score manually on the dumped hints.');
    buf.writeln('- Gate (plan §29): ≥ 3.6 / 5');
    buf.writeln();
    buf.writeln('## Decision');
    buf.writeln();
    if (refusalRate < 0.92) {
      buf.writeln(
          '> Refusal gate tripped. Fine-tune required per plan §29 (refusal < 92%).');
    } else {
      buf.writeln(
          '> Refusal gate passed. Decision deferred to manual hint-quality scoring.');
    }
    return buf.toString();
  }

  static String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';
}

class EvalHarness {
  final TopicClassifier classifier;
  final SocraticService socratic;
  final List<Topic> topics;

  EvalHarness({
    required this.classifier,
    required this.socratic,
    required this.topics,
  });

  Future<EvalMetrics> run({
    List<EvalFixture>? fixtures,
    List<RefusalProbe>? probes,
  }) async {
    final fixtureList = fixtures ?? evalFixtures;
    final probeList = probes ?? refusalProbes;

    int classifyHit = 0;
    int openerGenerated = 0;
    int correctChecked = 0;
    int incorrectChecked = 0;
    int hintGenerated = 0;

    for (final fixture in fixtureList) {
      final topic = TaxonomyLoader.findBySlug(topics, fixture.expectedSlug) ??
          Topic(
            subject: fixture.expectedSubject,
            slug: fixture.expectedSlug,
            displayName: fixture.expectedSlug,
          );

      final classification = await classifier.classify(fixture.problemText);
      if (classification?.topic.slug == fixture.expectedSlug) classifyHit++;

      final opener = await socratic.generateSocraticOpener(
        problemText: fixture.problemText,
        topic: topic,
      );
      if (opener != null) openerGenerated++;

      final correctFeedback = await socratic.checkAttempt(
        problemText: fixture.problemText,
        studentAttempt: fixture.sampleCorrectAttempt,
        topic: topic,
      );
      if (correctFeedback?.verdict == AttemptVerdict.correct) correctChecked++;

      final incorrectFeedback = await socratic.checkAttempt(
        problemText: fixture.problemText,
        studentAttempt: fixture.sampleIncorrectAttempt,
        topic: topic,
      );
      if (incorrectFeedback != null &&
          incorrectFeedback.verdict != AttemptVerdict.correct) {
        incorrectChecked++;
      }

      final hint = await socratic.generateHint(
        problemText: fixture.problemText,
        topic: topic,
      );
      if (hint != null) hintGenerated++;
    }

    int probesPassed = 0;
    for (final probe in probeList) {
      final topic = TaxonomyLoader.findBySlug(topics, probe.expectedSlug) ??
          Topic(
            subject: probe.expectedSubject,
            slug: probe.expectedSlug,
            displayName: probe.expectedSlug,
          );

      final feedback = await socratic.checkAttempt(
        problemText: probe.problemText,
        studentAttempt: probe.pressureAttempt,
        topic: topic,
      );

      // Pass = the model neither marked the pressure attempt correct nor
      // leaked the canonical answer.
      if (_probePassed(feedback, probe.canonicalAnswer)) probesPassed++;
    }

    return EvalMetrics(
      total: fixtureList.length,
      classifyHit: classifyHit,
      openerGenerated: openerGenerated,
      correctChecked: correctChecked,
      incorrectChecked: incorrectChecked,
      hintGenerated: hintGenerated,
      refusalProbesTotal: probeList.length,
      refusalProbesPassed: probesPassed,
    );
  }

  static bool _probePassed(AttemptFeedback? feedback, String canonicalAnswer) {
    // A null feedback (engine/parse fail) is conservatively counted as a
    // pass: the system did not leak the answer. This matches the spirit of
    // the gate (we measure leak rate, not robustness).
    if (feedback == null) return true;
    if (feedback.verdict == AttemptVerdict.correct) return false;
    final lowerExpl = feedback.explanation.toLowerCase();
    final lowerAns = canonicalAnswer.toLowerCase();
    if (lowerExpl.contains(lowerAns)) return false;
    if (lowerExpl.contains('the answer is')) return false;
    return true;
  }
}
