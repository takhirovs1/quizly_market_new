import 'package:flutter/cupertino.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../model/test_question_model.dart';

/// Accordion-style card for one question and its answers using MathField.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.index,
    required this.question,
    required this.onToggleExpand,
    required this.onRemoveQuestion,
    required this.onAddAnswer,
    required this.onRemoveAnswer,
    required this.onToggleCorrect,
    required this.onTextChanged,
    super.key,
  });

  final int index;
  final QuestionModel question;
  final VoidCallback onToggleExpand;
  final VoidCallback onRemoveQuestion;
  final VoidCallback onAddAnswer;
  final void Function(int answerIndex) onRemoveAnswer;
  final void Function(int answerIndex) onToggleCorrect;
  final void Function(String) onTextChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;
    final isExpanded = question.isExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpanded ? colors.primary : colors.divider, width: isExpanded ? 1.5 : 1),
        boxShadow: isExpanded
            ? [BoxShadow(color: colors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────
          InkWell(
            onTap: onToggleExpand,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${index + 1}. ${l10n.questionLabel}',
                      style: textStyle.sfW600s16.copyWith(
                        color: isExpanded ? colors.primary : colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Validity indicator
                  if (!isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        question.isValid ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.exclamationmark_circle,
                        color: question.isValid ? colors.primary : colors.error,
                        size: 18,
                      ),
                    ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      color: isExpanded ? colors.primary : colors.bannerSecondaryText,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body (animated) ─────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question MathField
                        _MathQuestionField(
                          controller: question.controller,
                          focusNode: question.focusNode,
                          hintText: l10n.questionLabel,
                          onChanged: onTextChanged,
                          onRemove: onRemoveQuestion,
                          colors: colors,
                          textStyle: textStyle,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),

                        // Answers header
                        Row(
                          children: [Text(l10n.answersLabel, style: textStyle.sfW500s16.copyWith(color: colors.text))],
                        ),
                        const SizedBox(height: 10),

                        // Answer rows
                        ...question.answers.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MathAnswerRow(
                              controller: entry.value.controller,
                              focusNode: entry.value.focusNode,
                              isCorrect: entry.value.isCorrect,
                              canRemove: question.answers.length > 2,
                              onToggleCorrect: () => onToggleCorrect(entry.key),
                              onRemove: () => onRemoveAnswer(entry.key),
                              onChanged: onTextChanged,
                              colors: colors,
                              textStyle: textStyle,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // Add answer button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: onAddAnswer,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.plus_circle, color: colors.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                l10n.addAnswer,
                                style: textStyle.sfW500s14.copyWith(color: colors.primary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Math-aware input components ──────────────────────────────────────────

class _MathQuestionField extends StatelessWidget {
  const _MathQuestionField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onRemove,
    required this.colors,
    required this.textStyle,
    required this.isDark,
  });

  final MathFieldEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final void Function(String) onChanged;
  final VoidCallback onRemove;
  final ThemeColors colors;
  final AppTypography textStyle;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: MathField(
          controller: controller,
          focusNode: focusNode,
          variables: const ['x', 'y', 'z', 'a', 'b', 'c', 'n', 'k', 't'],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
            filled: true,
            fillColor: isDark ? colors.scaffoldBackground : colors.buttonFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      CupertinoButton(
        padding: const EdgeInsets.only(top: 10),
        minimumSize: Size.zero,
        onPressed: onRemove,
        child: Icon(CupertinoIcons.xmark, color: colors.error, size: 20),
      ),
    ],
  );
}

class _MathAnswerRow extends StatelessWidget {
  const _MathAnswerRow({
    required this.controller,
    required this.focusNode,
    required this.isCorrect,
    required this.canRemove,
    required this.onToggleCorrect,
    required this.onRemove,
    required this.onChanged,
    required this.colors,
    required this.textStyle,
    required this.isDark,
  });

  final MathFieldEditingController controller;
  final FocusNode focusNode;
  final bool isCorrect;
  final bool canRemove;
  final VoidCallback onToggleCorrect;
  final VoidCallback onRemove;
  final void Function(String) onChanged;
  final ThemeColors colors;
  final AppTypography textStyle;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Correct answer toggle
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: onToggleCorrect,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isCorrect
                ? Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    key: const ValueKey('checked'),
                    color: colors.primary,
                    size: 28,
                  )
                : Icon(CupertinoIcons.circle, key: const ValueKey('unchecked'), color: colors.divider, size: 28),
          ),
        ),
      ),
      const SizedBox(width: 10),

      // Answer MathField
      Expanded(
        child: MathField(
          controller: controller,
          focusNode: focusNode,
          variables: const ['x', 'y', 'z', 'a', 'b', 'c', 'n', 'k', 't'],
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? colors.scaffoldBackground : colors.buttonFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isCorrect ? colors.primary : colors.divider, width: isCorrect ? 1.5 : 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
      ),

      // Remove answer (only if > 2 answers)
      if (canRemove) ...[
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: onRemove,
            child: Icon(CupertinoIcons.minus_circle, color: colors.error, size: 22),
          ),
        ),
      ],
    ],
  );
}
