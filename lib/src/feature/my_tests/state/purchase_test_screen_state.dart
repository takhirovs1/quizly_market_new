import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/app_enum.dart';
import '../../../common/util/state_status.dart';
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
  StateStatus _lastPurchaseStatus = .idle;

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
          type: .card,
          icon: Assets.lib.images.logoPng.path,
          subtitle: context.x.l10n.quizlyMarketCard,
        ),
        PaymentModel(id: 1, title: context.x.l10n.payme, type: .provider, icon: Assets.lib.images.payme2.path),
        PaymentModel(id: 2, title: context.x.l10n.clickSuperApp, type: .provider, icon: Assets.lib.images.click2.path),
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
                        padding: const .only(bottom: 8),
                        child: PaymentCard(
                          hasShadow: true,
                          imagePadding: const .symmetric(horizontal: 5, vertical: 16.5),
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

  Future<void> onBuyPressed({bool withPop = false}) async {
    if (withPop) {
      Navigator.pop(context);
    }
    context.telegramWebApp.hapticImpact(.light);

    final selected = selectedPayment.value;
    if (selected.type == .provider) {
      final provider = selected.id == 1 ? PaymentProvider.payme : PaymentProvider.click;
      final detail = myTestCubit.state.demoTestDetail;
      final code = (detail?.code != null && detail!.code!.isNotEmpty) ? detail.code! : widget.testId;
      final redirectUrl = 'https://t.me/@prjkttest_bot?startapp=$code';

      final response = await myTestCubit.checkoutTest(
        testId: widget.testId,
        provider: provider,
        redirectUrl: redirectUrl,
      );
      if (!mounted) return;

      final payUrl = response?.url;
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
    } else {
      myTestCubit.purchaseTest(widget.testId);
    }
  }

  void onPressLike() {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.toggleLike(widget.testId);
  }

  void onPressShare() {
    context.telegramWebApp.hapticImpact(.light);
    final detail = myTestCubit.state.demoTestDetail;
    if (detail == null) return;
    context.shareTest(
      detail.name ?? '',
      detail.categoryId ?? 'QuizlyMarket',
      detail.description ?? '',
      detail.price?.toString() ?? '0',
      detail.questionCount?.toString() ?? '0',
      code: detail.code,
    );
  }

  void onDemoTestStateChanged(BuildContext context, MyTestState state) {
    if (state.walletStatus.isSuccess && state.walletData != null) {
      final balance = state.walletData!.balance ?? 0;
      paymentModel[0] = PaymentModel(
        id: 0,
        title: balance.formatUzs,
        type: .card,
        icon: Assets.lib.images.logoPng.path,
        subtitle: context.x.l10n.quizlyMarketCard,
      );

      if (selectedPayment.value.id == 0) {
        selectedPayment.value = paymentModel[0];
      }
    }

    if (_lastPurchaseStatus != state.purchaseStatus) {
      _lastPurchaseStatus = state.purchaseStatus;
      if (state.purchaseStatus.isSuccess || state.purchaseStatus.isError) {
        final isError = state.purchaseStatus.isError;
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: context.x.colors.transparent,
            child: Center(
              child: SuccessDialog(
                title: isError ? context.x.l10n.testNotPurchasedTitle : context.x.l10n.testPurchasedTitle,
                description: isError
                    ? context.x.l10n.testNotPurchasedDescription
                    : context.x.l10n.testPurchasedDescription,
                cancelButtonText: context.x.l10n.exit,
                successButtonText: isError ? context.x.l10n.retry : context.x.l10n.enter,
                onCancelButtonPressed: () {
                  context.octopus.navigate(Routes.home.name);
                },
                isError: isError,
                onSuccessButtonPressed: () => isError
                    ? onBuyPressed(withPop: true)
                    : {
                        context.octopus.push(Routes.testMode, arguments: {'id': widget.testId}),
                        Navigator.pop(context),
                      },
              ),
            ),
          ),
        );
      }
    }
  }

  void onRetryPressed() {
    myTestCubit
      ..getDemoTest(widget.testId)
      ..getWallet();
  }
}
