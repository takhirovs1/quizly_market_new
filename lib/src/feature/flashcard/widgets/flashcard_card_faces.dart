import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';
import '../../tests/widgets/latex_text_widget.dart';
import '../../tests/widgets/question_image_widget.dart';
import '../model/flashcard_response_model.dart';
import 'flashcard_card_parts.dart';

/// Question (front) face: tag, optional image, the question text (LaTeX-aware)
/// and a "tap to flip" hint. All colors come from the app theme.
class FlashcardCardFront extends StatelessWidget {
  const FlashcardCardFront({required this.card, required this.onFlip, super.key});

  final FlashcardCardModel card;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final imageUrl = card.imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlashcardCardTag(
              label: context.x.l10n.columnRoleQuestion,
              color: colors.primary,
              background: colors.primary.withValues(alpha: 0.12),
            ),
            FlashcardFlipButton(onTap: onFlip),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    QuestionImageWidget(imageUrl: imageUrl, maxHeight: 200, borderRadius: 16),
                    const SizedBox(height: 20),
                  ],
                  LatexTextWidget(
                    text: card.front,
                    textAlign: TextAlign.center,
                    style: context.x.textStyle.sfW700s28.copyWith(
                      fontSize: 28,
                      height: 36 / 28,
                      letterSpacing: -0.28,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FlashcardHintRow(label: context.x.l10n.flashcardTapToSeeAnswer),
      ],
    );
  }
}

/// Answer (back) face: tag, the question echoed (muted), optional answer image,
/// the answer text (LaTeX-aware), an accent divider and optional explanation.
class FlashcardCardBack extends StatelessWidget {
  const FlashcardCardBack({required this.card, required this.onFlip, super.key});

  final FlashcardCardModel card;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final explanation = card.explanation;
    final backImageUrl = card.backImageUrl;
    final hasAnswerText = card.back.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlashcardCardTag(
              label: context.x.l10n.columnRoleAnswer,
              color: colors.success,
              background: colors.success.withValues(alpha: 0.12),
            ),
            FlashcardFlipButton(onTap: onFlip),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LatexTextWidget(
                    text: card.front,
                    textAlign: TextAlign.center,
                    style: context.x.textStyle.sfW500s14.copyWith(fontSize: 14, height: 20 / 14, color: colors.gray),
                  ),
                  const SizedBox(height: 16),
                  if (backImageUrl != null && backImageUrl.isNotEmpty) ...[
                    QuestionImageWidget(imageUrl: backImageUrl, maxHeight: 180, borderRadius: 16),
                    if (hasAnswerText) const SizedBox(height: 16),
                  ],
                  if (hasAnswerText)
                    LatexTextWidget(
                      text: card.back,
                      textAlign: TextAlign.center,
                      style: context.x.textStyle.sfW700s28.copyWith(
                        fontSize: 34,
                        height: 40 / 34,
                        letterSpacing: -0.34,
                        fontWeight: FontWeight.w800,
                        color: colors.text,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                  if (explanation != null && explanation.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    LatexTextWidget(
                      text: explanation,
                      textAlign: TextAlign.center,
                      style: context.x.textStyle.sfW400s14.copyWith(fontSize: 15, height: 22 / 15, color: colors.gray),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        FlashcardHintRow(label: context.x.l10n.flashcardTapToSeeQuestion),
      ],
    );
  }
}
