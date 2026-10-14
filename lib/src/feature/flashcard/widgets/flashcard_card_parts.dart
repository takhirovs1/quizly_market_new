import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Rounded card container with the floating shadow shared by both card faces.
/// Surface + shadow colors defer to the app theme, so dark/light both read well.
class FlashcardCardShell extends StatelessWidget {
  const FlashcardCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Small pill tag ("Savol" / "Javob") shown at the top of a card face.
class FlashcardCardTag extends StatelessWidget {
  const FlashcardCardTag({required this.label, required this.color, required this.background, super.key});

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100)),
    child: Text(label, style: context.x.textStyle.sfW600s16.copyWith(fontSize: 13, color: color, letterSpacing: -0.13)),
  );
}

/// Circular "flip" affordance button in the card header.
class FlashcardFlipButton extends StatelessWidget {
  const FlashcardFlipButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: colors.textFieldBackground, borderRadius: BorderRadius.circular(20)),
        child: Icon(Icons.autorenew_rounded, size: 20, color: colors.gray),
      ),
    );
  }
}

/// Centered hint row ("Tap to see the answer") at the bottom of a card face.
class FlashcardHintRow extends StatelessWidget {
  const FlashcardHintRow({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.autorenew_rounded, size: 16, color: colors.gray),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.x.textStyle.sfW500s14.copyWith(fontSize: 13, color: colors.gray),
          ),
        ),
      ],
    );
  }
}
