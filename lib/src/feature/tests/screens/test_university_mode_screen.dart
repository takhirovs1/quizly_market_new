import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../bloc/test_view.dart';
import '../model/test_attempt_model.dart';
import '../state/test_university_mode_state.dart';
import '../widgets/test_mode_shimmer.dart';
import '../widgets/test_result_item_widget.dart';
import '../widgets/test_title_box_widget.dart';

class TestUniversityModeScreen extends StatefulWidget {
  const TestUniversityModeScreen({super.key});

  @override
  State<TestUniversityModeScreen> createState() => _TestUniversityModeScreenState();
}

class _TestUniversityModeScreenState extends TestUniversityModeScreenState {
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
                title: context.x.l10n.universityModeTitle,
              ),
              bottomNavigationBar: isMobile
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          highlightColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF475569)
                              : const Color(0xFFF1F5F9),
                          child: const ShimmerBox(width: double.infinity, height: 48, radius: 10),
                        ),
                      ),
                    )
                  : null,
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
            createdBy: detail.academicYear != null ? '${detail.academicYear}' : null,
          );

          return Scaffold(
            backgroundColor: context.x.colors.scaffoldBackground,
            appBar: QuizAppBar(
              telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
              title: context.x.l10n.universityModeTitle,
            ),
            bottomNavigationBar: isMobile
                ? SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isStartingTest,
                        builder: (context, loading, _) => CustomButton(
                          onTap: onPressStartTest,
                          title: context.x.l10n.startTestButton,
                          borderRadius: 10,
                          isLoading: loading,
                        ),
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
      Text(context.x.l10n.universityModeSetup, style: context.x.textStyle.sfW500s22),
      const SizedBox(height: 16),
      Text(context.x.l10n.totalTestTime, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
      const SizedBox(height: 8),
      ValueListenableBuilder<Duration>(
        valueListenable: selectedTotalTime,
        builder: (context, value, child) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < totalTimeOptions.length; i++)
              TestTitleBoxWidget(
                title: _formatDurationOption(context, totalTimeOptions[i]),
                onPressed: () {
                  context.telegramWebApp.hapticImpact(.light);
                  selectedTotalTime.value = totalTimeOptions[i];
                },
                isSelected: value == totalTimeOptions[i],
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        context.x.l10n.totalQuestionsCount,
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<int?>(
        valueListenable: selectedQuestionCount,
        builder: (context, value, child) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < questionCountOptions.length; i++)
              TestTitleBoxWidget(
                title: _formatQuestionCountOption(context, questionCountOptions[i]),
                onPressed: () {
                  context.telegramWebApp.hapticImpact(.light);
                  selectedQuestionCount.value = questionCountOptions[i];
                },
                isSelected: value == questionCountOptions[i],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left side: Test Description card
                        Expanded(
                          flex: 5,
                          child: _WebInfoCard(
                            testModel: testModel,
                            onPressLike: onPressLike,
                            onPressShare: onPressShare,
                            onPressArchive: onPressArchive,
                          ),
                        ),
                        const SizedBox(width: 28),
                        // Right side: University Setup Configuration Card
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
                                Text(context.x.l10n.universityModeSetup, style: context.x.textStyle.sfW500s22),
                                const SizedBox(height: 24),
                                Text(
                                  context.x.l10n.totalTestTime,
                                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<Duration>(
                                  valueListenable: selectedTotalTime,
                                  builder: (context, value, child) => Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (int i = 0; i < totalTimeOptions.length; i++)
                                        TestTitleBoxWidget(
                                          title: _formatDurationOption(context, totalTimeOptions[i]),
                                          onPressed: () {
                                            context.telegramWebApp.hapticImpact(.light);
                                            selectedTotalTime.value = totalTimeOptions[i];
                                          },
                                          isSelected: value == totalTimeOptions[i],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  context.x.l10n.totalQuestionsCount,
                                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<int?>(
                                  valueListenable: selectedQuestionCount,
                                  builder: (context, value, child) => Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (int i = 0; i < questionCountOptions.length; i++)
                                        TestTitleBoxWidget(
                                          title: _formatQuestionCountOption(context, questionCountOptions[i]),
                                          onPressed: () {
                                            context.telegramWebApp.hapticImpact(.light);
                                            selectedQuestionCount.value = questionCountOptions[i];
                                          },
                                          isSelected: value == questionCountOptions[i],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 36),
                                ValueListenableBuilder<bool>(
                                  valueListenable: isStartingTest,
                                  builder: (context, loading, _) => CustomButton(
                                    onTap: onPressStartTest,
                                    title: context.x.l10n.startTestButton,
                                    borderRadius: 12,
                                    isLoading: loading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (attempts.isNotEmpty) ...[
                    const SizedBox(height: 36),
                    Text(context.x.l10n.answersHistory, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18)),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, attemptConstraints) {
                        final cardWidth = attemptConstraints.maxWidth >= 800
                            ? (attemptConstraints.maxWidth - 28) / 2
                            : attemptConstraints.maxWidth;
                        return Wrap(
                          spacing: 28,
                          runSpacing: 16,
                          children: attempts
                              .map(
                                (attempt) => SizedBox(
                                  width: cardWidth,
                                  child: _AttemptItemWidget(attempt: attempt),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

  String _formatDurationOption(BuildContext context, Duration duration) => duration.inMinutes < 60
      ? context.x.l10n.minutesText(duration.inMinutes)
      : context.x.l10n.hourText(duration.inHours);

  String _formatQuestionCountOption(BuildContext context, int? count) =>
      count == null ? context.x.l10n.allOption : context.x.l10n.countTaText(count);
}

class _WebInfoCard extends StatelessWidget {
  const _WebInfoCard({
    required this.testModel,
    required this.onPressLike,
    required this.onPressShare,
    required this.onPressArchive,
  });

  final TestModel testModel;
  final VoidCallback onPressLike;
  final VoidCallback onPressShare;
  final VoidCallback onPressArchive;

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
    final skipped = attempt.skipCount;
    final wrong = (total - correct - skipped).clamp(0, total);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: context.x.colors.textFieldBackground),
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
            const SizedBox(height: 8),
            _ResultInfoRow(
              leadingIcon: Assets.lib.icon.correct.svg(package: 'ui'),
              leadingTitle: context.x.l10n.correctLabel,
              trailingTitle: context.x.l10n.countTaText(correct),
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.icon.wrong.svg(package: 'ui'),
              leadingTitle: context.x.l10n.wrongLabel,
              trailingTitle: context.x.l10n.countTaText(wrong),
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.icon.timer.svg(package: 'ui'),
              leadingTitle: context.x.l10n.skippedLabel,
              trailingTitle: context.x.l10n.countTaText(skipped),
            ),
            _ResultInfoRow(
              leadingIcon: Assets.lib.icon.timer2.svg(package: 'ui'),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 14, height: 14, child: leadingIcon),
        const SizedBox(width: 8),
        Text(leadingTitle, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text)),
        Expanded(child: DottedDivider(color: context.x.colors.gray.withValues(alpha: 0.3))),
        Text(
          trailingTitle,
          style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.text, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
