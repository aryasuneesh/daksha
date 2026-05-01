import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';
import 'language_toggle.dart';
import 'tags.dart';

/// Home variant: दक्ष logo left, streak + avatar right.
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({
    super.key,
    required this.streakDays,
    this.onAvatarTap,
  });

  final int streakDays;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    return _TopBarShell(
      left: Text(
        'दक्ष',
        style: DakshaTypography.headingMd.copyWith(
          fontFamily: 'NotoSansDevanagari',
          fontFamilyFallback: const ['DMSans'],
          color: DT.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      right: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥$streakDays',
            style: DakshaTypography.sm.copyWith(color: DT.muted),
          ),
          const SizedBox(width: DT.sm),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: DT.elev2,
                shape: BoxShape.circle,
                border: Border.all(color: DT.outline),
              ),
              alignment: Alignment.center,
              child: Text(
                'द',
                style: DakshaTypography.caption.copyWith(
                  color: DT.muted,
                  fontFamily: 'NotoSansDevanagari',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Problem screen variant: back left, subject tag centre, close right.
class ProblemTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ProblemTopBar({
    super.key,
    required this.subject,
    required this.topic,
    required this.onBack,
    required this.onClose,
  });

  final String subject;
  final String topic;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    return _TopBarShell(
      left: _BackButton(onTap: onBack),
      center: SubjectTag(subject: subject, topic: topic),
      right: _CloseButton(onTap: onClose),
    );
  }
}

/// Capture screen variant: back left, Photo/Type toggle centre, close right.
class CaptureTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CaptureTopBar({
    super.key,
    required this.photoMode,
    required this.onToggle,
    required this.onBack,
    required this.onClose,
  });

  final bool photoMode;
  final ValueChanged<bool> onToggle;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    return _TopBarShell(
      left: _BackButton(onTap: onBack),
      center: _CaptureToggle(photoMode: photoMode, onToggle: onToggle),
      right: _CloseButton(onTap: onClose),
    );
  }
}

/// Parent shell variant: back + title left, language toggle right.
class ParentTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ParentTopBar({
    super.key,
    required this.title,
    required this.language,
    required this.onLanguageChanged,
    required this.onBack,
  });

  final String title;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    return _TopBarShell(
      left: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BackButton(onTap: onBack),
          const SizedBox(width: DT.sm),
          Text(title, style: DakshaTypography.headingMd),
        ],
      ),
      right: LanguageToggle(selected: language, onChanged: onLanguageChanged),
    );
  }
}

// ── Internal helpers ─────────────────────────────────────────────────────────

class _TopBarShell extends StatelessWidget implements PreferredSizeWidget {
  const _TopBarShell({required this.left, this.center, this.right});

  final Widget left;
  final Widget? center;
  final Widget? right;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      // No fixed height — let Scaffold inflate this for status-bar space.
      // topPadding pushes content below the status bar when Scaffold renders
      // edge-to-edge (Flutter 3.22+ / Android 15+).
      padding: EdgeInsets.fromLTRB(DT.lg, topPadding, DT.lg, 0),
      decoration: const BoxDecoration(
        color: DT.bg,
        border: Border(bottom: BorderSide(color: DT.outline, width: 1)),
      ),
      child: SizedBox(
        height: DT.topBarH,
        child: Row(
          children: [
            left,
            if (center != null) ...[
              const Spacer(),
              center!,
              const Spacer(),
            ] else
              const Spacer(),
            if (right != null) right!,
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: DT.minTouch,
        height: DT.minTouch,
        child: Center(
          child: Text(
            '◀',
            style: DakshaTypography.body.copyWith(
              fontSize: 18,
              color: DT.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: DT.minTouch,
        height: DT.minTouch,
        child: Center(
          child: Text(
            '✕',
            style: DakshaTypography.body.copyWith(
              fontSize: 16,
              color: DT.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureToggle extends StatelessWidget {
  const _CaptureToggle({required this.photoMode, required this.onToggle});
  final bool photoMode;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DT.radiusBtn),
        border: Border.all(color: DT.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DT.radiusBtn - 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleSeg(label: '📷 Photo', active: photoMode,  onTap: () => onToggle(true)),
            _ToggleSeg(label: '✏ Type',  active: !photoMode, onTap: () => onToggle(false)),
          ],
        ),
      ),
    );
  }
}

class _ToggleSeg extends StatelessWidget {
  const _ToggleSeg({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        color: active ? DT.primary : Colors.transparent,
        child: Text(
          label,
          style: DakshaTypography.caption.copyWith(
            color: active ? DT.primaryFg : DT.muted,
          ),
        ),
      ),
    );
  }
}
