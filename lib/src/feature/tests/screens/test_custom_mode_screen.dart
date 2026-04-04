import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../state/test_custom_mode_screen_state.dart';
import '../widgets/test_result_item_widget.dart';
import '../widgets/test_title_box_widget.dart';

class TestCustomModeScreen extends StatefulWidget {
  const TestCustomModeScreen({super.key});

  @override
  State<TestCustomModeScreen> createState() => _TestCustomModeScreenState();
}

class _TestCustomModeScreenState extends TestCustomModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Custom Mode',
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const .symmetric(horizontal: 20, vertical: 16),
        child: CustomButton(onTap: onPressStartTest, title: 'Testni boshlash', borderRadius: 10),
      ),
    ),
    body: ListView(
      padding: const .all(16),
      children: [
        TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        const SizedBox(height: 16),
        Text('Custom rejim uchun testni sozlang:', style: context.x.textStyle.sfW500s22),
        const SizedBox(height: 10),
        Text(
          'Test harbir savol qancha vaqtda almashsin?',
          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
        ),
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
        const SizedBox(height: 24),
        Text(
          'Savollar va javob variantlari aralashtirilsinmi?',
          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<ShuffleOption?>(
          valueListenable: selectedShuffleOption,
          builder: (context, selected, _) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ShuffleOption.values
                .map(
                  (option) => TestTitleBoxWidget(
                    title: _shuffleLabel(context, option),
                    isSelected: option == selected,
                    onPressed: () => selectedShuffleOption.value = option,
                  ),
                )
                .toList(),
          ),
        ),
        ValueListenableBuilder<RangeValues>(
          valueListenable: questionRange,
          builder: (context, range, _) => Column(
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    '${range.start.toInt()}',
                    style: context.x.textStyle.sfW500s16.copyWith(
                      color: context.x.colors.gray,
                      fontWeight: .w700,
                      fontSize: 17,
                    ),
                  ),
                  Flexible(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: context.x.colors.primary,
                        inactiveTrackColor: context.x.colors.gray.withValues(alpha: .25),
                        thumbColor: context.x.colors.white,
                        overlayColor: context.x.colors.primary.withValues(alpha: 0.12),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      ),
                      child: RangeSlider(
                        values: range,
                        min: minQuestions.toDouble(),
                        max: totalQuestions.toDouble(),
                        onChanged: (value) {
                          final snapped = snapRange(value);
                          final minDistance = (totalQuestions - minQuestions) < questionStep
                              ? (totalQuestions - minQuestions).toDouble()
                              : questionStep.toDouble();
                          if (minDistance > 0 && snapped.end - snapped.start < minDistance) return;
                          questionRange.value = snapped;
                          RangeValues(snapped.start, snapped.end);
                        },
                      ),
                    ),
                  ),
                  Text(
                    '${range.end.toInt()}',
                    style: context.x.textStyle.sfW500s16.copyWith(
                      color: context.x.colors.gray,
                      fontWeight: .w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
  String _shuffleLabel(BuildContext context, ShuffleOption option) => switch (option) {
    .all => 'Barchasini aralashtirish',
    .none => 'Aralashtirilmasin',
    .questionsOnly => 'Faqat savollar',
    .answersOnly => 'Faqat javoblar',
  };
}
