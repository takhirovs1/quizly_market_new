import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
        if (context.telegramWebApp.isSupported) {
          context.telegramWebApp.openLink(payUrl, tryInstantView: false);
        } else {
          await launchUrl(.parse(payUrl), mode: .externalApplication);
        }
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
    context.teardownTelegramBackButton(goBackToProfile);
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
