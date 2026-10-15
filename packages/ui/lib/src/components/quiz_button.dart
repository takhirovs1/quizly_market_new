import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import 'quiz_lottie_icon.dart';
import 'quiz_text.dart';

/// Figma "Button" component — Type × Size.
enum QuizButtonType { primary, tonal, dark, outline, success, light }

enum QuizButtonSize { l, m, s }

class QuizButton extends StatelessWidget {
  const QuizButton({
    required this.label,
    this.onTap,
    this.type = QuizButtonType.primary,
    this.size = QuizButtonSize.m,
    this.leadingIcon,
    this.leadingLottie,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final QuizButtonType type;
  final QuizButtonSize size;
  final IconData? leadingIcon;

  /// Animated leading icon, tinted with the button's foreground. Wins over [leadingIcon].
  final QuizLottie? leadingLottie;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final (Color bg, Color fg, Color? border) = switch (type) {
      QuizButtonType.primary => (hc.primary, hc.onAccent, null),
      QuizButtonType.tonal => (hc.primaryTint, hc.primary, null),
      // Inverted: dark-on-light in light mode, light-on-dark in dark mode.
      QuizButtonType.dark => (hc.text, hc.surface, null),
      QuizButtonType.success => (hc.success, hc.onAccent, null),
      QuizButtonType.light => (hc.surface, hc.primary, null),
      QuizButtonType.outline => (hc.surface, hc.text, hc.border),
    };
    final double height = switch (size) {
      QuizButtonSize.l => 50,
      QuizButtonSize.m => 38,
      QuizButtonSize.s => 32,
    };
    final double radius = size == QuizButtonSize.l ? 14 : 12;
    final double hpad = size == QuizButtonSize.s ? 12 : 16;
    final double fontSize = switch (size) {
      QuizButtonSize.l => 16,
      QuizButtonSize.m => 15,
      QuizButtonSize.s => 13,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: hpad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: border == null ? null : Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingLottie != null) ...[
                QuizLottieIcon(leadingLottie!, size: fontSize + 4, color: fg),
                const SizedBox(width: 6),
              ] else if (leadingIcon != null) ...[
                Icon(leadingIcon, size: fontSize + 2, color: fg),
                const SizedBox(width: 6),
              ],
              // Only flex the label when the button fills its parent (bounded);
              // an intrinsic button receives unbounded width where Flexible fails.
              if (expand)
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: quizText(fontSize, wSemibold, fg),
                  ),
                )
              else
                Text(label, maxLines: 1, style: quizText(fontSize, wSemibold, fg)),
            ],
          ),
        ),
      ),
    );
  }
}
