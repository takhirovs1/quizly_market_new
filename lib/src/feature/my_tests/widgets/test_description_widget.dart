import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/test_mode.dart';

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
          Expanded(child: Text(test.title, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 20))),
          GestureDetector(
            onTap: onPressShare,
            child: Assets.lib.vectors.share.svg(
              package: 'ui',
              colorFilter: .mode(ThemeColors.of(context).text, .srcATop),
            ),
          ),
          GestureDetector(
            onTap: onPressLike,
            child: Icon(Icons.favorite_border, color: ThemeColors.of(context).text),
          ),
        ],
      ),
      Text(test.author, style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText)),
      Text(
        test.description,
        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
      ),
    ],
  );
}
