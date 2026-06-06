import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/my_test_cubit.dart';
import '../models/payment_model.dart';
import '../screen/purchase_test_screen.dart';

abstract class PurchaseTestScreenState extends State<PurchaseTestScreen> {
  late final MyTestCubit myTestCubit;
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final ScrollController scrollController;
  late final ValueNotifier<int> currentTest;
  late final List<PaymentModel> paymentModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    scrollController = ScrollController()..addListener(onScroll);
    currentTest = ValueNotifier(0);
    myTestCubit = context.read<MyTestCubit>();
    myTestCubit
      ..getDemoTest(widget.testId)
      ..getWallet();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      paymentModel = [
        PaymentModel(
          id: 0,
          title: 0.formatUzs,
          type: PaymentType.card,
          icon: Assets.lib.images.logoPng.path,
          subtitle: context.x.l10n.quizlyMarketCard,
        ),
        PaymentModel(
          id: 1,
          title: context.x.l10n.payme,
          type: PaymentType.provider,
          icon: Assets.lib.images.payme2.path,
        ),
        PaymentModel(
          id: 2,
          title: context.x.l10n.clickSuperApp,
          type: PaymentType.provider,
          icon: Assets.lib.images.click2.path,
        ),
      ];
      selectedPayment = ValueNotifier(paymentModel[0]);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    selectedPayment.dispose();
    context.teardownTelegramBackButton();
  }

  void onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    final width = pos.viewportDimension;
    if (width <= 0) return;
    final page = (pos.pixels / width).round();
    if (currentTest.value != page) {
      currentTest.value = page;
    }
  }

  Future<void> onSwitchPaymentPressed() async {
    context.telegramWebApp.hapticImpact(.light);
    final result = await showModalBottomSheet<PaymentModel>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        builder: (context, scrollController) => BottomSheetView(
          isCenterTitle: false,
          onClose: () => Navigator.pop(ctx),
          title: context.x.l10n.selectPaymentType,
          child: Padding(
            padding: const .symmetric(horizontal: 14, vertical: 16),
            child: ValueListenableBuilder<PaymentModel?>(
              valueListenable: selectedPayment,
              builder: (context, isSelected, child) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(context.x.l10n.currentPaymentType, style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    PaymentCard(
                      hasShadow: true,
                      imagePadding: isSelected?.id != 0
                          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5)
                          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                      title: isSelected!.title,
                      subtitle: isSelected.subtitle,
                      image: Image.asset(isSelected.icon, package: 'ui', width: isSelected.type == .card ? 32 : 54),
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    Text(context.x.l10n.paymentViaProvider, style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                    for (final payment in paymentModel.where((e) => e != isSelected && e.id != 0))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PaymentCard(
                          hasShadow: true,
                          imagePadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5),
                          title: payment.title,
                          image: Image.asset(payment.icon, package: 'ui', width: 54),
                          onTap: () => Navigator.pop<PaymentModel>(ctx, payment),
                        ),
                      ),

                    if (isSelected.id != 0) ...[
                      const SizedBox(height: 16),
                      Text(context.x.l10n.wallet, style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                      PaymentCard(
                        hasShadow: true,
                        title: paymentModel.first.title,
                        subtitle: paymentModel.first.subtitle,
                        image: Image.asset(paymentModel.first.icon, package: 'ui', width: 34),
                        onTap: () => Navigator.pop<PaymentModel>(ctx, paymentModel.first),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      selectedPayment.value = result;
    }
  }

  void onBuyPressed() {
    context.telegramWebApp.hapticImpact(.light);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.x.colors.transparent,
        child: Center(
          child: SuccessDialog(
            title: 'Test sotib olindi!',
            description: 'Testni istalgan vaqtda o’rganishingiz mumkin.',
            cancelButtonText: 'Chiqish',
            successButtonText: 'Kirish',
            onCancelButtonPressed: () => Navigator.pop(context),
            onSuccessButtonPressed: () => context.octopus.push(Routes.testMode),
          ),
        ),
      ),
    );
  }

  void onPressLike() {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.toggleLike(widget.testId);
  }

  void onPressShare() {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      'Example test',
      'QuizlyMarket',
      'Example test description, Example test description, Example test description',
      '100000',
      '100',
    );
  }

  void onDemoTestStateChanged(BuildContext context, MyTestState state) {
    if (state.walletStatus.isSuccess && state.walletData != null) {
      final balance = state.walletData!.balance ?? 0;
      paymentModel[0] = PaymentModel(
        id: 0,
        title: balance.formatUzs,
        type: PaymentType.card,
        icon: Assets.lib.images.logoPng.path,
        subtitle: context.x.l10n.quizlyMarketCard,
      );

      if (selectedPayment.value.id == 0) {
        selectedPayment.value = paymentModel[0];
      }
    }
  }

  void onRetryPressed() {
    myTestCubit.getDemoTest(widget.testId);
    myTestCubit.getWallet();
  }
}
