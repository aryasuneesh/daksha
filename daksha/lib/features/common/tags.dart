import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';

/// "math · linear equations" pill — used in TopBar and problem header.
class SubjectTag extends StatelessWidget {
  const SubjectTag({super.key, required this.subject, required this.topic});

  final String subject;
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: DT.elev2,
        borderRadius: BorderRadius.circular(DT.radiusBtn),
        border: Border.all(color: DT.outline, width: DT.bwCard),
      ),
      child: Text(
        topic.isNotEmpty ? '$subject · $topic' : subject,
        style: DakshaTypography.caption.copyWith(color: DT.muted),
      ),
    );
  }
}

/// Accent pill showing SRS due count. Only rendered when [count] > 0.
class DueBadge extends StatelessWidget {
  const DueBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: DT.accent,
        borderRadius: BorderRadius.circular(DT.radiusBtn),
      ),
      child: Text(
        '$count due',
        style: DakshaTypography.caption.copyWith(
          color: DT.primaryFg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
