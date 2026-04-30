import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';

class StudentBubble extends StatelessWidget {
  const StudentBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DT.cardHPad,
            vertical: DT.lg,
          ),
          decoration: BoxDecoration(
            color: DT.bg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
            ),
            border: Border.all(color: DT.outline, width: DT.bwCard),
          ),
          child: Text(text, style: DakshaTypography.body),
        ),
      ),
    );
  }
}
