import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../models/test_mode.dart';
import '../state/purchase_test_screen_state.dart';
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
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: context.x.l10n.buy,
    ),
    body: ListView(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: TestDescriptionWidget(
            test: TestModel(id: 1, name: 'Test 1', description: 'Description 1', price: 10000),
            onPressLike: onPressLike,
            onPressShare: onPressShare,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 260,
          child: PageView.builder(
            clipBehavior: .none,
            controller: pageController,
            itemCount: 10,
            onPageChanged: (i) => currentTest.value = i,
            itemBuilder: (context, index) => Padding(
              padding: const .symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.x.colors.cardBackground2,
                  borderRadius: .circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.x.colors.black.withValues(alpha: .08),
                      offset: const Offset(0, 12),
                      blurRadius: 56,
                    ),
                    BoxShadow(color: context.x.colors.black.withValues(alpha: .05), offset: .zero, blurRadius: 3),
                  ],
                ),
                // child: Padding(
                //   padding: const .only(left: 14, right: 14, top: 12),
                //   child: MyTestItemWidget(test: [index]),
                // ),
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
              builder: (context, current, child) => PageIndicator(selectedPage: current, totalPages: 10),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Text(context.x.l10n.paymentType, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18)),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: ValueListenableBuilder(
            valueListenable: selectedPayment,
            builder: (context, payment, child) => PaymentCard(
              imagePadding: payment.id != 0
                  ? const .symmetric(horizontal: 5, vertical: 16.5)
                  : const .symmetric(horizontal: 16, vertical: 8.5),
              hasShadow: true,
              title: payment.title,
              subtitle: payment.subtitle,
              image: Image.asset(payment.icon, package: 'ui', width: payment.type == .card ? 32 : 54),
              onTap: onSwitchPaymentPressed,
              action: IconButton(onPressed: onSwitchPaymentPressed, icon: const Icon(Icons.unfold_more)),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: ColoredBox(
      color: context.x.colors.dialogBackground,
      child: Padding(
        padding: .only(
          bottom: context.telegramWebApp.isSupported ? context.telegramWebApp.safeAreaInset.bottom.toDouble() : 0.0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.x.colors.scaffoldBackground,
            borderRadius: const .only(topLeft: .circular(16), topRight: .circular(16)),
            boxShadow: [
              BoxShadow(
                color: context.x.colors.black.withValues(alpha: .078),
                offset: const Offset(0, 3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    10000.formatUzs,
                    style: context.x.textStyle.sfW700s16.copyWith(fontSize: 24, color: context.x.colors.primary),
                    textAlign: .center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    borderRadius: 10,
                    onTap: onBuyPressed,
                    title: context.x.l10n.buy,
                    textStyle: context.x.textStyle.sfW500s16.copyWith(fontSize: 17, color: context.x.colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
