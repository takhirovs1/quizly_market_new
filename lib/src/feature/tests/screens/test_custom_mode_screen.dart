import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class TestCustomModeScreen extends StatefulWidget {
  const TestCustomModeScreen({super.key});

  @override
  State<TestCustomModeScreen> createState() => _TestCustomModeScreenState();
}

class _TestCustomModeScreenState extends State<TestCustomModeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Custom Mode',
    ),
  );
}
