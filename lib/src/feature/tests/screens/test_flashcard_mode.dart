import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class TestFlashcardMode extends StatefulWidget {
  const TestFlashcardMode({super.key});

  @override
  State<TestFlashcardMode> createState() => _TestFlashcardModeState();
}

class _TestFlashcardModeState extends State<TestFlashcardMode> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Flashcard Mode',
    ),
  );
}
