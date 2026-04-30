import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/cards.dart';

class ProblemHeader extends StatelessWidget {
  const ProblemHeader({super.key, required this.problemText});

  final String problemText;

  @override
  Widget build(BuildContext context) {
    return ElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solve for x',
            style: DakshaTypography.caption.copyWith(color: DT.muted),
          ),
          const SizedBox(height: DT.xs),
          Text(
            problemText,
            style: DakshaTypography.mono.copyWith(fontSize: 30),
          ),
        ],
      ),
    );
  }
}
