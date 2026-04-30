import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';

enum AppLanguage { en, hi, ml }

extension AppLanguageLabel on AppLanguage {
  String get label => switch (this) {
        AppLanguage.en => 'EN',
        AppLanguage.hi => 'HI',
        AppLanguage.ml => 'ML',
      };
}

/// Segmented pill toggle for EN / HI / ML language switching.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DT.radiusBtn),
        border: Border.all(color: DT.outline, width: DT.bwCard),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DT.radiusBtn - 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final active = lang == selected;
            return GestureDetector(
              onTap: () => onChanged(lang),
              child: Container(
                constraints: const BoxConstraints(minWidth: DT.minTouch, minHeight: DT.minTouch),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                color: active ? DT.primary : Colors.transparent,
                child: Center(
                  child: Text(
                    lang.label,
                    style: DakshaTypography.caption.copyWith(
                      fontSize: 11,
                      color: active ? DT.primaryFg : DT.muted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
