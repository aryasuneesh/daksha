import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/cards.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final valueStyle = DakshaTypography.withScript(
      DakshaTypography.headingMd.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: DT.primary,
      ),
      value.length > 20 ? value.substring(0, 20) : value,
    );

    final labelStyle = DakshaTypography.withScript(
      DakshaTypography.caption.copyWith(
        fontSize: 10,
        color: DT.muted,
      ),
      label.length > 20 ? label.substring(0, 20) : label,
    );

    return StandardCard(
      padding: const EdgeInsets.symmetric(
        horizontal: DT.sm,
        vertical: DT.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: valueStyle, textAlign: TextAlign.center),
          const SizedBox(height: DT.xs),
          Text(label, style: labelStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
