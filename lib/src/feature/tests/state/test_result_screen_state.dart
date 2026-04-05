import 'package:ui/ui.dart';

import '../model/test_result_response_model.dart';
import '../screens/test_result_screen.dart';

abstract class TestResultScreenState extends State<TestResultScreen> {
  final List<TestResultResponseModel>? result = [
    TestResultResponseModel(
      id: 1,
      userId: '1',
      testId: 1,
      purchaseId: 1,
      status: 'completed',
      correctCount: 10,
      totalQuestions: 10,
      startedAt: DateTime.now().subtract(Duration(minutes: 10)),
      finishedAt: DateTime.now().subtract(Duration(minutes: 5)),
      timeSpentSec: 300,
      skipCount: 2,
      mode: 'university',
      createdAt: DateTime.now().subtract(Duration(minutes: 10)),
      updatedAt: DateTime.now().subtract(Duration(minutes: 10)),
    ),
  ];
}
