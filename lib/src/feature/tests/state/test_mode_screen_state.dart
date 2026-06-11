import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/test_view.dart';
import '../model/test_mode_model.dart';
import '../screens/test_mode_screen.dart';

abstract class TestModeScreenState extends State<TestModeScreen> {
  late final TestView cubit;

  @override
  void initState() {
    cubit = context.read<TestView>();
    super.initState();
  }

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

  void onPressTestMode(TestModeModel testMode) => context.octopus.push(switch (testMode.type) {
    .custom => Routes.testCustomMode,
    .university => Routes.testUniversityMode,
    .group => Routes.testGroupMode,
    .flashcard => Routes.testFlashcardMode,
  });
}
