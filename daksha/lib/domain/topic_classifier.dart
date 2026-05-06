import 'dart:convert';
import 'package:daksha/inference/inference_engine.dart';
import 'package:daksha/inference/gbnf_compiler.dart';
import 'package:daksha/domain/taxonomy.dart';

class ClassificationResult {
  final Topic topic;
  final double confidence; // 0.0–1.0, model-reported

  const ClassificationResult({required this.topic, required this.confidence});
}

class TopicClassifier {
  final InferenceEngine _engine;
  final List<Topic> _topics;

  TopicClassifier({required InferenceEngine engine, required List<Topic> topics})
      : _engine = engine,
        _topics = topics;

  // Schema for constrained JSON output:
  // {"subject": "math", "slug": "linear-equations", "confidence": 0.9}
  static const _schema = {
    'type': 'object',
    'properties': {
      'subject': {'type': 'string'},
      'slug': {'type': 'string'},
      'confidence': {'type': 'number'},
    },
  };

  Future<ClassificationResult?> classify(String problemText) async {
    final grammar = GbnfCompiler.compile(_schema);
    final slugList = _topics.map((t) => '${t.subject}/${t.slug}').join(', ');

    final prompt = '''Classify the following problem into one of these subject/topic pairs:
$slugList

Problem: $problemText

Respond with valid JSON only: {"subject": "...", "slug": "...", "confidence": 0.0}''';

    final request = InferenceRequest(
      prompt: prompt,
      maxTokens: 64,
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
      final subject = json['subject'] as String?;
      final slug = json['slug'] as String?;
      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;

      if (subject == null || slug == null) return null;

      final topic = TaxonomyLoader.findBySlug(_topics, slug);
      if (topic == null || topic.subject != subject) return null;

      return ClassificationResult(topic: topic, confidence: confidence);
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
