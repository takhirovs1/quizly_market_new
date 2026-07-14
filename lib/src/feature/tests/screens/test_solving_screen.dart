import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/app_enum.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/test_init_enum.dart' hide TestMode;
import '../bloc/test_view.dart';
import '../model/test_route_arguments.dart';
import '../state/test_solving_screen_state.dart';
import '../widgets/solving_option_item_widget.dart';
import '../widgets/latex_text_widget.dart';
import '../widgets/question_image_widget.dart';
import '../widgets/test_mode_shimmer.dart';

class TestSolvingScreen extends StatefulWidget {
  const TestSolvingScreen({required this.arguments, super.key});

  final TestSolvingArguments arguments;

  String get testId => arguments.testId;
  String get attemptId => arguments.attemptId;
  int get startRange => arguments.startRange;
  int get endRange => arguments.endRange;
  String get timeOptionName => arguments.timeOptionName;
  String get shuffleOptionName => arguments.shuffleOptionName;
  int? get lastAttemptCorrect => arguments.lastAttemptCorrect;
  int? get lastAttemptTotal => arguments.lastAttemptTotal;
  int? get lastAttemptTime => arguments.lastAttemptTime;
  String? get lastAttemptDate => arguments.lastAttemptDate;
  int? get lastAttemptSkip => arguments.lastAttemptSkip;

  @override
  State<TestSolvingScreen> createState() => _TestSolvingScreenState();
}

class _TestSolvingScreenState extends TestSolvingScreenState {
  late final ScrollController _indicatorScrollController;

  @override
  void initState() {
    super.initState();
    _indicatorScrollController = ScrollController();
    currentQuestionIndex.addListener(_scrollToCurrentIndicator);
  }

