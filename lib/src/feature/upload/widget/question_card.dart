import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../model/test_question_model.dart';
import 'answer_input_field.dart';

/// Accordion-style card for one question and its answers. Both the question and
/// every option use [AnswerInputField], so each can be typed with the native
/// keyboard (plain text) or the in-app math keyboard (TeX).
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
    this.onPickImage,
    this.onRemoveImage,
    this.allowMultiCorrect = false,
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

  /// Pick an image for the question (`answerIndex == null`) or an option.
  final void Function({int? answerIndex})? onPickImage;

  /// Remove the image from the question (`answerIndex == null`) or an option.
  final void Function({int? answerIndex})? onRemoveImage;

  /// When true the correct-answer toggles are checkboxes (multi), else radios.
  final bool allowMultiCorrect;

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
                        // Question field (native / math) + image + remove buttons
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AnswerInputField(
                                nativeController: question.nativeController,
                                mathController: question.mathController,
                                isMathMode: question.isMathMode,
                                hintText: l10n.questionLabel,
                                onChanged: onTextChanged,
                              ),
                            ),
                            if (onPickImage != null) ...[
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _ImagePickButton(
                                  hasImage: question.hasImage || question.imageUploading,
                                  onTap: () => onPickImage!(),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: GestureDetector(
                                onTap: onRemoveQuestion,
                                child: Icon(CupertinoIcons.xmark, color: colors.error, size: 20),
                              ),
                            ),
                          ],
                        ),
                        if (question.hasImage || question.imageUploading)
                          _ImageThumb(
                            url: question.imageUrl,
                            uploading: question.imageUploading,
                            onRemove: onRemoveImage == null ? null : () => onRemoveImage!(),
                          ),
                        const SizedBox(height: 14),

                        Row(
                          children: [Text(l10n.answersLabel, style: textStyle.sfW500s16.copyWith(color: colors.text))],
                        ),
                        const SizedBox(height: 10),

                        // Answer rows
                        ...question.answers.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: AnswerInputField(
                                        nativeController: entry.value.nativeController,
                                        mathController: entry.value.mathController,
                                        isMathMode: entry.value.isMathMode,
                                        hintText: '${l10n.answersLabel} ${entry.key + 1}',
                                        showWrongFeedback: false,
                                        onChanged: onTextChanged,
                                        leading: _CorrectToggle(
                                          isCorrect: entry.value.isCorrect,
                                          multi: allowMultiCorrect,
                                          onTap: () => onToggleCorrect(entry.key),
                                        ),
                                      ),
                                    ),
                                    if (onPickImage != null) ...[
                                      const SizedBox(width: 6),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: _ImagePickButton(
                                          hasImage: entry.value.hasImage || entry.value.imageUploading,
                                          onTap: () => onPickImage!(answerIndex: entry.key),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (entry.value.hasImage || entry.value.imageUploading)
                                  _ImageThumb(
                                    url: entry.value.imageUrl,
                                    uploading: entry.value.imageUploading,
                                    onRemove: onRemoveImage == null
                                        ? null
                                        : () => onRemoveImage!(answerIndex: entry.key),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Remove-answer row (shown only when > 2 answers)
                        if (question.answers.length > 2)
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              onPressed: () => onRemoveAnswer(question.answers.length - 1),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.minus_circle, color: colors.error, size: 18),
                                  const SizedBox(width: 4),
                                  Text(l10n.removeLast, style: textStyle.sfW500s14.copyWith(color: colors.error)),
                                ],
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

/// Small photo button that opens the image picker for a field.
class _ImagePickButton extends StatelessWidget {
  const _ImagePickButton({required this.hasImage, required this.onTap});

  final bool hasImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Semantics(
      button: true,
      label: context.x.l10n.addImageLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            hasImage ? CupertinoIcons.photo_fill : CupertinoIcons.photo,
            color: hasImage ? colors.primary : colors.bannerSecondaryText,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Uploaded-image thumbnail with a remove badge; shimmer while uploading.
class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.url, required this.uploading, this.onRemove});

  final String? url;
  final bool uploading;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;

    if (uploading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Align(alignment: Alignment.centerLeft, child: ShimmerBox(width: 72, height: 72, radius: 12)),
      );
    }
    if (url == null || url!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 72,
                  height: 72,
                  color: colors.divider,
                  child: Icon(CupertinoIcons.photo, color: colors.bannerSecondaryText),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
                    child: Icon(CupertinoIcons.xmark, size: 12, color: colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Correct-answer toggle: a radio (single) or a checkbox (multi).
class _CorrectToggle extends StatelessWidget {
  const _CorrectToggle({required this.isCorrect, required this.multi, required this.onTap});

  final bool isCorrect;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final icon = isCorrect
        ? (multi ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.checkmark_circle_fill)
        : (multi ? CupertinoIcons.square : CupertinoIcons.circle);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          icon,
          key: ValueKey('${multi}_$isCorrect'),
          color: isCorrect ? colors.primary : colors.divider,
          size: 26,
        ),
      ),
    );
  }
}
