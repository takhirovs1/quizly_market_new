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

  List<TestModeModel> get testModes => [
    TestModeModel(
      id: 1,
      title: context.x.l10n.customModeTitle,
      description: context.x.l10n.customModeDesc,
      image: Assets.lib.vectors.personSelected,
      type: .custom,
    ),
    TestModeModel(
      id: 2,
      title: context.x.l10n.universityModeTitle,
      description: context.x.l10n.universityModeDesc,
      image: Assets.lib.vectors.university,
      type: .university,
    ),
    TestModeModel(
      id: 3,
      title: context.x.l10n.groupModeTitle,
      description: context.x.l10n.groupModeDesc,
      image: Assets.lib.vectors.group,
      type: .group,
    ),
    TestModeModel(
      id: 4,
      title: context.x.l10n.flashcardModeTitle,
      description: context.x.l10n.flashcardModeDesc,
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
        context.x.showNotification(message: message, isError: false);
      }
    } on Object catch (_) {
      if (mounted) {
        context.x.showNotification(message: context.x.l10n.errorOccurred, isError: true);
      }
    }
  }

  void onPressTestMode(TestModeModel testMode) => context.octopus.push(switch (testMode.type) {
    .custom => Routes.testCustomMode,
    .university => Routes.testUniversityMode,
    .group => Routes.testGroupMode,
    .flashcard => Routes.testFlashcardMode,
  });
}
