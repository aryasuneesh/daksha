import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/tutor/widgets/subject_grid_home.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(problemCountProvider);

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: const HomeTopBar(streakDays: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DT.contentPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DT.lg),
            Text(
              'Good morning',
              style: DakshaTypography.display.copyWith(color: DT.textStrong),
            ),
            const SizedBox(height: DT.xs),
            Text(
              '0 due · 0-day streak',
              style: DakshaTypography.sm.copyWith(color: DT.muted),
            ),
            const SizedBox(height: DT.lg),
            const SubjectGridHome(),
            const SizedBox(height: DT.lg),
            ElevatedCard(
              child: Row(
                children: [
                  Expanded(
                    child: DakshaTextButton(
                      label: '📷 Photo',
                      onPressed: () => context.go('/capture'),
                    ),
                  ),
                  Expanded(
                    child: DakshaTextButton(
                      label: '✏ Type',
                      onPressed: () => context.go('/capture'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DT.bottomSafe),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: count > 0 ? 'View history ($count)' : 'View history',
            onPressed: () => context.go('/history'),
          ),
        ],
      ),
    );
  }
}
