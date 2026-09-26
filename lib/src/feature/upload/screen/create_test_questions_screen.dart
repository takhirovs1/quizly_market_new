import 'package:flutter/cupertino.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/create_test_questions_state.dart';
import '../widget/question_card.dart';

class CreateTestQuestionsScreen extends StatefulWidget {
  const CreateTestQuestionsScreen({
    required this.testName,
    required this.university,
    this.description,
    this.price,
    super.key,
  });

  final String testName;
  final String university;
  final String? description;

  /// Sale price in so'm ("Narxi" from the meta form); null/0 → free.
  final int? price;

  @override
  State<CreateTestQuestionsScreen> createState() => _CreateTestQuestionsScreenState();
}

class _CreateTestQuestionsScreenState extends CreateTestQuestionsState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isMobile = context.x.isMobile;

    return MathKeyboardViewInsets(
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: context.x.l10n.testUploadTitle,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          showBackButton: true,
        ),
        body: SafeArea(
          child: isMobile
              ? _buildBody(context)
              : Center(
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: _buildBody(context)),
                ),
        ),
        bottomNavigationBar: (MediaQuery.viewInsetsOf(context).bottom == 0)
            ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: context.telegramWebApp.isSupported
                        ? context.telegramWebApp.safeAreaInset.bottom.toDouble() + 8
                        : 16,
                  ),
                  child: isMobile
                      ? _buildBottomBar(context)
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: _buildBottomBar(context),
                          ),
                        ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBody(BuildContext context) => CustomScrollView(
    slivers: [
      // ── Info header ───────────────────────────────────────────
      SliverToBoxAdapter(child: _buildInfoHeader(context)),

      // ── Question cards ────────────────────────────────────────
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) => QuestionCard(
            key: ValueKey(questions[index]),
            index: index,
            question: questions[index],
            onToggleExpand: () => onToggleExpand(index),
            onRemoveQuestion: () => removeQuestion(index),
            onAddAnswer: () => addAnswer(index),
            onRemoveAnswer: (ai) => removeAnswer(index, ai),
            onToggleCorrect: (ai) => toggleCorrect(index, ai),
            onTextChanged: onTextChanged,
            onPickImage: ({int? answerIndex}) => pickImage(index, answerIndex: answerIndex),
            onRemoveImage: ({int? answerIndex}) => removeImage(index, answerIndex: answerIndex),
          ),
        ),
      ),

      // ── Add question button ────────────────────────────────────
      SliverToBoxAdapter(child: _buildAddQuestionButton(context)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );

  Widget _buildInfoHeader(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;

    final count = questions.length;
    final reachedMin = reachedRecommendedMin;
    final progress = (count / minQuestions).clamp(0.0, 1.0);

    // Build one-line breadcrumb: university → testName [→ description]
    final titleParts = [
      widget.university,
      widget.testName,
      if (widget.description?.isNotEmpty == true) widget.description!,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // One-line title: university → testName
          Text(
            titleParts.join(' → '),
            style: textStyle.sfW600s16.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Min-questions subtitle
          Text(
            reachedMin
                ? context.x.l10n.minQuestionsCountReached(minQuestions)
                : context.x.l10n.minQuestionsAdvisory(minQuestions),
            style: textStyle.sfW400s14.copyWith(
              color: reachedMin ? colors.primary : colors.bannerSecondaryText,
              fontWeight: reachedMin ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),

          // Progress bar + count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: .circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: colors.divider,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$count/$minQuestions',
                style: textStyle.sfW500s14.copyWith(
                  color: reachedMin ? colors.primary : colors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddQuestionButton(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isEnabled = canAddQuestion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: () {
            if (isEnabled) {
              addQuestion();
            } else {
              context.x.showNotification(
                message: context.x.l10n.fillPreviousQuestionFirst,
                isError: true,
                top: switch (context.telegramWebApp.isSupported) {
                  true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
                  false => MediaQuery.paddingOf(context).top + 56,
                },
              );
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: isEnabled ? colors.primary : colors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
            elevation: 0,
          ),
          icon: Icon(CupertinoIcons.plus, size: 18, color: colors.white),
          label: Text(
            l10n.addQuestion,
            style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isEnabled = canSubmit;

    return AnimatedOpacity(
      opacity: (isEnabled && !isCreating) ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: (isEnabled && !isCreating) ? onUploadTest : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            disabledBackgroundColor: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          ),
          child: isCreating
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(valueColor: AlwaysStoppedAnimation<Color>(colors.white)),
                )
              : Text(
                  l10n.uploadTestButton,
                  style: textStyle.sfW600s16.copyWith(color: colors.white, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
