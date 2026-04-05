import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class TestGroupModeScreen extends StatefulWidget {
  const TestGroupModeScreen({super.key});

  @override
  State<TestGroupModeScreen> createState() => _TestGroupModeScreenState();
}

class _TestGroupModeScreenState extends State<TestGroupModeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Group Mode',
    ),
  );
}
