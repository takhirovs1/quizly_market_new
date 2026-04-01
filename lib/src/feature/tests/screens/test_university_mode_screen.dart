import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../state/test_university_mode_screen.dart';
import '../widgets/test_title_box_widget.dart';

class TestUniversityModeScreen extends StatefulWidget {
  const TestUniversityModeScreen({super.key});

  @override
  State<TestUniversityModeScreen> createState() => _TestUniversityModeScreenState();
}

class _TestUniversityModeScreenState extends TestUniversityModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'University Mode',
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const .all(20),
        child: CustomButton(onTap: onPressStartTest, title: 'Testni boshlash', borderRadius: 10),
      ),
    ),
    body: ListView(
      padding: const .all(16),
      children: [
        TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        const SizedBox(height: 14),
        Text('University rejim uchun testni sozlang:', style: context.x.textStyle.sfW500s22),
        const SizedBox(height: 10),
        Text('Testning umumiy vaqti:', style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: selectedQuestionTime,
          builder: (context, value, child) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < questionTimeOptions.length; i++)
                TestTitleBoxWidget(
                  title: questionTimeOptions[i].label,
                  onPressed: () => selectedQuestionTime.value = questionTimeOptions[i],
                  isSelected: value == questionTimeOptions[i],
                ),
            ],
          ),
        ),
        Text(
          '100 ta savol orasidan 25 tasi almashib tushadi.',
          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 14),
        Text('Javoblar tarixi:', style: context.x.textStyle.sfW500s22),
      ],
    ),
  );
}
