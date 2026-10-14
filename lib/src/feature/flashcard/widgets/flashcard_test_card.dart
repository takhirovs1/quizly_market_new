import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';
import '../model/flashcard_response_model.dart';

/// Multiple-choice card used by the (optional) "test" sub-mode: the question
/// in a raised card followed by tappable option tiles that reveal correct /
/// wrong state once checked.
class FlashcardTestCard extends StatelessWidget {
  const FlashcardTestCard({
    required this.card,
    required this.selectedOptionId,
    required this.isChecked,
    required this.onSelect,
    super.key,
  });

  final FlashcardCardModel card;
  final String? selectedOptionId;
  final bool isChecked;
  final ValueChanged<FlashcardOptionModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final options = card.options ?? const <FlashcardOptionModel>[];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.cardBackground2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(color: colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Text(
              card.front,
              textAlign: TextAlign.center,
              style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18, height: 1.5, color: colors.text),
            ),
          ),
          const SizedBox(height: 16),
          for (final opt in options)
            FlashcardOptionTile(
              option: opt,
              isChecked: isChecked,
              isSelected: selectedOptionId == opt.id,
              isCorrect: card.correctOptionId == opt.id,
              onTap: isChecked ? null : () => onSelect(opt),
            ),
        ],
      ),
    );
  }
}

/// A single answer tile in [FlashcardTestCard].
class FlashcardOptionTile extends StatelessWidget {
  const FlashcardOptionTile({
    required this.option,
    required this.isChecked,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    super.key,
  });

  final FlashcardOptionModel option;
  final bool isChecked;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;

    var bgColor = colors.textFieldBackground;
    var borderColor = colors.divider;
    if (isChecked) {
      if (isCorrect) {
        bgColor = colors.appleGreen.withValues(alpha: 0.12);
        borderColor = colors.appleGreen;
      } else if (isSelected) {
        bgColor = colors.error.withValues(alpha: 0.10);
        borderColor = colors.error;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(option.text, style: context.x.textStyle.sfW400s16.copyWith(fontSize: 15, color: colors.text)),
            ),
            if (isChecked && isCorrect)
              Icon(Icons.check_circle_rounded, color: colors.appleGreen, size: 20)
            else if (isChecked && isSelected && !isCorrect)
              Icon(Icons.cancel_rounded, color: colors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
