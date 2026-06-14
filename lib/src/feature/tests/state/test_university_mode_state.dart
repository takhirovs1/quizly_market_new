import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/test_view.dart';
import '../model/test_request_response_models.dart';
import '../screens/test_university_mode_screen.dart';

abstract class TestUniversityModeScreenState extends State<TestUniversityModeScreen> {
  late final TestView cubit;
  late final ValueNotifier<Duration> selectedTotalTime;
  late final ValueNotifier<int?> selectedQuestionCount;
  late final ValueNotifier<bool> isStartingTest;

  final List<Duration> totalTimeOptions = [
    const Duration(minutes: 30),
    const Duration(minutes: 45),
    const Duration(hours: 1),
  ];

  final List<int?> questionCountOptions = [15, 25, 35, 50, null];

  Future<void> onPressStartTest() async {
    final testId = cubit.state.detail?.id;
    if (testId == null) return;

    if (isStartingTest.value) return;
    isStartingTest.value = true;

    try {
      final response = await cubit.startAttempt(testId, const StartAttemptRequest(mode: 'university'));
      final attemptId = response.attemptId;
      final detail = cubit.state.detail;
      final lastAttempt = cubit.state.attempts.firstOrNull;
      if (attemptId.isNotEmpty && mounted) {
        context.octopus.push(
          Routes.testSolving,
          arguments: {
            'id': testId,
            'attemptId': attemptId,
            'start': '1',
            'end': (selectedQuestionCount.value ?? detail?.questionCount ?? 100).toString(),
            'time': selectedTotalTime.value.inMinutes.toString(),
            'shuffle': 'all',
            'mode': 'university',
            if (lastAttempt != null) ...{
              'lastAttemptCorrect': lastAttempt.correctAnswers.toString(),
              'lastAttemptTotal': lastAttempt.totalQuestions.toString(),
              'lastAttemptTime': lastAttempt.timeSpent.toString(),
              'lastAttemptDate': lastAttempt.createdAt.toIso8601String(),
              'lastAttemptSkip': lastAttempt.skipCount.toString(),
            },
          },
        );
      } else if (mounted) {
        context.x.showNotification(message: context.x.l10n.errorOccurred, isError: true);
      }
    } on Object catch (_) {
      if (mounted) {
        context.x.showNotification(message: context.x.l10n.errorOccurred, isError: true);
      }
    } finally {
      if (mounted) {
        isStartingTest.value = false;
      }
    }
  }

  void onPressLike() {
    final detail = cubit.state.detail;
    if (detail == null) return;
    final testId = detail.id;
    if (testId == null) return;
    cubit.toggleLike(testId);
  }

  void onPressShare() {
    final detail = cubit.state.detail;
    if (detail == null) return;
    context.shareTest(
      detail.name ?? '',
      'QuizlyMarket',
      detail.description ?? '',
      detail.price?.toString() ?? '0',
      detail.questionCount?.toString() ?? '0',
      code: detail.code,
    );
  }

  Future<void> onPressArchive() async {
    final detail = cubit.state.detail;
    if (detail == null) return;
    final testId = detail.id;
    if (testId == null) return;

    final wasArchived = detail.isArchived ?? false;
    context.telegramWebApp.hapticImpact(.light);
    try {
      await cubit.toggleArchive(testId);
      if (mounted) {
        final message = wasArchived
            ? context.x.l10n.testUnarchivedSuccessfully
            : context.x.l10n.testArchivedSuccessfully;
        context.x.showNotification(
          message: message,
          isError: false,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    } on Object catch (_) {
      if (mounted) {
        context.x.showNotification(
          message: context.x.l10n.errorOccurred,
          isError: true,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    }
  }

  void onBackPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.pop();
  }

  @override
  void initState() {
    super.initState();
    cubit = context.read<TestView>();
    isStartingTest = ValueNotifier<bool>(false);
    selectedTotalTime = ValueNotifier(totalTimeOptions.first);
    selectedQuestionCount = ValueNotifier(questionCountOptions.first);
    context.setupTelegramBackButton(onBackPressed);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    isStartingTest.dispose();
    selectedTotalTime.dispose();
    selectedQuestionCount.dispose();
    super.dispose();
  }
}
