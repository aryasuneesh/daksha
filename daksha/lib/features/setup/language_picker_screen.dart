import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daksha/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/app/locale_provider.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';

/// First-launch language picker. Shown after the model download finishes
/// when no locale has been persisted yet. Selection is required — there is
/// no skip button (the planner specified explicit selection so we never
/// guess between the three target languages).
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  static const _options = <_LangOption>[
    _LangOption(code: 'en', native: 'English', script: null),
    _LangOption(code: 'hi', native: 'हिन्दी', script: 'NotoSansDevanagari'),
    _LangOption(code: 'ml', native: 'മലയാളം', script: 'NotoSansMalayalam'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Strings here intentionally use AppLocalizations — on first launch this
    // resolves to device locale (en/hi/ml if matched, else en fallback) so
    // the picker itself reads naturally before the user has chosen.
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DT.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DT.contentPad,
            vertical: DT.contentPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DT.lg * 2),
              Text(
                l.chooseLanguage,
                style: DakshaTypography.display.copyWith(color: DT.textStrong),
              ),
              const SizedBox(height: DT.sm),
              Text(
                l.chooseLanguageSubtitle,
                style: DakshaTypography.body.copyWith(color: DT.muted),
              ),
              const SizedBox(height: DT.lg * 2),
              for (final opt in _options) ...[
                _LangCard(
                  option: opt,
                  onTap: () async {
                    await ref
                        .read(localeProvider.notifier)
                        .setLocale(Locale(opt.code));
                    if (context.mounted) context.go('/');
                  },
                ),
                const SizedBox(height: DT.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LangOption {
  const _LangOption({required this.code, required this.native, this.script});
  final String code;
  final String native;
  final String? script;
}

class _LangCard extends StatelessWidget {
  const _LangCard({required this.option, required this.onTap});
  final _LangOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DT.cardHPad,
          vertical: DT.lg * 1.2,
        ),
        decoration: BoxDecoration(
          color: DT.elev1,
          borderRadius: BorderRadius.circular(DT.radius),
          border: Border.all(color: DT.outline, width: DT.bwCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.native,
                style: DakshaTypography.headingLg.copyWith(
                  color: DT.textStrong,
                  fontFamily: option.script,
                  fontFamilyFallback: const ['DMSans'],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: DT.muted),
          ],
        ),
      ),
    );
  }
}
