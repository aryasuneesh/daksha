import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:daksha/app/locale_provider.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/tutor/widgets/subject_grid_home.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Anchor keys for the four spotlight stops. Held in state so the same
  // GlobalKey instances survive rebuilds (required for the package's
  // findRenderBox lookups to resolve once the post-frame callback fires).
  final GlobalKey _subjectsKey = GlobalKey();
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _streakKey = GlobalKey();

  // Latch so the post-frame scheduler only ever attempts to fire one tour
  // per HomeScreen lifetime — even if the engine async-state cycles, we
  // don't want a second TutorialCoachMark stacking on top of the first.
  bool _tourScheduled = false;
  TutorialCoachMark? _tour;

  @override
  void dispose() {
    _tour?.finish();
    super.dispose();
  }

  void _maybeStartTour() {
    if (_tourScheduled) return;
    final completed = ref.read(onboardingCompletedProvider);
    if (completed) return;
    _tourScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Bail out cleanly if any anchor failed to attach — happens in widget
      // tests that don't pump a full layout. Marking complete in that case
      // would be wrong, so we simply skip.
      final anchors = [_subjectsKey, _captureKey, _historyKey, _streakKey];
      final allAttached = anchors.every(
        (k) => k.currentContext != null,
      );
      if (!allAttached) return;
      _startTour();
    });
  }

  void _startTour() {
    final l = AppLocalizations.of(context)!;
    final targets = <TargetFocus>[
      _buildTarget(
        identify: 'subjects',
        keyTarget: _subjectsKey,
        title: l.tourSubjectsTitle,
        body: l.tourSubjectsBody,
        align: ContentAlign.bottom,
      ),
      _buildTarget(
        identify: 'capture',
        keyTarget: _captureKey,
        title: l.tourCaptureTitle,
        body: l.tourCaptureBody,
        align: ContentAlign.top,
      ),
      _buildTarget(
        identify: 'history',
        keyTarget: _historyKey,
        title: l.tourHistoryTitle,
        body: l.tourHistoryBody,
        align: ContentAlign.top,
      ),
      _buildTarget(
        identify: 'streak',
        keyTarget: _streakKey,
        title: l.tourStreakTitle,
        body: l.tourStreakBody,
        align: ContentAlign.bottom,
      ),
    ];

    _tour = TutorialCoachMark(
      targets: targets,
      colorShadow: DT.textStrong,
      opacityShadow: 0.85,
      paddingFocus: 8,
      hideSkip: false,
      textSkip: l.tourSkip,
      onFinish: _markComplete,
      onSkip: () {
        _markComplete();
        return true;
      },
    )..show(context: context);
  }

  void _markComplete() {
    ref.read(onboardingCompletedProvider.notifier).markComplete();
  }

  TargetFocus _buildTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String title,
    required String body,
    required ContentAlign align,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: ShapeLightFocus.RRect,
      radius: DT.radiusBtn,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DakshaTypography.headingMd.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DT.xs),
                Text(
                  body,
                  style: DakshaTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(problemCountProvider);
    final streak = ref.watch(streakDaysProvider);
    // Pre-warm the inference engine on home so the first /problem visit
    // does not block on a ~2.26 GB GPU/OpenCL load. The provider is cached
    // for the rest of the app lifetime.
    final engineAsync = ref.watch(engineProvider);
    final engineReady = engineAsync.hasValue;
    final engineError = engineAsync.error;

    // Only schedule the walkthrough once the engine is warm — firing while
    // the action buttons are still disabled would put a spotlight on a
    // greyed-out CTA, which would be confusing.
    if (engineReady) {
      _maybeStartTour();
    }

    void goCapture() {
      if (!engineReady) return;
      context.push('/capture');
    }

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: HomeTopBar(
        streakDays: streak.value ?? 0,
        streakKey: _streakKey,
        onSettingsTap: () => context.push('/settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DT.contentPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DT.lg),
            Text(
              l.goodMorning,
              style: DakshaTypography.display.copyWith(color: DT.textStrong),
            ),
            const SizedBox(height: DT.xs),
            _StatusLine(
              count: count,
              engineReady: engineReady,
              engineError: engineError,
            ),
            const SizedBox(height: DT.lg),
            SubjectGridHome(key: _subjectsKey),
            const SizedBox(height: DT.lg),
            ElevatedCard(
              key: _captureKey,
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
            key: _historyKey,
            label: count > 0 ? l.viewHistoryWithCount(count) : l.viewHistory,
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
    final l = AppLocalizations.of(context)!;
    if (engineError != null) {
      return Text(
        l.engineFailed,
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
            l.warmingUp,
            style: DakshaTypography.sm.copyWith(color: DT.muted),
          ),
        ],
      );
    }
    return Text(
      l.problemsSolved(count),
      style: DakshaTypography.sm.copyWith(color: DT.muted),
    );
  }
}
