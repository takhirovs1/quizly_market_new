import 'package:flutter/material.dart';

import 'quiz_text.dart';

/// Circular initial-letter avatar (test cards, friend cluster). Tinted fill +
/// accent border, matching the Figma Avatar component.
class QuizInitialAvatar extends StatelessWidget {
  const QuizInitialAvatar({
    required this.initial,
    required this.color,
    required this.background,
    this.size = 52,
    this.borderWidth = 2,
    this.borderColor,
    this.fontSize,
    super.key,
  });

  final String initial;
  final Color color;
  final Color background;
  final double size;
  final double borderWidth;
  final Color? borderColor;

  /// Defaults to a third of [size].
  final double? fontSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      shape: BoxShape.circle,
      border: borderWidth > 0 ? Border.all(color: borderColor ?? color, width: borderWidth) : null,
    ),
    child: Text(initial, style: quizText(fontSize ?? size * 0.33, wBold, color)),
  );
}
