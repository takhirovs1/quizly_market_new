import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Rotated "KNOW IT" / "DON'T KNOW" stamp overlaid on the card while swiping.
/// Green when swiping toward "known", red toward "unknown".
class FlashcardSwipeStamp extends StatelessWidget {
  const FlashcardSwipeStamp({required this.known, super.key});

  final bool known;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final color = known ? colors.success : colors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(known ? Icons.check_rounded : Icons.close_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            (known ? context.x.l10n.flashcardKnown : context.x.l10n.flashcardUnknown).toUpperCase(),
            style: context.x.textStyle.sfW700s18.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
