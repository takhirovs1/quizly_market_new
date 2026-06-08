import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../models/test_model.dart';

class MyTestCardItem extends StatelessWidget {
  const MyTestCardItem({
    required this.test,
    required this.onBuyButtonPressed,
    required this.onShareButtonPressed,
    this.onLikeButtonPressed,
    super.key,
  });

  final TestModel test;
  final void Function(TestModel test) onBuyButtonPressed;
  final void Function(TestModel test) onShareButtonPressed;
  final void Function(TestModel test)? onLikeButtonPressed;

  @override
  Widget build(BuildContext context) => TestCardWidget(
    title: test.name ?? '',
    companyName: test.categoryName ?? '',
    description: test.description ?? '',
    price: test.isPurchased == true
        ? context.x.l10n.purchased
        : (test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs),
    questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
    buyButtonText: test.isPurchased == true ? context.x.l10n.enterTest : context.x.l10n.buy,
    onBuyButtonPressed: () => onBuyButtonPressed(test),
    isFree: test.price == 0 || test.price == null,
    isPurchased: test.isPurchased == true,
    onShareButtonPressed: () => onShareButtonPressed(test),
    isLiked: test.isLiked == true,
    onLikeButtonPressed: onLikeButtonPressed != null ? () => onLikeButtonPressed!(test) : null,
    textBought: context.x.l10n.textBought,
  );
}
