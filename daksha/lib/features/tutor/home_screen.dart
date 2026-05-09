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
    // Pre-warm the inference engine on home so the first /problem visit
    // does not block on a ~2.26 GB GPU/OpenCL load. The provider is cached
    // for the rest of the app lifetime.
    final engineAsync = ref.watch(engineProvider);
    final engineReady = engineAsync.hasValue;
    final engineError = engineAsync.error;

    void goCapture() {
      if (!engineReady) return;
      context.push('/capture');
    }

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
            _StatusLine(
              count: count,
              engineReady: engineReady,
              engineError: engineError,
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
                      onPressed: engineReady ? goCapture : null,
                    ),
                  ),
                  Expanded(
                    child: DakshaTextButton(
                      label: '✏ Type',
                      onPressed: engineReady ? goCapture : null,
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
            onPressed: () => context.push('/history'),
          ),
        ],
      ),
    );
  }
}

/// Replaces the hardcoded "0 due · 0-day streak" line with a real, contextual
/// status: shows engine warm-up state and surfaces load errors so the user
/// understands why the action buttons are temporarily disabled instead of
/// tapping into a frozen UI.
class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.count,
    required this.engineReady,
    required this.engineError,
  });

  final int count;
  final bool engineReady;
  final Object? engineError;

  @override
  Widget build(BuildContext context) {
    if (engineError != null) {
      return Text(
        'Daksha could not start — close other apps and reopen.',
        style: DakshaTypography.sm.copyWith(color: DT.error),
      );
    }
    if (!engineReady) {
      return Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: DT.sm),
          Text(
            'Warming up Daksha…',
            style: DakshaTypography.sm.copyWith(color: DT.muted),
          ),
        ],
      );
    }
    final solvedSuffix = count == 1 ? '' : 's';
    return Text(
      '$count problem$solvedSuffix solved',
      style: DakshaTypography.sm.copyWith(color: DT.muted),
    );
  }
}
