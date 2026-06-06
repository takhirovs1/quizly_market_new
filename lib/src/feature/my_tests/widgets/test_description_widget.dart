import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/test_model.dart';

class TestDescriptionWidget extends StatelessWidget {
  const TestDescriptionWidget({required this.test, required this.onPressShare, required this.onPressLike, super.key});
  final TestModel test;
  final VoidCallback onPressShare;
  final VoidCallback onPressLike;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: .start,
    spacing: 1,
    children: [
      Row(
        crossAxisAlignment: .start,
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              test.name ?? '',
              style: context.x.textStyle.sfW700s16.copyWith(fontSize: 20),
              maxLines: 2,
              overflow: .ellipsis,
            ),
          ),
          IconButton(
            onPressed: onPressShare,
            icon: Assets.lib.vectors.share.svg(
              package: 'ui',
              colorFilter: .mode(ThemeColors.of(context).text, .srcATop),
            ),
          ),
          IconButton(
            onPressed: onPressLike,
            icon: Icon(
              test.isLiked == true ? Icons.favorite : Icons.favorite_border,
              color: test.isLiked == true ? context.x.colors.primary : ThemeColors.of(context).text,
            ),
          ),
        ],
      ),
      Text(
        test.description ?? '',
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          if (test.createdBy != null && test.createdBy.toString().isNotEmpty) ...[
            Text(
              test.createdBy.toString(),
              style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
            ),
            Padding(
              padding: const .symmetric(horizontal: 8),
              child: Text(
                '•',
                style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
              ),
            ),
          ],
          Text(
            context.x.l10n.questionAmountText(test.questionCount ?? 0),
            style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
          ),
        ],
      ),
    ],
  );
}
