import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';

class CooldownRing extends StatelessWidget {
  const CooldownRing({
    super.key,
    required this.cooling,
    required this.progress,
  });

  final bool cooling;

  /// 0.0 = just started cooling, 1.0 = ready (cooldown complete).
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (!cooling) return const SizedBox.shrink();
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        value: progress,
        color: DT.amber,
        strokeWidth: 3,
        backgroundColor: DT.elev2,
      ),
    );
  }
}
