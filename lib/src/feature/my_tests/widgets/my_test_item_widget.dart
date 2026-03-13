import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/test_mode.dart';

class MyTestItemWidget extends StatelessWidget {
  const MyTestItemWidget({required this.test, required this.testCount, required this.currentTest, super.key});
  final QuestionModel test;
  final int testCount;
  final int currentTest;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(children: [Text(test.question, style: context.x.textStyle.w400s16.copyWith(fontSize: 17))]),
      const SizedBox(height: 6),
      for (int i = 0; i < test.answers.length; i++)
        Padding(
          padding: const .only(bottom: 6),
          child: _AnswerItem(answerModel: test.answers[i]),
        ),

      const SizedBox(height: 10),
      PageIndicator(selectedPage: currentTest, totalPages: testCount),
    ],
  );
}

class _AnswerItem extends StatelessWidget {
  const _AnswerItem({required this.answerModel});
  final AnswerModel answerModel;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: ThemeColors.of(context).white,
      border: Border.all(color: ThemeColors.of(context).gray),
      borderRadius: .circular(8),
    ),
    child: SizedBox(
      width: .infinity,
      child: Padding(
        padding: const .symmetric(vertical: 8, horizontal: 10),
        child: Text(answerModel.text, style: context.x.textStyle.w400s14, textAlign: .start),
      ),
    ),
  );
}
