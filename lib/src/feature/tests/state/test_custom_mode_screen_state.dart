import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/router/pages.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/models/test_mode.dart';
import '../model/test_result_response_model.dart';
import '../screens/test_custom_mode_screen.dart';

abstract class TestCustomModeScreenState extends State<TestCustomModeScreen> {
  late final ValueNotifier<QuestionTimeOption?> selectedQuestionTime;
  late final ValueNotifier<ShuffleOption?> selectedShuffleOption;
  late final ValueNotifier<RangeValues> questionRange;
  int minQuestions = 0;
  int questionStep = 5;

  int get totalQuestions {
    final n = test.questions.length;
    return n > 0 ? n : 100;
  }

  final TestModel test = TestModel(
    id: 1,
    title: 'O’zbekistonning eng yangi tarixi fanidan testlar',
    description: 'O’zbekiston tarixi bo‘yicha test savollari',
    author: 'Toshkent Davlat Iqtisodiyot Universiteti',
    price: 20000,
    questions: [],
  );

  final List<QuestionTimeOption> questionTimeOptions = [
    .seconds15,
    .seconds30,
    .seconds45,
    .minute1,
    .minutes2,
    .minutes3,
  ];
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
  void onPressLike() {}
  void onPressShare() {}

  RangeValues snapRange(RangeValues values) {
    final min = minQuestions.toDouble();
    final max = totalQuestions.toDouble();
    if (max <= min) {
      final snappedRange = RangeValues(min, max);

      return snappedRange;
    }

    final available = max - min;
    final step = available < questionStep ? available : questionStep.toDouble();
    double snap(double v) => (step * (v / step).round()).toDouble();

    final start = snap(values.start).clamp(min, max - step);
    final end = snap(values.end).clamp(start + step, max);
    final snappedRange = RangeValues(start, end);
    return snappedRange;
  }

  RangeValues _coerceRange() {
    final min = minQuestions.toDouble();
    final max = totalQuestions.toDouble();
    if (max <= min) return RangeValues(min, max);

    return RangeValues(min, max);
  }

  void onPressStartTest() => context.octopus.push(Routes.testResult);

  @override
  void initState() {
    super.initState();
    selectedQuestionTime = ValueNotifier(null);
    selectedShuffleOption = ValueNotifier(null);
    questionRange = ValueNotifier<RangeValues>(_coerceRange());
  }

  @override
  void dispose() {
    selectedQuestionTime.dispose();
    selectedShuffleOption.dispose();
    super.dispose();
  }
}
