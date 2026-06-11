import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../bloc/test_view.dart';
import '../screens/test_custom_mode_screen.dart';

abstract class TestCustomModeScreenState extends State<TestCustomModeScreen> {
  late final TestView cubit;
  late final ValueNotifier<QuestionTimeOption?> selectedQuestionTime;
  late final ValueNotifier<ShuffleOption?> selectedShuffleOption;
  late final ValueNotifier<RangeValues> questionRange;
  int minQuestions = 1;
  int questionStep = 5;

  int totalQuestions = 100;

  final List<QuestionTimeOption> questionTimeOptions = [
    QuestionTimeOption.seconds15,
    QuestionTimeOption.seconds30,
    QuestionTimeOption.seconds45,
    QuestionTimeOption.minute1,
    QuestionTimeOption.minutes2,
    QuestionTimeOption.minutes3,
  ];

  void onDetailLoaded(int count) {
    if (totalQuestions != count && count > 0) {
      totalQuestions = count;
      minQuestions = count >= 5 ? 1 : 0;
      final endVal = count.toDouble();
      final startVal = count >= 5 ? 1.0 : 0.0;
      questionRange.value = RangeValues(startVal, endVal);
    }
  }

  void onBackPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.navigate(Routes.home.name);
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

  RangeValues snapRange(RangeValues values) {
    final min = minQuestions.toDouble();
    final max = totalQuestions.toDouble();
    if (max - min < 5) {
      return RangeValues(min, max);
    }

    // Snap to nearest integer
    var start = values.start.roundToDouble();
    var end = values.end.roundToDouble();

    if (end - start < 5) {
      if (values.start != questionRange.value.start) {
        start = (end - 5).clamp(min, max);
      } else {
        end = (start + 5).clamp(min, max);
      }
    }

    return RangeValues(start.clamp(min, max), end.clamp(min, max));
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

  void onPressStartTest() => context.octopus.push(Routes.testResult);

  @override
  void initState() {
    super.initState();
    cubit = context.read<TestView>();

    // Default values: first option selected for both
    selectedQuestionTime = ValueNotifier(questionTimeOptions.first);
    selectedShuffleOption = ValueNotifier(ShuffleOption.values.first);

    final detail = cubit.state.detail;
    totalQuestions = detail?.questionCount ?? 100;
    minQuestions = totalQuestions >= 5 ? 1 : 0;

    questionRange = ValueNotifier<RangeValues>(RangeValues(minQuestions.toDouble(), totalQuestions.toDouble()));
    context.setupTelegramBackButton(onBackPressed);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    selectedQuestionTime.dispose();
    selectedShuffleOption.dispose();
    questionRange.dispose();
    super.dispose();
  }
}
