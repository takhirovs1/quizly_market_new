import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';
import 'dart:ui';

import '../../../common/constant/config.dart';
import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../bloc/test_view.dart';
import '../state/test_solving_screen_state.dart';
import '../widgets/solving_option_item_widget.dart';
import '../widgets/test_mode_shimmer.dart';

class TestSolvingScreen extends StatefulWidget {
  const TestSolvingScreen({
    required this.testId,
    required this.startRange,
    required this.endRange,
    required this.timeOptionName,
    required this.shuffleOptionName,
    super.key,
  });

  final String testId;
  final int startRange;
  final int endRange;
  final String timeOptionName;
  final String shuffleOptionName;

  @override
  State<TestSolvingScreen> createState() => _TestSolvingScreenState();
}

class _TestSolvingScreenState extends TestSolvingScreenState {
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: BlocConsumer<TestView, TestViewState>(
      listener: (context, state) {
        if (state.detail != null && questions.isEmpty) {
          setState(initializeQuestions);
        }
      },
      builder: (context, state) {
        if (state.detail == null || questions.isEmpty) {
          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            appBar: _buildAppBar(context),
            body: const TestCustomModeShimmer(),
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
                  body: ValueListenableBuilder<int>(
                    valueListenable: currentQuestionIndex,
                    builder: (context, index, _) {
                      if (index >= questions.length) return const SizedBox.shrink();
                      final question = questions[index];
                      return SingleChildScrollView(
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
                              child: _buildWebCardContent(context, state, index, question),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            // Mobile Layout
            return Scaffold(
              backgroundColor: context.x.colors.scaffoldBackground,
              appBar: _buildAppBar(context),
              bottomNavigationBar: _buildBottomBar(context),
              body: ValueListenableBuilder<int>(
                valueListenable: currentQuestionIndex,
                builder: (context, index, _) {
                  if (index >= questions.length) return const SizedBox.shrink();
                  final question = questions[index];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.x.l10n.questionLabel,
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            ),
                            Text(
                              '${index + 1}/${questions.length}',
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            ),
                          ],
                        ),
                        if (question.image != null && question.image!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Builder(
                              builder: (context) {
                                var imageUrl = question.image!;
                                if (!imageUrl.startsWith('http') && Config.apiBaseUrl.isNotEmpty) {
                                  final base = Config.apiBaseUrl.endsWith('/')
                                      ? Config.apiBaseUrl.substring(0, Config.apiBaseUrl.length - 1)
                                      : Config.apiBaseUrl;
                                  final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
                                  imageUrl = '$base$path';
                                }
                                return Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(question.text ?? '', style: context.x.textStyle.sfW600s16.copyWith(fontSize: 18)),
                        const SizedBox(height: 24),
                        ValueListenableBuilder<bool>(
                          valueListenable: isAnswerChecked,
                          builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
                            valueListenable: selectedOption,
                            builder: (context, selected, _) {
                              return Column(
                                spacing: 12,
                                children: (question.options ?? []).map((option) {
                                  return SolvingOptionItemWidget(
                                    option: option,
                                    isSelected: selected == option,
                                    isChecked: checked,
                                    onTap: () => onOptionSelected(option),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ),
  );

  Widget _buildWebCardContent(BuildContext context, TestViewState state, int index, DemoQuestion question) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header Row: Title & Progress on left, Timer & Finish Button on right
      Row(
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
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (index + 1) / questions.length,
                          backgroundColor: context.x.colors.gray.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(context.x.colors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${index + 1}/${questions.length}',
                      style: context.x.textStyle.sfW600s16.copyWith(
                        color: context.x.colors.gray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                  final showTimer = questionTimeSeconds > 0 || checked;
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
      ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Builder(
              builder: (context) {
                var imageUrl = question.image!;
                if (!imageUrl.startsWith('http') && Config.apiBaseUrl.isNotEmpty) {
                  final base = Config.apiBaseUrl.endsWith('/')
                      ? Config.apiBaseUrl.substring(0, Config.apiBaseUrl.length - 1)
                      : Config.apiBaseUrl;
                  final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
                  imageUrl = '$base$path';
                }
                return Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 320,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      ],
      Text(
        question.text ?? '',
        style: context.x.textStyle.sfW600s16.copyWith(fontSize: 20, height: 1.45, color: context.x.colors.text),
      ),
      const SizedBox(height: 28),
      ValueListenableBuilder<bool>(
        valueListenable: isAnswerChecked,
        builder: (context, checked, _) => ValueListenableBuilder<DemoOption?>(
          valueListenable: selectedOption,
          builder: (context, selected, _) => Column(
            spacing: 12,
            children: (question.options ?? []).map((option) {
              return SolvingOptionItemWidget(
                option: option,
                isSelected: selected == option,
                isChecked: checked,
                onTap: () => onOptionSelected(option),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 32),
      _buildNextButtonWidget(context),
    ],
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => PreferredSize(
    preferredSize: Size.fromHeight((context.telegramWebApp.safeAreaInset.top.toDouble()) + 56),
    child: ValueListenableBuilder<bool>(
      valueListenable: isAnswerChecked,
      builder: (context, checked, _) {
        final showTimer = questionTimeSeconds > 0 || checked;
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
    child: Padding(padding: const EdgeInsets.all(20), child: _buildNextButtonWidget(context)),
  );
}
