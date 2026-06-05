import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../models/test_mode.dart';

class MyTestCardItem extends StatelessWidget {
  const MyTestCardItem({
    required this.test,
    required this.onBuyButtonPressed,
    required this.onShareButtonPressed,
    super.key,
  });

  final TestModel test;
  final VoidCallback onBuyButtonPressed;
  final void Function(TestModel test) onShareButtonPressed;

  @override
  Widget build(BuildContext context) => TestCardWidget(
    title: test.name ?? '',
    companyName: test.categoryName ?? '',
    description: test.description ?? '',
    price: test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs,
    questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
    buyButtonText: test.isPurchased == true ? context.x.l10n.enterTest : context.x.l10n.buy,
    onBuyButtonPressed: onBuyButtonPressed,
    isFree: test.price == 0 || test.price == null,
    onShareButtonPressed: () => onShareButtonPressed(test),
  );
}
