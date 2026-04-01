import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../state/test_mode_screen_state.dart';
import '../widgets/test_mode_item_widget.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({super.key});

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends TestModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Rejim',
    ),
    body: ListView(
      padding: const .all(16),
      children: [
        TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        const SizedBox(height: 16),
        Text('Rejimni tanlang:', style: context.x.textStyle.sfW500s22),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: testModes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) => TestModeItemWidget(
            title: testModes[index].title,
            description: testModes[index].description,
            image: testModes[index].image.svg(
              package: 'ui',
              width: 32,
              height: 32,
              colorFilter: .mode(context.x.colors.white, .srcATop),
            ),
            onPressed: () => onPressTestMode(testModes[index]),
          ),
        ),
      ],
    ),
  );
}
