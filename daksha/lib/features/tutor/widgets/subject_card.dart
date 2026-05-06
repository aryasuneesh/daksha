import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/tutor/widgets/mastery_ring.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.topicLine,
    required this.progress,
    required this.dueCount,
    this.onTap,
  });

  final String subject;
  final String topicLine;
  final double progress;
  final int dueCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DT.md),
        decoration: BoxDecoration(
          color: DT.elev1,
          borderRadius: BorderRadius.circular(DT.radius),
          border: Border.all(color: DT.outline, width: DT.bwCard),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ring shows mastery progress; icon identifies the subject.
            Stack(
              alignment: Alignment.center,
              children: [
                MasteryRing(
                  diameter: 44,
                  progress: progress,
                  color: DT.primary,
                ),
                Icon(
                  _iconForSubject(subject),
                  size: 20,
                  color: DT.primary,
                ),
              ],
            ),
            const SizedBox(height: DT.sm),
            Text(
              subject,
              style: DakshaTypography.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              topicLine,
              style: DakshaTypography.caption.copyWith(color: DT.muted),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (dueCount > 0) ...[
              const SizedBox(height: DT.xs),
              _DueBadge(dueCount: dueCount),
            ],
          ],
        ),
      ),
    );
  }
}

/// Maps a subject name to a representative Material icon.
IconData _iconForSubject(String subject) {
  return switch (subject.toLowerCase()) {
    'math' || 'mathematics' || 'maths' => Icons.calculate_outlined,
    'physics'                           => Icons.bolt_outlined,
    'chemistry'                         => Icons.science_outlined,
    'biology'                           => Icons.eco_outlined,
    'history' || 'social studies'       => Icons.history_edu_outlined,
    'geography'                         => Icons.public_outlined,
    'english' || 'language' || 'hindi'  => Icons.menu_book_outlined,
    'computer' || 'cs' || 'computers'   => Icons.computer_outlined,
    _                                   => Icons.auto_awesome_outlined,
  };
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.dueCount});
  final int dueCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: DT.amberBg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: DT.amber, width: DT.bwCard),
      ),
      child: Text(
        '$dueCount',
        style: DakshaTypography.caption.copyWith(color: DT.amber),
      ),
    );
  }
}
