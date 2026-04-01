import 'package:ui/ui.dart';

import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/models/test_mode.dart';
import '../screens/test_university_mode_screen.dart';

abstract class TestUniversityModeScreenState extends State<TestUniversityModeScreen> {
  late final ValueNotifier<QuestionTimeOption?> selectedQuestionTime;
  final TestModel test = TestModel(
    id: 1,
    title: 'O’zbekistonning eng yangi tarixi fanidan testlar',
    description: 'O’zbekiston tarixi bo‘yicha test savollari',
    author: 'Toshkent Davlat Iqtisodiyot Universiteti',
    price: 20000,
    questions: [],
  );
  final List<QuestionTimeOption> questionTimeOptions = [
    .seconds30, .seconds45, .seconds45
  ];
  void onPressStartTest() {}
  void onPressLike() {}
  void onPressShare() {}
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
