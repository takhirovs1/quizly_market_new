import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../tests/widgets/latex_text_widget.dart';
import '../../tests/widgets/question_image_widget.dart';
import '../models/demo_test_model.dart';

/// Read-only preview of one question and its options, used inside the
/// questions carousel (purchase preview + upload confirm). Renders both LaTeX
/// math and images for the question and for every option.
class QuestionCardWidget extends StatelessWidget {
  const QuestionCardWidget({required this.question, required this.languageCode, super.key});

  final DemoQuestion question;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final hasQuestionImage = question.image != null && question.image!.isNotEmpty;
    final hasQuestionText = question.text != null && question.text!.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (hasQuestionImage) ...[
            QuestionImageWidget(imageUrl: question.image!, maxHeight: 180, borderRadius: 12),
            const SizedBox(height: 12),
          ],
          if (hasQuestionText)
            LatexTextWidget(
              text: question.text!,
              style: context.x.textStyle.sfW500s16.copyWith(fontSize: 16, height: 1.4, color: colors.text),
              maxLines: 4,
              overflow: .ellipsis,
            ),
          const SizedBox(height: 12),
          if (question.options != null)
            ...question.options!.asMap().entries.map((entry) => _OptionRow(index: entry.key, option: entry.value)),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.index, required this.option});

  final int index;
  final DemoOption option;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isCorrect = option.isCorrect ?? false;
    final hasImage = option.image != null && option.image!.isNotEmpty;
    final hasText = option.text != null && option.text!.isNotEmpty;

    final accent = isCorrect ? const Color(0xFF43C04D) : colors.bannerSecondaryText.withValues(alpha: 0.15);
    final letter = index < _letters.length ? _letters[index] : '${index + 1}';

    return Padding(
      padding: const .only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isCorrect ? const Color(0xFF43C04D).withValues(alpha: 0.08) : colors.cardBackground2,
          border: Border.all(color: accent, width: isCorrect ? 1.5 : 1),
          borderRadius: .circular(12),
        ),
        child: Padding(
          padding: const .symmetric(vertical: 12, horizontal: 14),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              // Letter badge (turns into a check when this option is correct).
              Container(
                width: 24,
                height: 24,
                alignment: .center,
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFF43C04D) : colors.primary.withValues(alpha: 0.12),
                  shape: .circle,
                ),
                child: isCorrect
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(letter, style: context.x.textStyle.sfW600s16.copyWith(color: colors.primary, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (hasImage) ...[
                      QuestionImageWidget(imageUrl: option.image!, maxHeight: 120, borderRadius: 8),
                      if (hasText) const SizedBox(height: 6),
                    ],
                    if (hasText)
                      LatexTextWidget(
                        text: option.text!,
                        style: context.x.textStyle.sfW400s14.copyWith(color: colors.text, height: 1.35),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
