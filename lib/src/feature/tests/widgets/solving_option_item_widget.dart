import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/demo_test_model.dart';
import 'latex_text_widget.dart';
import 'question_image_widget.dart';

class SolvingOptionItemWidget extends StatelessWidget {
  const SolvingOptionItemWidget({
    required this.option,
    required this.isSelected,
    required this.isChecked,
    required this.onTap,
    super.key,
  });

  final DemoOption option;
  final bool isSelected;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default states
    var backgroundColor = context.x.colors.optionBackground;
    var borderColor = isDark ? colors.divider : colors.gray.withValues(alpha: 0.2);
    var textColor = colors.text;

    // When the answer is checked (submitted)
    if (isChecked) {
      if (option.isCorrect ?? false) {
        backgroundColor = context.x.colors.optionCorrectBackground;
        borderColor = context.x.colors.answerCorrect; // Success Green
      } else if (isSelected) {
        backgroundColor = context.x.colors.optionWrongBackground;
        borderColor = context.x.colors.answerWrong; // Error Red
      }
    } else {
      // Selected state before check
      if (isSelected) {
        backgroundColor = colors.primary.withValues(alpha: isDark ? 0.15 : 0.08);
        borderColor = colors.primary;
      }
    }

    final hasImage = option.image != null && option.image!.isNotEmpty;
    final hasText = option.text != null && option.text!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: context.x.colors.transparent,
        child: InkWell(
          onTap: isChecked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: colors.primary.withValues(alpha: isDark ? 0.08 : 0.03),
          splashColor: colors.primary.withValues(alpha: 0.1),
          highlightColor: colors.primary.withValues(alpha: 0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected || (isChecked && (option.isCorrect ?? false)) ? 2.0 : 1.0,
              ),
              boxShadow: isSelected && !isChecked
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                _buildIndicator(context, colors, isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        QuestionImageWidget(imageUrl: option.image!, maxHeight: 160, borderRadius: 8),
                        if (hasText) const SizedBox(height: 8),
                      ],
                      if (hasText)
                        LatexTextWidget(
                          text: option.text!,
                          style: context.x.textStyle.sfW500s14.copyWith(color: textColor, fontSize: 15.5, height: 1.4),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, colors, bool isDark) {
    if (isChecked) {
      if (option.isCorrect ?? false) {
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: context.x.colors.answerCorrect, shape: BoxShape.circle),
          child: Icon(Icons.check, color: context.x.colors.pureWhite, size: 14),
        );
      } else if (isSelected) {
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: context.x.colors.answerWrong, shape: BoxShape.circle),
          child: Icon(Icons.close, color: context.x.colors.pureWhite, size: 14),
        );
      }
    }

    // Default indicators (circular dot)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? context.x.colors.primary : context.x.colors.gray.withValues(alpha: 0.4),
          width: isSelected ? 6 : 2,
        ),
        color: isSelected ? context.x.colors.pureWhite : context.x.colors.transparent,
      ),
    );
  }
}
