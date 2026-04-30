import 'package:daksha/domain/topic_classifier.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'eval_fixtures.dart';

class EvalMetrics {
  final int total;
  final int classifyHit;
  final int openerGenerated;
  final int correctChecked;
  final int incorrectChecked;
  final int hintGenerated;

  const EvalMetrics({
    required this.total,
    required this.classifyHit,
    required this.openerGenerated,
    required this.correctChecked,
    required this.incorrectChecked,
    required this.hintGenerated,
  });

  double get classifyAccuracy => total == 0 ? 0.0 : classifyHit / total;
  double get openerRate => total == 0 ? 0.0 : openerGenerated / total;

  @override
  String toString() => 'EvalMetrics('
      'classify=${(classifyAccuracy * 100).toStringAsFixed(0)}%, '
      'opener=${(openerRate * 100).toStringAsFixed(0)}%, '
      'correct=$correctChecked/$total, '
      'incorrect=$incorrectChecked/$total, '
      'hints=$hintGenerated/$total)';
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

  Future<EvalMetrics> run({List<EvalFixture>? fixtures}) async {
    final fixtureList = fixtures ?? evalFixtures;

    int classifyHit = 0;
    int openerGenerated = 0;
    int correctChecked = 0;
    int incorrectChecked = 0;
    int hintGenerated = 0;

    for (final fixture in fixtureList) {
      // 1. Classify
      final classification = await classifier.classify(fixture.problemText);
      final topic = classification?.topic ??
          TaxonomyLoader.findBySlug(topics, fixture.expectedSlug) ??
          Topic(
            subject: fixture.expectedSubject,
            slug: fixture.expectedSlug,
            displayName: fixture.expectedSlug,
          );

      if (classification?.topic.slug == fixture.expectedSlug) classifyHit++;

      // 2. Generate opener
      final opener = await socratic.generateSocraticOpener(
        problemText: fixture.problemText,
        topic: topic,
      );
      if (opener != null) openerGenerated++;

      // 3. Check correct attempt
      final correctFeedback = await socratic.checkAttempt(
        problemText: fixture.problemText,
        studentAttempt: fixture.sampleCorrectAttempt,
        topic: topic,
      );
      if (correctFeedback?.verdict == AttemptVerdict.correct) correctChecked++;

      // 4. Check incorrect attempt
      final incorrectFeedback = await socratic.checkAttempt(
        problemText: fixture.problemText,
        studentAttempt: fixture.sampleIncorrectAttempt,
        topic: topic,
      );
      if (incorrectFeedback?.verdict != AttemptVerdict.correct &&
          incorrectFeedback != null) {
        incorrectChecked++;
      }

      // 5. Generate hint
      final hint = await socratic.generateHint(
        problemText: fixture.problemText,
        topic: topic,
      );
      if (hint != null) hintGenerated++;
    }

    return EvalMetrics(
      total: fixtureList.length,
      classifyHit: classifyHit,
      openerGenerated: openerGenerated,
      correctChecked: correctChecked,
      incorrectChecked: incorrectChecked,
      hintGenerated: hintGenerated,
    );
  }
}
