import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import 'quiz_button.dart';
import 'quiz_text.dart';

/// Figma "Inline Error / Section" — a per-section failure card with a retry
/// button. One failing section shows this; the rest of the screen keeps working.
class QuizInlineError extends StatelessWidget {
  const QuizInlineError({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow]),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: hc.dangerTint, shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, size: 24, color: hc.danger),
          ),
          const SizedBox(height: 8),
          Text(title, style: quizText(16, wSemibold, hc.text)),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center, style: quizText(13, wRegular, hc.text3)),
          const SizedBox(height: 12),
          QuizButton(
            label: retryLabel,
            type: QuizButtonType.outline,
            size: QuizButtonSize.s,
            leadingIcon: Icons.refresh_rounded,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}
