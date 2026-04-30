import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/tutor/widgets/mastery_ring.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DT.contentPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DT.lg),
            const Text('Subjects', style: DakshaTypography.headingMd),
            const SizedBox(height: DT.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: DT.sm,
              mainAxisSpacing: DT.sm,
              children: const [
                _DashboardSubjectCard(
                  subject: 'Math',
                  ringColor: DT.primary,
                  progress: 0.0,
                ),
                _DashboardSubjectCard(
                  subject: 'Physics',
                  ringColor: DT.accent,
                  progress: 0.0,
                ),
                _DashboardSubjectCard(
                  subject: 'Chemistry',
                  ringColor: DT.caution,
                  progress: 0.0,
                ),
                _DashboardSubjectCard(
                  subject: 'Biology',
                  ringColor: DT.muted,
                  progress: 0.0,
                ),
              ],
            ),
            const SizedBox(height: DT.lg),
            const Divider(color: DT.outline),
            const SizedBox(height: DT.sm),
            const Text(
              'Needs work',
              style: DakshaTypography.headingMd,
            ),
            const SizedBox(height: DT.sm),
            const _WeakTopicCard(topicName: 'Quadratic equations'),
            const SizedBox(height: DT.sm),
            const _WeakTopicCard(topicName: 'Newton\'s laws'),
            const SizedBox(height: DT.bottomSafe),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: 'Practice weakest now',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _DashboardSubjectCard extends StatelessWidget {
  const _DashboardSubjectCard({
    required this.subject,
    required this.ringColor,
    required this.progress,
  });

  final String subject;
  final Color ringColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DT.md),
      decoration: BoxDecoration(
        color: DT.elev1,
        borderRadius: BorderRadius.circular(DT.radius),
        border: Border.all(color: DT.outline, width: DT.bwCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MasteryRing(
            diameter: 52,
            progress: progress,
            color: ringColor,
          ),
          const SizedBox(height: DT.sm),
          Text(
            subject,
            style: DakshaTypography.body.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeakTopicCard extends StatelessWidget {
  const _WeakTopicCard({required this.topicName});

  final String topicName;

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      child: Row(
        children: [
          const Text('●', style: TextStyle(color: DT.caution)),
          const SizedBox(width: DT.sm),
          Expanded(
            child: Text(topicName, style: DakshaTypography.body),
          ),
          DakshaTextButton(label: 'Practice →', onPressed: () {}),
        ],
      ),
    );
  }
}
