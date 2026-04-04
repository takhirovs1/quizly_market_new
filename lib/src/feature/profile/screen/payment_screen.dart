import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/extension/string_extension.dart';
import '../state/payment_screen_state.dart';
import '../widget/payment_item_widget.dart';
import '../widget/payment_text_builder_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends PaymentScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    resizeToAvoidBottomInset: false,
    appBar: QuizAppBar(
      title: context.x.l10n.topUpUserBalance,
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: Padding(
      padding: const .symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: Text(
              context.x.l10n.paymentAmount,
              style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: CustomTextFiled(
              fillColor: context.x.colors.scaffoldBackground,
              enabledBorderColor: context.x.colors.gray,
              keyboardType: .number,
              focusNode: amountFocusNode,
              controller: amountController,
              style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.text),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
                UZSFormatter(),
              ],
              onChanged: (value) => selectedAmount.value = value,
              hintText: context.x.l10n.enterAmount,
              hintStyle: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.gray),

              suffixIcon: ValueListenableBuilder(
                valueListenable: amountController,
                builder: (context, value, child) => amountController.text.isNotEmpty
                    ? IconButton(
                        onPressed: onClearPressed,
                        icon: Icon(Icons.clear, color: context.x.colors.gray),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: ValueListenableBuilder<String?>(
              valueListenable: selectedAmount,
              builder: (context, value, child) {
                if (!isAmountOverLimit) return const SizedBox.shrink();
                return Padding(
                  padding: const .only(top: 4),
                  child: Row(
                    spacing: 4,
                    children: [
                      Icon(CupertinoIcons.info_circle_fill, size: 24, color: context.x.colors.error),
                      Text(
                        context.x.l10n.transferLimitRange,
                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView.separated(
              padding: const .symmetric(horizontal: 16),
              scrollDirection: .horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: defaultAmounts.length,
              itemBuilder: (context, index) => ValueListenableBuilder(
                valueListenable: selectedAmount,
                builder: (context, value, child) => PaymentItemWidget(
                  backgroundColor: context.x.colors.scaffoldBackground,
                  isSelected: value == defaultAmounts[index],
                  onTap: () {
                    onSelectAmount(defaultAmounts[index]);
                    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
                  },
                  child: Center(
                    child: Text(
                      defaultAmounts[index].toUZSString(),
                      style: context.x.textStyle.sfW500s16.copyWith(
                        color: value == defaultAmounts[index] ? context.x.colors.primary : context.x.colors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: Text(
              context.x.l10n.paymentType,
              style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const .symmetric(horizontal: 16),
              scrollDirection: .horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: paymentResponseModels.length,
              itemBuilder: (context, index) => ValueListenableBuilder(
                valueListenable: selectedPayment,
                builder: (context, value, child) => PaymentItemWidget(
                  width: (context.x.width * 0.5) - 20,
                  padding: const .all(12),
                  isSelected: value?.paymentId == paymentResponseModels[index].paymentId,
                  onTap: () {
                    selectedPayment.value = paymentResponseModels[index];
                    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
                  },
                  child: Image.asset(paymentResponseModels[index].paymentLink, package: Constant.packageUi),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: PaymentTextBuilderWidget(text: context.x.l10n.noPaymentFee, isImportant: true),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: PaymentTextBuilderWidget(text: context.x.l10n.paymentViaApps),
          ),
          const Spacer(),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                context.telegramWebApp.hapticFeedback.impactOccurred(.light);
                // onTapReport(parentContext: context);
              },
              child: Row(
                spacing: 8,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: context.x.colors.black.withValues(alpha: .04),
                    child: Assets.lib.vectors.questionMark.svg(package: Constant.packageUi),
                  ),
                  Text(
                    context.x.l10n.reportErrorAbout,
                    style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.error, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: PaymentTextBuilderWidget(text: context.x.l10n.cardBalancePaymentInfo, isImportant: true),
          ),
        ],
      ),
    ),

    bottomNavigationBar: Padding(
      padding: const .all(16),
      child: ListenableBuilder(
        listenable: .merge([selectedAmount, selectedPayment]),
        builder: (context, child) => CustomButton(
          onTap: () {
            context.telegramWebApp.hapticFeedback.notificationOccurred(.success);
          },

          title: context.x.l10n.filling,
        ),
      ),
    ),
  );
}
