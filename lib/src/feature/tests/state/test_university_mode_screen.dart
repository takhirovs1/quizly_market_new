import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/models/test_model.dart';
import '../bloc/test_view.dart';
import '../model/test_request_response_models.dart';
import '../model/test_result_response_model.dart';
import '../screens/test_university_mode_screen.dart';

abstract class TestUniversityModeScreenState extends State<TestUniversityModeScreen> {
  late final TestView cubit;
  late final ValueNotifier<QuestionTimeOption?> selectedQuestionTime;
  late final ValueNotifier<bool> isStartingTest;
  final TestModel test = TestModel(id: '1', description: 'O’zbekiston tarixi bo‘yicha test savollari', price: 20000);
  final List<TestResultResponseModel>? result = [
    TestResultResponseModel(
      id: 1,
      userId: '1',
      testId: 1,
      purchaseId: 1,
      status: 'completed',
      correctCount: 10,
      totalQuestions: 10,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      finishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      timeSpentSec: 300,
      skipCount: 2,
      mode: 'university',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TestResultResponseModel(
      id: 2,
      userId: '2',
      testId: 2,
      purchaseId: 2,
      status: 'completed',
      correctCount: 8,
      totalQuestions: 10,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      finishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      timeSpentSec: 300,
      skipCount: 2,
      mode: 'university',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TestResultResponseModel(
      id: 3,
      userId: '3',
      testId: 3,
      purchaseId: 3,
      status: 'completed',
      correctCount: 6,
      totalQuestions: 10,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      finishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      timeSpentSec: 300,
      skipCount: 2,
      mode: 'university',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TestResultResponseModel(
      id: 4,
      userId: '4',
      testId: 4,
      purchaseId: 4,
      status: 'completed',
      correctCount: 4,
      totalQuestions: 10,
      startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      finishedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      timeSpentSec: 300,
      skipCount: 2,
      mode: 'university',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];
  final List<QuestionTimeOption> questionTimeOptions = [.seconds30, .seconds45, .hour1];

  Future<void> onPressStartTest() async {
    final testId = cubit.state.detail?.id ?? test.id;
    if (testId == null) return;

    if (isStartingTest.value) return;
    isStartingTest.value = true;

    try {
      final response = await cubit.startAttempt(testId, const StartAttemptRequest(mode: 'university'));
      final attemptId = response.attemptId;
      final detail = cubit.state.detail;
      final lastAttempt = result?.firstOrNull;
      if (attemptId.isNotEmpty && mounted) {
        context.octopus.push(
          Routes.testResult,
          arguments: {
            'id': testId,
            'attempt_id': attemptId,
            if (detail?.name != null) 'name': detail!.name!,
            if (detail?.description != null) 'description': detail!.description!,
            if (detail?.academicYear != null) 'academic_year': detail!.academicYear!,
            if (detail?.semester != null) 'semester': detail!.semester!.toString(),
            if (detail?.questionCount != null) 'question_count': detail!.questionCount!.toString(),
            if (lastAttempt != null) ...{
              'last_attempt_correct': lastAttempt.correctCount.toString(),
              'last_attempt_total': lastAttempt.totalQuestions.toString(),
              'last_attempt_time': lastAttempt.timeSpentSec.toString(),
              'last_attempt_date': lastAttempt.createdAt?.toIso8601String() ?? '',
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

  void onPressLike() {}
  void onPressShare() {
    context.shareTest(
      'Example test',
      'QuizlyMarket',
      'Example test description, Example test description, Example test description',
      '100000',
      '100',
    );
  }

  @override
  void initState() {
    super.initState();
    cubit = context.read<TestView>();
    isStartingTest = ValueNotifier<bool>(false);
    selectedQuestionTime = ValueNotifier(null);
  }

  @override
  void dispose() {
    isStartingTest.dispose();
    selectedQuestionTime.dispose();
    super.dispose();
  }
}
