import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../state/test_mode_screen_state.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({super.key});

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends TestModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: QuizAppBar(title: 'Rejim'),
    body: ListView(
      padding: .all(16),
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        ),
        const SizedBox(height: 16),
        Text('To’lov turi:', style: context.x.textStyle.w700s16.copyWith(fontSize: 22)),
      ],
    ),
  );
}
