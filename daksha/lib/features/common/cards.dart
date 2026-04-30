import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';

class StandardCard extends StatelessWidget {
  const StandardCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.lg),
      decoration: BoxDecoration(
        color: DT.elev1,
        borderRadius: BorderRadius.circular(DT.radius),
        border: Border.all(color: DT.outline, width: DT.bwCard),
      ),
      child: child,
    );
  }
}

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.lg),
      decoration: BoxDecoration(
        color: DT.elev2,
        borderRadius: BorderRadius.circular(DT.radius),
        border: Border.all(color: DT.outline, width: DT.bwCard),
      ),
      child: child,
    );
  }
}

/// Amber card — Daksha's voice surface. Used for all AI-generated prompts/hints.
class AmberCard extends StatelessWidget {
  const AmberCard({
    super.key,
    required this.label,
    required this.body,
  });

  /// e.g. "Daksha asks" or "Hint 1"
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.lg),
      decoration: BoxDecoration(
        color: DT.amberBg,
        borderRadius: BorderRadius.circular(DT.radius),
        border: Border.all(color: DT.amber, width: DT.bwCallout),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DakshaTypography.caption.copyWith(
              color: DT.amber,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DT.xs),
          Text(body, style: DakshaTypography.body),
        ],
      ),
    );
  }
}

/// Caution card — misconception feedback surface. Never uses red.
class CautionCard extends StatelessWidget {
  const CautionCard({
    super.key,
    required this.label,
    required this.body,
  });

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.lg),
      decoration: BoxDecoration(
        color: DT.cautionBg,
        borderRadius: BorderRadius.circular(DT.radius),
        border: Border.all(color: DT.caution, width: DT.bwCallout),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠', style: TextStyle(fontSize: 18)),
          const SizedBox(width: DT.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DakshaTypography.caption.copyWith(
                    color: DT.caution,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DT.xs),
                Text(body, style: DakshaTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
