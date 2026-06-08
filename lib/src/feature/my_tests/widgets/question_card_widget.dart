import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/demo_test_model.dart';

class QuestionCardWidget extends StatelessWidget {
  const QuestionCardWidget({required this.question, required this.languageCode, super.key});
  final DemoQuestion question;
  final String languageCode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    children: [
      Text(
        question.text ?? '',
        style: context.x.textStyle.sfW500s16.copyWith(fontSize: 16),
        maxLines: 3,
        overflow: .ellipsis,
      ),
      const SizedBox(height: 12),
      if (question.options != null)
        ...question.options!.map(
          (option) => Padding(
            padding: const .only(bottom: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.x.colors.cardBackground2,
                border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.15)),
                borderRadius: .circular(12),
              ),
              child: SizedBox(
                width: .infinity,
                child: Padding(
                  padding: const .symmetric(vertical: 12, horizontal: 14),
                  child: Text(option.text ?? '', style: context.x.textStyle.sfW400s14),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
