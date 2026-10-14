import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Circular accuracy gauge shown on the result screen. The ring + percentage
/// color shifts green/blue/red by score; all colors come from the app theme.
class FlashcardAccuracyRing extends StatelessWidget {
  const FlashcardAccuracyRing({required this.accuracy, super.key});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final percent = (accuracy * 100).round();
    final color = percent >= 80
        ? colors.appleGreen
        : percent >= 50
        ? colors.primary
        : colors.error;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _RingPainter(progress: accuracy, color: color, backgroundColor: colors.divider),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$percent%', style: context.x.textStyle.sfW700s28.copyWith(color: color, fontSize: 36)),
              Text(
                context.x.l10n.flashcardResultTitle,
                style: context.x.textStyle.sfW400s12.copyWith(color: colors.gray, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color, required this.backgroundColor});

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
