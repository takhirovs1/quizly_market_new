import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/app_enum.dart';
import '../bloc/profile_cubit.dart';
import '../model/payment_response_model.dart';
import '../screen/payment_screen.dart';

abstract class PaymentScreenState extends State<PaymentScreen> {
  late final TextEditingController amountController;
  late final TextEditingController _reportController;
  late final FocusNode amountFocusNode;
  late final ValueNotifier<bool> _reportLoading;
  late final ValueNotifier<ButtonType> _reportButtonType;
  late final ValueNotifier<String?> selectedAmount;
  late final ValueNotifier<PaymentResponseModel?> selectedPayment;

  final List<String> defaultAmounts = ['10000', '20000', '30000', '40000', '50000'];

  final List<PaymentResponseModel> paymentResponseModels = [
    PaymentResponseModel(paymentLink: Assets.lib.images.payme2.path, paymentId: '1', paymentName: 'Payme'),
    PaymentResponseModel(paymentLink: Assets.lib.images.click2.path, paymentId: '2', paymentName: 'Click'),
  ];

  static const int minAmount = 1000;
  static const int maxAmount = 200000;

  int? get parsedAmount {
    final raw = amountController.text.replaceAll(RegExp(r'\D'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  bool get isAmountInValidRange {
    final amount = parsedAmount;
    return amount != null && amount >= minAmount && amount <= maxAmount;
  }

  bool get isAmountOverLimit {
    final amount = parsedAmount;
    return amount != null && amount > maxAmount;
  }

  void onSelectAmount(String amount) {
    context.telegramWebApp.hapticImpact(TelegramHapticImpact.light);
    final digits = amount.replaceAll(RegExp(r'\D'), '');
    final formatted = "${NumberFormat('#,###', 'uz').format(int.parse(digits)).replaceAll(',', ' ')} so'm";

    amountController.text = formatted;
    selectedAmount.value = digits;
  }

  // void onTopUpButtonPressed() {
  //   final amount = parsedAmount;
  //   if (amount == null || amount < minAmount || amount > maxAmount) return;

  //   context.telegramWebApp.hapticImpact(TelegramHapticImpact.light);
  //   final userId = context.user?.userID;
  //   context.read<PaymentBloc>().add(CreateClickPaymentEvent(amount: amount, userId: userId));
  // }

  // void onPaymentStateChanged(BuildContext context, PaymentState state) {
  //   if (state.status.isLoading) {
  //     context.showLoading();
  //   } else if (state.status.isSuccess) {
  //     context.hideLoading();
  //     final payUrl = state.payUrl;
  //     if (payUrl != null && payUrl.isNotEmpty) {
  //       log('payUrl: $payUrl');
  //       openPaymentUrl(payUrl);
  //     }
  //   } else if (state.status.isError) {
  //     context
  //       ..hideLoading()
  //       ..showNotification(message: state.error ?? context.l10n.paymentError, isError: true);
  //     TelegramBotService.sendMessageToTelegram(
  //       message: 'Payment error: ${state.error}',
  //       user: context.user,
  //       appVersion: formatVersion(),
  //       platform: context.telegramWebApp.platform,
  //       screenName: 'PaymentScreen',
  //       functionName: 'onPaymentStateChanged',
  //     );
  //   }
  // }

  // Future<void> openPaymentUrl(String url) async {
  //   try {
  //     final paymentName = '💸${selectedPayment.value?.paymentName} payment #${selectedPayment.value?.paymentName}';
  //     TelegramBotService.sendMessageToTelegram(
  //       messageType: paymentName,
  //       message: 'Launch Url: $url',
  //       user: context.user,
  //       appVersion: formatVersion(),
  //       platform: context.telegramWebApp.platform,
  //       description: '💸 Amount: <code>${amountController.text}</code>\n',
  //       screenName: 'PaymentScreen',
  //       functionName: 'openPaymentUrl',
  //     );
  //     debugPrint('Opening payment link: $url');
  //     context.telegramWebApp.openLink(url, tryInstantView: false);
  //   } on Object catch (e) {
  //     debugPrint('Error opening payment link: $e');
  //     TelegramBotService.sendMessageToTelegram(
  //       message: 'Launch Url error: $e',
  //       user: context.user,
  //       appVersion: formatVersion(),
  //       screenName: 'PaymentScreen',
  //       functionName: 'onTapReport',
  //       platform: context.telegramWebApp.platform,
  //     );
  //   }
  // }

  // String formatVersion() {
  //   final raw = context.appMetadata.appVersion;
  //   final parts = raw.split('+');
  //   if (parts.length == 2) return '${parts[0]}(+${parts[1]})';
  //   return raw;
  // }

  // Future<void> onTapReport({required BuildContext parentContext}) async {
  //   _reportController.clear();
  //   _reportLoading.value = false;
  //   await showModalBottomSheet<void>(
  //     backgroundColor: context.x.colors.transparent,
  //     context: context,
  //     useRootNavigator: true,
  //     isScrollControlled: true,
  //     builder: (ctx) => Padding(
  //       padding: .only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
  //       child: ValueListenableBuilder(
  //         valueListenable: _reportLoading,
  //         builder: (context, isLoading, child) => CustomBottomSheet(
  //           initialChildSize: .8,
  //           maxChildSize: .8,
  //           isScrollable: false,
  //           bottomNavigationBar: ValueListenableBuilder(
  //             valueListenable: _reportButtonType,
  //             builder: (context, value, child) => CustomButton2(
  //               rightButtonType: value,
  //               onRightPressed: () async {
  //                 _reportButtonType.value = .disabled;
  //                 _reportLoading.value = true;
  //                 final success = await TelegramBotService.sendMessageToTelegram(
  //                   messageType: '📋 Message #message',
  //                   message: _reportController.text,
  //                   user: parentContext.user!,
  //                   appVersion: formatVersion(),
  //                   platform: context.telegramWebApp.platform,
  //                   screenName: 'PaymentScreen',
  //                   functionName: 'onTapReport',
  //                 );
  //                 _reportLoading.value = false;
  //                 if (!context.mounted) return;
  //                 ctx.pop();
  //                 if (success && parentContext.mounted) {
  //                   context.telegramWebApp.hapticNotification(TelegramHapticNotification.success);
  //                   parentContext.showCustomDialog(
  //                     dialog: CustomPrimaryDialog(
  //                       onRightPressed: parentContext.pop,
  //                       title: parentContext.l10n.reportSentTitle,
  //                       description: parentContext.l10n.reportSentSubtitle,
  //                       rightText: parentContext.l10n.back,
  //                     ),
  //                   );
  //                 }
  //               },
  //               rightText: isLoading ? context.x.l10n.sending : context.x.l10n.send,
  //               leftText: context.x.l10n.cancel,
  //               onLeftPressed: context.pop,
  //             ),
  //           ),
  //           children: [
  //             Text(context.x.l10n.reportIssue, style: context.x.textStyle.sfW500s22),
  //             const SizedBox(height: 16),
  //             CustomTextFiled(
  //               height: 300,
  //               hintText: context.x.l10n.writeReason,
  //               controller: _reportController,
  //               textCapitalization: .words,
  //               maxLines: 5,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> onTopUpButtonPressed() async {
    final amount = parsedAmount;
    final provider = PaymentProvider.fromValue(selectedPayment.value?.paymentName);
    if (amount == null || !isAmountInValidRange) return;

    context.telegramWebApp.hapticImpact(.light);

    try {
      final response = await context.read<ProfileCubit>().topUp(amount, provider);
      if (!mounted) return;

      final payUrl = response?.payUrl;
      if (payUrl != null && payUrl.isNotEmpty) {
        context.telegramWebApp.openLink(payUrl, tryInstantView: false);
      } else {
        context.x.showNotification(
          message: context.x.l10n.somethingWentWrong,
          isError: true,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    } on Object catch (_) {
      if (mounted) {
        context.x.showNotification(
          message: context.x.l10n.somethingWentWrong,
          isError: true,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    }
  }

  void onTopUpPressed() {
    if (isAmountInValidRange) {
      onTopUpButtonPressed();
    }
  }

  void onClearPressed() {
    if (amountController.text.isNotEmpty) {
      amountController.text = '';
      selectedAmount.value = '';
    }
  }

  void goBackToProfile() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.setState(
      (state) => state
        ..clear()
        ..add(OctopusNode(name: Routes.home.name, arguments: const {'tab': '3'}, children: const [])),
    );
  }

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton(goBackToProfile);
    amountController = TextEditingController();
    amountFocusNode = FocusNode()..requestFocus();
    selectedPayment = ValueNotifier<PaymentResponseModel?>(paymentResponseModels.first);
    selectedAmount = ValueNotifier<String?>(null);
    _reportController = TextEditingController();
    _reportLoading = ValueNotifier<bool>(false);
    _reportButtonType = ValueNotifier<ButtonType>(.disabled);
    _reportController.addListener(() {
      _reportButtonType.value = _reportController.text.trim().isEmpty ? .disabled : .active;
    });
  }

  @override
  void dispose() {
    super.dispose();
    amountController.dispose();
    selectedPayment.dispose();
    selectedAmount.dispose();
    amountFocusNode.dispose();
    _reportController.dispose();
    _reportLoading.dispose();
    _reportButtonType.dispose();
    context.teardownTelegramBackButton();
  }
}

class UZSFormatter extends TextInputFormatter {
  final f = NumberFormat('#,###', 'uz');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return .empty;

    final text = "${f.format(int.parse(digits)).replaceAll(',', ' ')} so'm";

    return TextEditingValue(
      text: text,
      selection: .collapsed(offset: text.length - 5),
    );
  }
}
