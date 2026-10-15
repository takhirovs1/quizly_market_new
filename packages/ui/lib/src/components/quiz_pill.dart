import 'package:flutter/material.dart';

import 'quiz_text.dart';

/// Figma "Pill" component — a small rounded label (status, count, result, XP,
/// streak, delta…). Colors are passed in so one widget covers every type.
class QuizPill extends StatelessWidget {
  const QuizPill({
    required this.text,
    required this.background,
    required this.foreground,
    this.showDot = false,
    this.leading,
    this.fontSize = 12,
    super.key,
  });

  final String text;
  final Color background;
  final Color foreground;
  final bool showDot;
  final Widget? leading;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(100)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        if (leading != null) ...[leading!, const SizedBox(width: 4)],
        Text(text, style: quizText(fontSize, wSemibold, foreground)),
      ],
    ),
  );
}
