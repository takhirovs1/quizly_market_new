import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/models/test_model.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../bloc/test_view.dart';
import '../model/test_attempt_model.dart';
import '../state/test_custom_mode_screen_state.dart';
import '../widgets/test_mode_shimmer.dart';
import '../widgets/test_result_item_widget.dart';
import '../widgets/test_title_box_widget.dart';

class TestCustomModeScreen extends StatefulWidget {
  const TestCustomModeScreen({super.key});

  @override
  State<TestCustomModeScreen> createState() => _TestCustomModeScreenState();
}

class _TestCustomModeScreenState extends TestCustomModeScreenState {
  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          onBackPressed();
        }
      },
      child: BlocBuilder<TestView, TestViewState>(
        builder: (context, state) {
          final detail = state.detail;
          if (detail == null) {
            return Scaffold(
              backgroundColor: context.x.colors.scaffoldBackground,
              appBar: QuizAppBar(
                telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
                title: context.x.l10n.customModeTitle,
              ),
              body: const TestCustomModeShimmer(),
            );
          }

          final testModel = TestModel(
            id: detail.id,
            categoryId: detail.categoryId,
            name: detail.name ?? '',
            description: detail.description ?? '',
            price: detail.price,
            isPurchased: detail.isPurchased,
            isLiked: detail.isLiked,
            questionCount: detail.questionCount,
            createdAt: detail.createdAt,
            academicYear: detail.academicYear,
            semester: detail.semester,
            code: detail.code,
            isArchived: detail.isArchived,
            createdBy: detail.academicYear != null ? '${detail.academicYear}' : null, // Fallback if createdBy is empty
          );

          // Notify state that details are loaded to adjust totalQuestions/questionRange
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              onDetailLoaded(detail.questionCount ?? 0);
            }
          });

          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            appBar: QuizAppBar(
              telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
              title: context.x.l10n.customModeTitle,
            ),
            bottomNavigationBar: isMobile
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: CustomButton(
                        onTap: onPressStartTest,
                        title: context.x.l10n.startTestButton,
                        borderRadius: 10,
                      ),
                    ),
                  )
                : null,
            body: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 800) {
                  return _buildWebLayout(context, testModel, state.attempts);
                } else {
                  return _buildMobileLayout(context, testModel, state.attempts);
                }
              },
            ),
          );
        },
      ),
    );
  }

  // ─── MOBILE LAYOUT ────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, TestModel testModel, List<TestAttempt> attempts) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TestDescriptionWidget(
        test: testModel,
        onPressLike: onPressLike,
        onPressShare: onPressShare,
        onPressArchive: onPressArchive,
      ),
      const SizedBox(height: 24),
      Text(context.x.l10n.customModeSetup, style: context.x.textStyle.sfW500s22),
      const SizedBox(height: 16),
      Text(
        context.x.l10n.questionTimePrompt,
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<QuestionTimeOption?>(
        valueListenable: selectedQuestionTime,
        builder: (context, value, child) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < questionTimeOptions.length; i++)
              TestTitleBoxWidget(
                title: questionTimeOptions[i].label,
                onPressed: () {
                  context.telegramWebApp.hapticImpact(.light);
                  selectedQuestionTime.value = questionTimeOptions[i];
                },
                isSelected: value == questionTimeOptions[i],
              ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(context.x.l10n.shufflePrompt, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
      const SizedBox(height: 8),
      ValueListenableBuilder<ShuffleOption?>(
        valueListenable: selectedShuffleOption,
        builder: (context, selected, _) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ShuffleOption.values
              .map(
                (option) => TestTitleBoxWidget(
                  title: _shuffleLabel(context, option),
                  isSelected: option == selected,
                  onPressed: () {
                    context.telegramWebApp.hapticImpact(.light);
                    selectedShuffleOption.value = option;
                  },
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 24),
      Text(context.x.l10n.rangePrompt, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
      const SizedBox(height: 8),
      ValueListenableBuilder<RangeValues>(
        valueListenable: questionRange,
        builder: (context, range, _) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${range.start.toInt()}',
                  style: context.x.textStyle.sfW500s16.copyWith(
                    color: context.x.colors.gray,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Flexible(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: context.x.colors.primary,
                      inactiveTrackColor: context.x.colors.gray.withValues(alpha: .25),
                      thumbColor: context.x.colors.white,
                      overlayColor: context.x.colors.primary.withValues(alpha: 0.12),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    ),
                    child: RangeSlider(
                      values: range,
                      min: minQuestions.toDouble(),
                      max: totalQuestions.toDouble(),
                      onChanged: (value) {
                        final snappedValue = snapRange(value);
                        if (snappedValue != questionRange.value) {
                          context.telegramWebApp.hapticImpact(.light);
                          questionRange.value = snappedValue;
                        }
                      },
                    ),
                  ),
                ),
                Text(
                  '${range.end.toInt()}',
                  style: context.x.textStyle.sfW500s16.copyWith(
                    color: context.x.colors.gray,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      if (attempts.isNotEmpty) ...[
        Text(context.x.l10n.answersHistory, style: context.x.textStyle.sfW500s16),
        const SizedBox(height: 8),
        for (final attempt in attempts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AttemptItemWidget(attempt: attempt),
          ),
      ],
    ],
  );

  // ─── WEB LAYOUT ───────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context, TestModel testModel, List<TestAttempt> attempts) =>
      SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side: Test Description card and Attempt History
                    Expanded(
                      flex: 5,
                      child: attempts.isEmpty
                          ? _WebInfoCard(
                              testModel: testModel,
                              onPressLike: onPressLike,
                              onPressShare: onPressShare,
                              onPressArchive: onPressArchive,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _WebInfoCard(
                                  testModel: testModel,
                                  onPressLike: onPressLike,
                                  onPressShare: onPressShare,
                                  onPressArchive: onPressArchive,
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  context.x.l10n.answersHistory,
                                  style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 12),
                                for (final attempt in attempts)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _AttemptItemWidget(attempt: attempt),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 28),
                    // Right side: Custom Setup Configuration Card
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.x.colors.cardBackground2,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.x.colors.black.withValues(alpha: 0.06), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: context.x.colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(context.x.l10n.customModeSetup, style: context.x.textStyle.sfW500s22),
                            const SizedBox(height: 24),
                            Text(
                              context.x.l10n.questionTimePrompt,
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<QuestionTimeOption?>(
                              valueListenable: selectedQuestionTime,
                              builder: (context, value, child) => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (int i = 0; i < questionTimeOptions.length; i++)
                                    TestTitleBoxWidget(
                                      title: questionTimeOptions[i].label,
                                      onPressed: () {
                                        context.telegramWebApp.hapticImpact(.light);
                                        selectedQuestionTime.value = questionTimeOptions[i];
                                      },
                                      isSelected: value == questionTimeOptions[i],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.x.l10n.shufflePrompt,
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<ShuffleOption?>(
                              valueListenable: selectedShuffleOption,
                              builder: (context, selected, _) => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ShuffleOption.values
                                    .map(
                                      (option) => TestTitleBoxWidget(
                                        title: _shuffleLabel(context, option),
                                        isSelected: option == selected,
                                        onPressed: () {
                                          context.telegramWebApp.hapticImpact(.light);
                                          selectedShuffleOption.value = option;
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.x.l10n.rangePrompt,
                              style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<RangeValues>(
                              valueListenable: questionRange,
                              builder: (context, range, _) => Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${range.start.toInt()}',
                                        style: context.x.textStyle.sfW500s16.copyWith(
                                          color: context.x.colors.gray,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Flexible(
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 6,
                                            activeTrackColor: context.x.colors.primary,
                                            inactiveTrackColor: context.x.colors.gray.withValues(alpha: .25),
                                            thumbColor: context.x.colors.white,
                                            overlayColor: context.x.colors.primary.withValues(alpha: 0.12),
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                                          ),
                                          child: RangeSlider(
                                            values: range,
                                            min: minQuestions.toDouble(),
                                            max: totalQuestions.toDouble(),
                                            onChanged: (value) {
                                              final snappedValue = snapRange(value);
                                              if (snappedValue != questionRange.value) {
                                                context.telegramWebApp.hapticImpact(.light);
                                                questionRange.value = snappedValue;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${range.end.toInt()}',
                                        style: context.x.textStyle.sfW500s16.copyWith(
                                          color: context.x.colors.gray,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            CustomButton(
                              onTap: onPressStartTest,
                              title: context.x.l10n.startTestButton,
                              borderRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  String _shuffleLabel(BuildContext context, ShuffleOption option) => switch (option) {
    ShuffleOption.all => context.x.l10n.allShuffleOption,
    ShuffleOption.none => context.x.l10n.noneShuffleOption,
    ShuffleOption.questionsOnly => context.x.l10n.questionsOnlyShuffleOption,
    ShuffleOption.answersOnly => context.x.l10n.answersOnlyShuffleOption,
  };
}

class _AttemptItemWidget extends StatelessWidget {
  const _AttemptItemWidget({required this.attempt});
  final TestAttempt attempt;

  String _formatDuration(int timeSpentSec) {
    final duration = Duration(seconds: timeSpentSec);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).abs();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final correct = attempt.correctAnswers;
    final total = attempt.totalQuestions;
    final wrong = (total - correct).clamp(0, total);
    const skipped = 0; // TestAttempt does not store skipped count

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: context.x.colors.bannerBackground),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(attempt.createdAt.toLocal()),
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(attempt.createdAt.toLocal()),
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.vectors.correct.svg(package: 'ui'),
              leadingTitle: context.x.l10n.correctLabel,
              trailingTitle: '$correct ta',
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.vectors.wrong.svg(package: 'ui'),
              leadingTitle: context.x.l10n.wrongLabel,
              trailingTitle: '$wrong ta',
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.vectors.timer.svg(package: 'ui'),
              leadingTitle: context.x.l10n.skippedLabel,
              trailingTitle: '$skipped ta',
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.vectors.timer2.svg(package: 'ui'),
              leadingTitle: context.x.l10n.timeLabel,
              trailingTitle: _formatDuration(attempt.timeSpent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultInfoRow extends StatelessWidget {
  const _ResultInfoRow({required this.leadingIcon, required this.leadingTitle, required this.trailingTitle});

  final Widget leadingIcon;
  final String leadingTitle;
  final String trailingTitle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        spacing: 12,
        children: [
          leadingIcon,
          Text(
            leadingTitle,
            style: context.x.textStyle.sfW500s16.copyWith(
              color: context.x.colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      Expanded(child: DottedDivider(color: context.x.colors.gray)),
      Text(
        trailingTitle,
        style: context.x.textStyle.sfW500s16.copyWith(
          color: context.x.colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _WebInfoCard extends StatelessWidget {
  const _WebInfoCard({
    required this.testModel,
    required this.onPressLike,
    required this.onPressShare,
    this.onPressArchive,
  });

  final TestModel testModel;
  final VoidCallback onPressLike;
  final VoidCallback onPressShare;
  final VoidCallback? onPressArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [BoxShadow(color: colors.black.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient banner header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'QuizlyMarket',
                        style: context.x.textStyle.sfW600s16.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.x.l10n.enterTest,
                        style: context.x.textStyle.sfW600s16.copyWith(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: TestDescriptionWidget(
              test: testModel,
              onPressLike: onPressLike,
              onPressShare: onPressShare,
              onPressArchive: onPressArchive,
            ),
          ),
        ],
      ),
    );
  }
}
