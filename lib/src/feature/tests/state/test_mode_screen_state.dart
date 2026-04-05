import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/router/pages.dart';
import '../../my_tests/models/test_mode.dart';
import '../model/test_mode_model.dart';
import '../screens/test_mode_screen.dart';

abstract class TestModeScreenState extends State<TestModeScreen> {
  final TestModel test = TestModel(id: 1, description: 'O’zbekiston tarixi bo‘yicha test savollari', price: 20000);

  final List<TestModeModel> testModes = [
    TestModeModel(
      id: 1,
      title: 'Custom',
      description: 'Test parametrlarini o’zingiz sozlab test yeching.',
      image: Assets.lib.vectors.personSelected,
      type: .custom,
    ),
    TestModeModel(
      id: 2,
      title: 'University',
      description: 'Universitet imtihon formatida test yeching.',
      image: Assets.lib.vectors.university,
      type: .university,
    ),
    TestModeModel(
      id: 3,
      title: 'Group',
      description: 'Do’stlar bilan bir vaqting o’zida test ishlash.',
      image: Assets.lib.vectors.group,
      type: .group,
    ),
    TestModeModel(
      id: 4,
      title: 'Flashcard',
      description: 'Savollarni kartochka orqali yodlash va tez takrorlash..',
      image: Assets.lib.vectors.flashcards,
      type: .flashcard,
    ),
  ];

  void onPressLike() {}
  void onPressShare() {}

  void onPressTestMode(TestModeModel testMode) => context.octopus.push(switch (testMode.type) {
    .custom => Routes.testCustomMode,
    .university => Routes.testUniversityMode,
    .group => Routes.testGroupMode,
    .flashcard => Routes.testFlashcardMode,
  });
}
