import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// A blank "next card" peeking out behind the top card. Narrower and pushed
/// down so a sliver shows at the bottom of the deck (02b). Theme-aware surface
/// + shadow.
class FlashcardGhostCard extends StatelessWidget {
  const FlashcardGhostCard({required this.width, required this.height, required this.translateY, super.key});

  final double width;
  final double height;
  final double translateY;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Transform.translate(
      offset: Offset(0, translateY),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardBackground2,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
