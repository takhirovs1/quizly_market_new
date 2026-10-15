import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import 'quiz_button.dart';
import 'quiz_text.dart';

/// Figma "Empty State" (Card / Plain) — an illustration, title, description
/// and a single CTA.
class QuizEmptyState extends StatelessWidget {
  const QuizEmptyState({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.card = true,
    this.emoji = '📚',
    this.illustration,
    this.illustrationBackground,
    this.illustrationDecorations = const <Widget>[],
    super.key,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool card;
  final String emoji;

  /// Replaces [emoji] inside the illustration circle (e.g. a [QuizLottieIcon]).
  final Widget? illustration;

  /// Defaults to `primaryTint`.
  final Color? illustrationBackground;

  /// Extra [Positioned] layers painted over the 96×96 illustration circle.
  final List<Widget> illustrationDecorations;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      decoration: card
          ? BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow])
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: illustrationBackground ?? hc.primaryTint, shape: BoxShape.circle),
                  child: illustration ?? Text(emoji, style: const TextStyle(fontSize: 44)),
                ),
                ...illustrationDecorations,
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: quizText(17, wSemibold, hc.text)),
          const SizedBox(height: 6),
          Text(description, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3, height: 1.42)),
          const SizedBox(height: 16),
          QuizButton(label: buttonLabel, onTap: onPressed),
        ],
      ),
    );
  }
}
