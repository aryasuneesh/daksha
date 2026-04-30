import 'dart:convert';
import 'package:flutter/services.dart';

class Topic {
  final String subject;
  final String slug;
  final String displayName;

  const Topic({
    required this.subject,
    required this.slug,
    required this.displayName,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        subject: json['subject'] as String,
        slug: json['slug'] as String,
        displayName: json['displayName'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is Topic && other.subject == subject && other.slug == slug;

  @override
  int get hashCode => Object.hash(subject, slug);
}

class TaxonomyLoader {
  static const _assetPath = 'assets/taxonomy/topics.json';

  static Future<List<Topic>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<Topic> filterBySubject(List<Topic> topics, String subject) =>
      topics.where((t) => t.subject == subject).toList();

  static Topic? findBySlug(List<Topic> topics, String slug) {
    for (final t in topics) {
      if (t.slug == slug) return t;
    }
    return null;
  }
}
