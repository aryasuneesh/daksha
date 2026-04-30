import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';

class HintLevelDots extends StatelessWidget {
  const HintLevelDots({super.key, required this.level});

  /// Current hint level (0–3). Dots ≤ level are filled.
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < level;
        return Padding(
          padding: EdgeInsets.only(right: i < 2 ? 6.0 : 0.0),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? DT.primary : DT.elev2,
              border: filled
                  ? null
                  : Border.all(color: DT.outline, width: DT.bwCard),
            ),
          ),
        );
      }),
    );
  }
}
