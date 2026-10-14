import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Bottom controls of the study session: swipe hints and the two answer
/// buttons, which fill in as the user swipes (driven by [swipeProgress]).
class FlashcardFooter extends StatelessWidget {
  const FlashcardFooter({
    required this.knownCount,
    required this.unknownCount,
    required this.onKnown,
    required this.onUnknown,
    required this.swipeProgress,
    super.key,
  });

  final int knownCount;
  final int unknownCount;
  final VoidCallback onKnown;
  final VoidCallback onUnknown;
  final ValueNotifier<double> swipeProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '←  ${context.x.l10n.flashcardSwipeLeft} · $unknownCount',
                  style: textStyle.sfW500s14.copyWith(fontSize: 13, color: colors.error),
                ),
                Text(
                  '${context.x.l10n.flashcardSwipeRight} · $knownCount  →',
                  style: textStyle.sfW500s14.copyWith(fontSize: 13, color: colors.success),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<double>(
            valueListenable: swipeProgress,
            builder: (context, progress, _) => Row(
              children: [
                Expanded(
                  child: FlashcardAnswerButton(
                    label: context.x.l10n.flashcardUnknown,
                    color: colors.error,
                    background: colors.error.withValues(alpha: 0.12),
                    icon: Icons.close_rounded,
                    active: progress < -0.5,
                    onTap: onUnknown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FlashcardAnswerButton(
                    label: context.x.l10n.flashcardKnown,
                    color: colors.success,
                    background: colors.success.withValues(alpha: 0.12),
                    icon: Icons.check_rounded,
                    active: progress > 0.5,
                    onTap: onKnown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single pill answer button ("Bilaman" / "Bilmayman"). Fills with its color
/// when [active] (either swiped past threshold or tapped).
class FlashcardAnswerButton extends StatelessWidget {
  const FlashcardAnswerButton({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.active,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final white = colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 64,
        decoration: BoxDecoration(
          color: active ? color : background,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: active ? white : color, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 18, color: active ? color : white),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.x.textStyle.sfW700s16.copyWith(color: active ? white : color, letterSpacing: -0.16),
            ),
          ],
        ),
      ),
    );
  }
}