  @override
  void dispose() {
    currentQuestionIndex.removeListener(_scrollToCurrentIndicator);
    _indicatorScrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentIndicator() {
    void doScroll([int retryCount = 0]) {
      if (!mounted) return;
      if (!_indicatorScrollController.hasClients) return;

      final maxScroll = _indicatorScrollController.position.maxScrollExtent;

      // If maxScrollExtent is 0 but we have many items, the layout is not ready yet.
      // We will retry on the next frame (up to 5 times to prevent infinite loops).
      if (maxScroll == 0.0 && totalToSolve > 8 && retryCount < 5) {
        WidgetsBinding.instance.addPostFrameCallback((_) => doScroll(retryCount + 1));
        return;
      }

      final index = currentQuestionIndex.value;
      const itemSize = 48.0; // 40 width + 8 padding
      final viewportWidth = MediaQuery.sizeOf(context).width;
      final targetOffset = (index * itemSize) - (viewportWidth / 2) + (itemSize / 2);

      _indicatorScrollController.animateTo(
        targetOffset.clamp(0.0, maxScroll > 0.0 ? maxScroll : double.infinity),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => doScroll());
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: BlocConsumer<TestView, TestViewState>(
      listener: (context, state) {
        if (state.detail != null) {
          if (questions.isEmpty) {
            setState(initializeQuestions);
          } else {
            final apiQuestions = state.detail?.questions ?? [];
            if (apiQuestions.length > questions.length) {
              final newApiQuestions = apiQuestions.sublist(questions.length);
              final processedNewQuestions = newApiQuestions.map((q) {
                if (q.options != null &&
                    (widget.shuffleOptionName == ShuffleOption.all.name ||
                        widget.shuffleOptionName == ShuffleOption.answersOnly.name)) {
                  final newOptions = List<DemoOption>.from(q.options!)..shuffle();
                  return DemoQuestion(
                    id: q.id,
                    testId: q.testId,
                    text: q.text,
                    position: q.position,
                    score: q.score,
                    options: newOptions,
                    createdAt: q.createdAt,
                    image: q.image,
                  );
                }
                return q;
              }).toList();
              setState(() {
                questions.addAll(processedNewQuestions);
              });
            }
          }
        }
      },
      builder: (context, state) {
        if (state.detail == null || questions.isEmpty) {
          final isMobile = context.x.isMobile || context.x.isTablet;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
          final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            appBar: _buildAppBar(context),
            bottomNavigationBar: isMobile
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: const ShimmerBox(width: double.infinity, height: 48, radius: 12),
                      ),
                    ),
                  )
                : null,
            body: const TestSolvingShimmer(),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth >= 800;

            if (isWeb) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: Theme.of(context).brightness == Brightness.light
                        ? [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)]
                        : [const Color(0xFF090D16), const Color(0xFF151B2C)],
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.x.colors.cardBackground2,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0x0F000000)
                                  : const Color(0x1FFFFFFF),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.x.colors.black.withValues(
                                  alpha: Theme.of(context).brightness == Brightness.light ? 0.04 : 0.12,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: context.x.colors.black.withValues(
                                  alpha: Theme.of(context).brightness == Brightness.light ? 0.02 : 0.06,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWebHeader(context, state),
                              if (widget.arguments.mode == TestMode.university) ...[
                                const SizedBox(height: 16),
                                _buildQuestionIndicatorRow(),
                              ],
                              ValueListenableBuilder<bool>(
                                valueListenable: isFetching,
                                builder: (context, fetching, _) {
                                  if (fetching) {
                                    return const TestQuestionContentShimmer(isMobile: false);
                                  }
                                  return ValueListenableBuilder<int>(
                                    valueListenable: currentQuestionIndex,
                                    builder: (context, index, _) {
                                      if (index >= questions.length) {
                                        return const TestQuestionContentShimmer(isMobile: false);
                                      }
                                      final question = questions[index];
                                      return _buildWebQuestionBody(context, index, question);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Mobile Layout
            return Scaffold(
              backgroundColor: context.x.colors.scaffoldBackground,
              appBar: _buildAppBar(context),
              bottomNavigationBar: _buildBottomBar(context),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              state.detail?.name ?? '',
                              style: context.x.textStyle.sfW600s16.copyWith(fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: onFinish,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 80,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.x.colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: context.x.colors.gray.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                context.x.l10n.finishTest,
                                style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.arguments.mode == TestMode.university) ...[
                      const SizedBox(height: 16),
                      _buildQuestionIndicatorRow(),
                    ],
                    ValueListenableBuilder<bool>(
                      valueListenable: isFetching,
                      builder: (context, fetching, _) {
                        if (fetching) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: TestQuestionContentShimmer(isMobile: true),
                          );
                        }
                        return ValueListenableBuilder<int>(
                          valueListenable: currentQuestionIndex,
                          builder: (context, index, _) {
                            if (index >= questions.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: TestQuestionContentShimmer(isMobile: true),
                              );
                            }
                            final question = questions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.x.l10n.questionLabel,
                                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                                      ),
                                      Text(
                                        '${index + 1}/$totalToSolve',
                                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                                      ),
                                    ],
                                  ),
                                  if (question.image != null && question.image!.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    QuestionImageWidget(imageUrl: question.image!, width: double.infinity, height: 200),
                                  ],
                                  const SizedBox(height: 16),
                                  LatexTextWidget(
                                    text: question.text ?? '',
                                    style: context.x.textStyle.sfW600s16.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 24),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: isAnswerChecked,
                                    builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
                                      valueListenable: selectedOption,
                                      builder: (context, selected, _) => Column(
                                        spacing: 12,
                                        children: (question.options ?? [])
                                            .map(
                                              (option) => SolvingOptionItemWidget(
                                                option: option,
                                                isSelected: selected == option,
                                                isChecked: checked,
                                                onTap: () => onOptionSelected(option),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );

  Widget _buildWebHeader(BuildContext context, TestViewState state) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.detail?.name ?? '',
              style: context.x.textStyle.sfW600s16.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.x.colors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: currentQuestionIndex,
              builder: (context, index, _) => Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (index + 1) / totalToSolve,
                        backgroundColor: context.x.colors.gray.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(context.x.colors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${index + 1}/$totalToSolve',
                    style: context.x.textStyle.sfW600s16.copyWith(
                      color: context.x.colors.gray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 24),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: isAnswerChecked,
            builder: (context, checked, _) {
              final showTimer = questionTimeSeconds > 0 || checked || widget.arguments.mode == TestMode.university;
              if (!showTimer) return const SizedBox.shrink();
              return ValueListenableBuilder<int>(
                valueListenable: remainingSeconds,
                builder: (context, seconds, _) {
                  final min = seconds ~/ 60;
                  final sec = seconds % 60;
                  final timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
                  final isLow = seconds <= 10;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLow
                          ? context.x.colors.error.withValues(alpha: 0.12)
                          : context.x.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isLow
                            ? context.x.colors.error.withValues(alpha: 0.2)
                            : context.x.colors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: isLow ? context.x.colors.error : context.x.colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeStr,
                          style: context.x.textStyle.sfW600s16.copyWith(
                            color: isLow ? context.x.colors.error : context.x.colors.primary,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onFinish,
            style: OutlinedButton.styleFrom(
              foregroundColor: context.x.colors.error,
              side: BorderSide(color: context.x.colors.error.withValues(alpha: 0.3)),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(context.x.l10n.finishTest, style: context.x.textStyle.sfW600s16.copyWith(fontSize: 13)),
          ),
        ],
      ),
    ],
  );

  Widget _buildWebQuestionBody(BuildContext context, int index, DemoQuestion question) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 32),
      if (question.image != null && question.image!.isNotEmpty) ...[
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.x.colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.light ? 0.04 : 0.15,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QuestionImageWidget(imageUrl: question.image!, width: double.infinity, height: 320, borderRadius: 16),
        ),
      ],
      LatexTextWidget(
        text: question.text ?? '',
        style: context.x.textStyle.sfW600s16.copyWith(fontSize: 20, height: 1.45, color: context.x.colors.text),
      ),
      const SizedBox(height: 28),
      ValueListenableBuilder<bool>(
        valueListenable: isAnswerChecked,
        builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
          valueListenable: selectedOption,
          builder: (context, selected, _) => Column(
            spacing: 12,
            children: (question.options ?? [])
                .map(
                  (option) => SolvingOptionItemWidget(
                    option: option,
                    isSelected: selected == option,
                    isChecked: checked,
                    onTap: () => onOptionSelected(option),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      const SizedBox(height: 32),
      _buildNavigationButtons(context),
    ],
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => PreferredSize(
    preferredSize: Size.fromHeight((context.telegramWebApp.safeAreaInset.top.toDouble()) + 56),
    child: ValueListenableBuilder<bool>(
      valueListenable: isAnswerChecked,
      builder: (context, checked, _) {
        final showTimer = questionTimeSeconds > 0 || checked || widget.arguments.mode == TestMode.university;
        if (showTimer) {
          return ValueListenableBuilder<int>(
            valueListenable: remainingSeconds,
            builder: (context, seconds, _) {
              final min = seconds ~/ 60;
              final sec = seconds % 60;
              final timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
              return QuizAppBar(
                telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
                title: timeStr,
              );
            },
          );
        }
        return QuizAppBar(
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          title: '',
        );
      },
    ),
  );

  Widget _buildNextButtonWidget(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: isAnswerChecked,
    builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
      valueListenable: selectedOption,
      builder: (context, selected, _) {
        final isCorrect = selected?.isCorrect ?? false;
        final buttonColor = checked
            ? (isCorrect ? const Color(0xFF43C04D) : const Color(0xFFE53935))
            : context.x.colors.buttonFill;
        final textColor = checked ? Colors.white : context.x.colors.gray;

        return SizedBox(
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            tween: Tween<double>(end: checked ? 1.0 : 0.95),
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 300),
                tween: ColorTween(end: buttonColor),
                builder: (context, animBgColor, _) => TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 300),
                  tween: ColorTween(end: textColor),
                  builder: (context, animTextColor, _) => ValueListenableBuilder<int>(
                    valueListenable: remainingSeconds,
                    builder: (context, seconds, _) {
                      final title = checked && seconds > 0
                          ? '${context.x.l10n.nextButton} ($seconds)'
                          : context.x.l10n.nextButton;
                      return CustomButton(
                        onTap: checked ? onNextPressed : () {},
                        title: title,
                        color: animBgColor,
                        textColor: animTextColor,
                        borderRadius: 12,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildBottomBar(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
      child: _buildNavigationButtons(context),
    ),
  );

  Widget _buildNavigationButtons(BuildContext context) {
    if (widget.arguments.mode != TestMode.university) {
      return _buildNextButtonWidget(context);
    }

    return ValueListenableBuilder<int>(
      valueListenable: currentQuestionIndex,
      builder: (context, index, _) {
        final isFirstQuestion = index == 0;

        return ValueListenableBuilder<bool>(
          valueListenable: isAnswerChecked,
          builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
            valueListenable: selectedOption,
            builder: (context, selected, _) {
              final isCorrect = selected?.isCorrect ?? false;
              final rightButtonType = checked ? (isCorrect ? ButtonType.success : ButtonType.error) : ButtonType.active;

              return ValueListenableBuilder<int>(
                valueListenable: postAnswerRemainingSeconds,
                builder: (context, postSeconds, _) {
                  final rightText = checked && postSeconds > 0
                      ? '${context.x.l10n.nextButton} ($postSeconds)'
                      : context.x.l10n.nextButton;

                  return CustomButton2(
                    width: context.x.width,
                    onLeftPressed: isFirstQuestion ? null : onPreviousPressed,
                    leftText: context.x.l10n.previousButton,
                    leftButtonType: isFirstQuestion ? ButtonType.disabled : ButtonType.active,
                    onRightPressed: onNextPressed,
                    rightText: rightText,
                    rightButtonType: rightButtonType,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuestionIndicatorRow() => ValueListenableBuilder<int>(
    valueListenable: currentQuestionIndex,
    builder: (context, currentIndex, _) => ValueListenableBuilder<bool>(
      valueListenable: isAnswerChecked,
      builder: (context, checked, child) => SizedBox(
        height: 44,
        child: ListView.builder(
          key: const PageStorageKey('question_indicator_list_view'),
          controller: _indicatorScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: totalToSolve,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final isCurrent = index == currentIndex;
            final statusColor = _getQuestionStatusColor(index);
            final bgColor = _getQuestionBackgroundColor(index, statusColor);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () async {
                  if (index >= questions.length) {
                    await fetchQuestionsUpTo(index);
                  }
                  if (index < questions.length && mounted) {
                    currentQuestionIndex.value = index;
                    startQuestion();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: isCurrent ? 2.4 : 1.2),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: context.x.textStyle.sfW500s22.copyWith(color: context.x.colors.text, fontSize: 14),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  Color _getQuestionStatusColor(int index) {
    final isCurrent = index == currentQuestionIndex.value;
    if (index >= questions.length) {
      return isCurrent ? context.x.colors.primary : context.x.colors.gray.withValues(alpha: 0.3);
    }

    final q = questions[index];
    final selectedOptionId = selectedAnswers[q.id];

    if (selectedOptionId == null) {
      return isCurrent ? context.x.colors.primary : context.x.colors.gray.withValues(alpha: 0.3);
    }

    final option = q.options?.firstWhereOrNull((o) => o.id == selectedOptionId);
    final isCorrect = option?.isCorrect ?? false;
    return isCorrect ? const Color(0xFF43C04D) : const Color(0xFFE53935);
  }

  Color _getQuestionBackgroundColor(int index, Color statusColor) {
    final isCurrent = index == currentQuestionIndex.value;
    if (index >= questions.length) {
      return isCurrent ? statusColor.withValues(alpha: 0.12) : Colors.transparent;
    }

    final q = questions[index];
    final isAnswered = selectedAnswers.containsKey(q.id);

    if (isCurrent || isAnswered) {
      return statusColor.withValues(alpha: 0.12);
    }
    return Colors.transparent;
  }
}
