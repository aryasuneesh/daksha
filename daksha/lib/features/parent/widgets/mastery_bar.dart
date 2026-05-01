import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';

class MasteryBar extends StatelessWidget {
  const MasteryBar({super.key, required this.label, required this.pct});

  final String label;

  /// Mastery fraction 0.0–1.0.
  final double pct;

  @override
  Widget build(BuildContext context) {
    final labelStyle = DakshaTypography.withScript(
      DakshaTypography.sm,
      label.length > 20 ? label.substring(0, 20) : label,
    );

    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: DT.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: DT.elev2,
              valueColor: const AlwaysStoppedAnimation<Color>(DT.primary),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: DT.sm),
        Text(
          '${(pct * 100).round()}%',
          style: DakshaTypography.caption.copyWith(color: DT.muted),
        ),
      ],
    );
  }
}
