import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Full-bleed colored glow that bleeds in from the swipe side (green = right/
/// known, red = left/unknown) as the card is dragged.
class FlashcardEdgeGlow extends StatelessWidget {
  const FlashcardEdgeGlow({required this.known, required this.opacity, super.key});

  final bool known;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final color = known ? colors.success : colors.error;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: known ? Alignment.centerRight : Alignment.centerLeft,
              end: known ? Alignment.centerLeft : Alignment.centerRight,
              colors: [
                color.withValues(alpha: 0.28 * opacity),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.4],
            ),
          ),
        ),
      ),
    );
  }
}
