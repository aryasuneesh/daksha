import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:daksha/core/design_tokens.dart';

class MasteryRing extends StatelessWidget {
  const MasteryRing({
    super.key,
    required this.diameter,
    required this.progress,
    required this.color,
  });

  final double diameter;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _MasteryRingPainter(progress: progress, color: color),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  const _MasteryRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = DT.elev2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MasteryRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
