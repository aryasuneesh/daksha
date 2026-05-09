import 'dart:convert';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/inference/gbnf_compiler.dart';
import 'package:daksha/domain/taxonomy.dart';

class ClassificationResult {
  final Topic topic;

  const ClassificationResult({required this.topic});
}

class TopicClassifier {
  final InferenceEngine _engine;
  final List<Topic> _topics;

  TopicClassifier({required InferenceEngine engine, required List<Topic> topics})
      : _engine = engine,
        _topics = topics;

  // The MediaPipe LiteRT-LM backend (used in production) does NOT enforce GBNF
  // grammars — see socratic_tools.dart for the full note. The grammar is only
  // a hint for the LlamaCpp fallback path; the prompt itself is what makes the
  // model produce parseable JSON, so we keep the prompt simple, give labels,
  // and show two worked examples.
  static const _schema = {
    'type': 'object',
    'properties': {
      'subject': {'type': 'string'},
      'slug': {'type': 'string'},
    },
  };

  Future<ClassificationResult?> classify(String problemText) async {
    final grammar = GbnfCompiler.compile(_schema);

    // Group topics under their subject and show display names so the model
    // sees human-readable labels, not just dash-separated slugs. Earlier
    // versions sent only `subject/slug` pairs — small Gemma models then
    // defaulted to the closest-looking slug, usually misclassifying.
    final buf = StringBuffer();
    final bySubject = <String, List<Topic>>{};
    for (final t in _topics) {
      bySubject.putIfAbsent(t.subject, () => []).add(t);
    }
    for (final entry in bySubject.entries) {
      buf.writeln('${entry.key}:');
      for (final t in entry.value) {
        buf.writeln('  - ${t.slug} → ${t.displayName}');
      }
    }

    final prompt = '''You classify a school problem into one subject and one topic.

Available subjects and topics:
${buf.toString().trim()}

Pick the single best slug from the list above. Use the exact slug as written.
Choose the subject that the slug belongs to.

Examples:

Problem: Solve for x: 2x + 3 = 11
{"subject": "math", "slug": "linear-equations"}

Problem: A car travels 60 km in 2 hours. What is its average speed?
{"subject": "physics", "slug": "motion"}

Problem: What is the chemical formula for water?
{"subject": "chemistry", "slug": "elements-compounds"}

Now classify this problem.

Problem: $problemText
''';

    final request = InferenceRequest(
      prompt: prompt,
      maxTokens: 64,
      temperature: 0.1, // low temp — this is a categorical pick, not creative
      grammarBnf: grammar,
    );

    final response = await _engine.generate(request);

    return response.when(
      success: (text, _) => _parseResult(text),
      failure: (error) => null,
    );
  }

  ClassificationResult? _parseResult(String raw) {
    try {
      final json = jsonDecode(_extractJson(raw)) as Map<String, dynamic>;
      final subject = (json['subject'] as String?)?.trim().toLowerCase();
      final slug = (json['slug'] as String?)?.trim().toLowerCase();

      if (subject == null || slug == null) return null;

      // Resolve by (subject, slug) pair so two slugs with the same name in
      // different subjects don't collide.
      final topic = _topics.firstWhere(
        (t) => t.subject == subject && t.slug == slug,
        orElse: () => const Topic(subject: '', slug: '', displayName: ''),
      );
      if (topic.subject.isEmpty) return null;

      return ClassificationResult(topic: topic);
    } catch (_) {
      return null;
    }
  }

  /// Extracts the first JSON object from free-form model output.
  /// Strips markdown fences and any preamble before the opening brace.
  static String _extractJson(String raw) {
    final stripped = raw
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();
    final start = stripped.indexOf('{');
    final end = stripped.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return raw;
    return stripped.substring(start, end + 1);
  }
}
