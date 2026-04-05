import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/test_result_screen_state.dart';
import '../widgets/test_result_item_widget.dart';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({super.key});

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends TestResultScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Result',
    ),
    body: ListView(
      padding: const .all(16),
      children: [
        // Assets.lib.images.testResult.image(width: 100, height: 100),
        Text('University rejim uchun testni sozlang:', style: context.x.textStyle.sfW500s22, textAlign: .center),
        const SizedBox(height: 12),
        Text(
          'Alfraganus, Iqtisodiyot sirtqi 2-kurs 2-semistr 100 ta savoldan 25 donasi yechildi',
          style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.gray),
          textAlign: .center,
        ),
        const SizedBox(height: 20),
        TestAttemptWidget(result: result?.first, backgroundColor: context.x.colors.transparent),
        const SizedBox(height: 20),
        if (result != null && result!.isNotEmpty) ...[
          Text('Javoblar tarixi:', style: context.x.textStyle.sfW500s16),
          const SizedBox(height: 8),
          for (final result in result!)
            Padding(
              padding: const .only(bottom: 8),
              child: TestAttemptWidget(result: result),
            ),
        ],
      ],
    ),
  );
}
