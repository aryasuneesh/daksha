import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: DT.primary,
          disabledBackgroundColor: DT.elev2,
          foregroundColor: DT.primaryFg,
          disabledForegroundColor: DT.muted,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: DT.btnHPad, vertical: DT.lg),
          minimumSize: const Size(double.infinity, DT.minTouch),
          textStyle: DakshaTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Alias used by ModelSetupScreen and other screens that need a clearly named
/// secondary CTA alongside [PrimaryButton].
typedef SecondaryButton = DakshaOutlineButton;

class DakshaOutlineButton extends StatelessWidget {
  const DakshaOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: enabled ? DT.primary : DT.muted,
          side: BorderSide(
            color: enabled ? DT.primary : DT.outline,
            width: 2,
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: DT.btnHPad, vertical: DT.lg),
          minimumSize: const Size(double.infinity, DT.minTouch),
          textStyle: DakshaTypography.sm.copyWith(fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      ),
    );
  }
}

class DakshaTextButton extends StatelessWidget {
  const DakshaTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: DT.accent,
        padding: const EdgeInsets.all(DT.sm),
        minimumSize: const Size(DT.minTouch, DT.minTouch),
        textStyle: DakshaTypography.sm.copyWith(fontWeight: FontWeight.w400),
      ),
      child: Text(label),
    );
  }
}
