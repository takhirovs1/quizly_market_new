import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import 'quiz_text.dart';

/// Figma "Section Header" — a 22/Bold title (optional subtitle) with an
/// optional trailing "[seeAllLabel] ›" link, shown when [onSeeAll] is set.
class QuizSectionHeader extends StatelessWidget {
  const QuizSectionHeader({required this.title, this.subtitle, this.seeAllLabel, this.onSeeAll, super.key})
    : assert(onSeeAll == null || seeAllLabel != null, 'seeAllLabel is required when onSeeAll is set');

  final String title;
  final String? subtitle;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Row(
      crossAxisAlignment: subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: quizText(22, wBold, hc.text)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: quizText(13, wRegular, hc.text3)),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('${seeAllLabel ?? ''} ›', style: quizText(15, wSemibold, hc.primary)),
            ),
          ),
      ],
    );
  }
}
