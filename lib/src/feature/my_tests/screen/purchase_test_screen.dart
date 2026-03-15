import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../state/purchase_test_screen_state.dart';
import '../widgets/my_test_item_widget.dart';
import '../widgets/test_description_widget.dart';

class PurchaseTestScreen extends StatefulWidget {
  const PurchaseTestScreen({super.key});

  @override
  State<PurchaseTestScreen> createState() => _PurchaseTestScreenState();
}

class _PurchaseTestScreenState extends PurchaseTestScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: const QuizAppBar(title: 'Sotib olish'),
    body: ListView(
      padding: const .symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        const SizedBox(height: 28),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: pageController,
            itemCount: test.questions.length,
            onPageChanged: (i) => currentTest.value = i,
            itemBuilder: (context, index) => DecoratedBox(
              decoration: BoxDecoration(color: context.x.colors.white, borderRadius: .circular(24)),
              child: Padding(
                padding: const .symmetric(horizontal: 14, vertical: 12),
                child: MyTestItemWidget(test: test.questions[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: .center,
          children: [
            ValueListenableBuilder(
              valueListenable: currentTest,
              builder: (context, current, child) =>
                  PageIndicator(selectedPage: current, totalPages: test.questions.length),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Text('To’lov turi:', style: context.x.textStyle.w700s16.copyWith(fontSize: 22)),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: selectedPayment,
          builder: (context, payment, child) => PaymentCard(
            hasShadow: true,
            title: payment.title,
            subtitle: payment.subtitle,
            image: Image.asset(payment.icon, package: 'ui', width: payment.type == .card ? 32 : 54),
            onTap: onSwitchPaymentPressed,
            action: const Icon(Icons.unfold_more),
          ),
        ),
      ],
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: BoxDecoration(
        color: ThemeColors.of(context).white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                20000.formatUzs,
                style: context.x.textStyle.w700s16.copyWith(fontSize: 24, color: ThemeColors.of(context).primary),
                textAlign: .center,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(onTap: onBuyPressed, title: 'Sotib olish'),
            ),
          ],
        ),
      ),
    ),
  );
}
