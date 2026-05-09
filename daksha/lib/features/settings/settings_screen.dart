import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/app/locale_provider.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/common/language_toggle.dart';

/// Runtime settings: language, walkthrough replay, about. Reachable via the
/// gear icon in [HomeTopBar]. Locale changes here flip the whole app
/// without restart because [DakshaApp] watches [localeProvider].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final selected = _toAppLanguage(locale);

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: AppBar(
        backgroundColor: DT.bg,
        foregroundColor: DT.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          tooltip: l.back,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(l.settings, style: DakshaTypography.headingMd),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: DT.contentPad,
          vertical: DT.lg,
        ),
        children: [
          _SectionLabel(text: l.language),
          const SizedBox(height: DT.sm),
          StandardCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _languageLabel(l, selected),
                    style: DakshaTypography.body,
                  ),
                ),
                LanguageToggle(
                  selected: selected,
                  onChanged: (lang) {
                    ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(lang.name));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: DT.lg),
          _SectionLabel(text: l.replayTutorial),
          const SizedBox(height: DT.sm),
          StandardCard(
            child: InkWell(
              onTap: () async {
                // Clear the persisted "onboarding completed" flag, then bounce
                // back to home — HomeScreen's post-frame check sees the flag
                // is false and re-fires the spotlight tour.
                await ref
                    .read(onboardingCompletedProvider.notifier)
                    .reset();
                if (!context.mounted) return;
                context.go('/');
              },
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline, color: DT.muted),
                  const SizedBox(width: DT.sm),
                  Expanded(
                    child: Text(l.replayTutorial, style: DakshaTypography.body),
                  ),
                  const Icon(Icons.chevron_right, color: DT.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: DT.lg),
          _SectionLabel(text: l.aboutDaksha),
          const SizedBox(height: DT.sm),
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.appTitle,
                  style: DakshaTypography.headingMd,
                ),
                const SizedBox(height: DT.xs),
                Text(
                  l.aboutBody,
                  style: DakshaTypography.body.copyWith(color: DT.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: DT.bottomSafe),
        ],
      ),
    );
  }

  static AppLanguage _toAppLanguage(Locale? locale) {
    return switch (locale?.languageCode) {
      'hi' => AppLanguage.hi,
      'ml' => AppLanguage.ml,
      _ => AppLanguage.en,
    };
  }

  static String _languageLabel(AppLocalizations l, AppLanguage lang) {
    return switch (lang) {
      AppLanguage.en => l.english,
      AppLanguage.hi => l.hindi,
      AppLanguage.ml => l.malayalam,
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: DT.xs),
      child: Text(
        text.toUpperCase(),
        style: DakshaTypography.caption.copyWith(
          color: DT.muted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
