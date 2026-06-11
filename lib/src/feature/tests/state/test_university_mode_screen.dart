import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/models/test_model.dart';
import '../model/test_result_response_model.dart';
import '../screens/test_university_mode_screen.dart';

abstract class TestUniversityModeScreenState extends State<TestUniversityModeScreen> {
  late final ValueNotifier<QuestionTimeOption?> selectedQuestionTime;
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
  void onPressStartTest() => context.octopus.push(Routes.testResult);

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
    selectedQuestionTime = ValueNotifier(null);
  }

  @override
  void dispose() {
    super.dispose();
    selectedQuestionTime.dispose();
  }
}
