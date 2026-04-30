import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/features/tutor/widgets/subject_card.dart';

class SubjectGridHome extends StatelessWidget {
  const SubjectGridHome({super.key});

  static const _subjects = [
    'Math',
    'Physics',
    'Chemistry',
    'Biology',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: DT.sm,
      crossAxisSpacing: DT.sm,
      childAspectRatio: 1.2,
      children: _subjects
          .map(
            (subject) => SubjectCard(
              subject: subject,
              topicLine: 'No recent activity',
              progress: 0.0,
              dueCount: 0,
            ),
          )
          .toList(),
    );
  }
}
