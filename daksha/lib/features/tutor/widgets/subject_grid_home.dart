import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/features/tutor/widgets/subject_card.dart';
import 'package:daksha/storage/database/app_database.dart';

class SubjectGridHome extends ConsumerWidget {
  const SubjectGridHome({super.key});

  static const _subjects = [
    'Math',
    'Physics',
    'Chemistry',
    'Biology',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(problemsProvider).value ?? const <Problem>[];
    final topics = ref.watch(taxonomyProvider).value ?? const <Topic>[];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: DT.sm,
      crossAxisSpacing: DT.sm,
      childAspectRatio: 1.2,
      children: _subjects.map((subject) {
        final key = subject.toLowerCase();
        // problemsProvider already orders by capturedAt desc, so the first
        // match is the most recent problem for this subject.
        final latest = problems.cast<Problem?>().firstWhere(
              (p) => p!.subject.toLowerCase() == key,
              orElse: () => null,
            );
        final solvedCount = problems
            .where((p) => p.subject.toLowerCase() == key && p.solved)
            .length;
        final totalForSubject =
            problems.where((p) => p.subject.toLowerCase() == key).length;
        return SubjectCard(
          subject: subject,
          topicLine: latest == null
              ? 'No recent activity'
              : _topicDisplay(topics, latest.subject, latest.topic),
          progress: totalForSubject == 0 ? 0.0 : solvedCount / totalForSubject,
          dueCount: 0,
        );
      }).toList(),
    );
  }
}

/// Resolves a (subject, slug) pair to its human-readable topic name.
/// Falls back to the slug with dashes replaced by spaces if the taxonomy
/// hasn't loaded yet or the slug is unknown — keeps the UI populated rather
/// than reverting to "No recent activity" while taxonomy resolves.
String _topicDisplay(List<Topic> topics, String subject, String slug) {
  for (final t in topics) {
    if (t.subject == subject && t.slug == slug) return t.displayName;
  }
  return slug.replaceAll('-', ' ');
}
