import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/payment_model.dart';
import '../../my_tests/models/wallet_model.dart';
import '../bloc/upload_confirm_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../screen/upload_confirm_screen.dart';

abstract class UploadConfirmState extends State<UploadConfirmScreen> {
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final List<PaymentModel> paymentMethods;
  bool _isInitialized = false;

  late final UploadConfirmCubit confirmCubit;
  late final UploadPricingCubit pricingCubit;

  List<DemoQuestion> questions = const [];

  @override
  void initState() {
    super.initState();
    currentPage = ValueNotifier<int>(0);

    final repo = context.x.dependencies.repository.uploadRepository;
    confirmCubit = UploadConfirmCubit(uploadRepository: repo);
    pricingCubit = UploadPricingCubit(uploadRepository: repo)..fetchPricing();

    if (widget.testId != null && widget.testId!.isNotEmpty) {
      confirmCubit.fetchQuote(widget.testId!);
    }

    _loadQuestions();
    _loadWalletBalance();
  }

  Future<void> _loadQuestions() async {
    final testId = widget.testId;
    if (testId == null || testId.isEmpty) return;
    try {
      final loaded = await context.x.dependencies.repository.uploadRepository.getTestQuestions(testId);
      if (mounted && loaded.isNotEmpty) {
        setState(() {
          questions = loaded;
        });
      }
    } on Object catch (_) {}
  }

  Future<void> _loadWalletBalance() async {
    try {
      final wallet = await context.x.dependencies.repository.myTestRepository.getWallet(const WalletRequest());
      final balance = wallet.data?.balance;
      if (mounted && balance != null && paymentMethods.isNotEmpty) {
        setState(() {
          paymentMethods[0] = PaymentModel(
            id: 0,
            title: balance.formatUzs,
            subtitle: context.x.l10n.quizlyMarketCard,
            icon: Assets.lib.images.robot.path,
            type: .card,
          );
          if (selectedPayment.value.id == 0) {
            selectedPayment.value = paymentMethods[0];
          }
        });
      }
    } on Object catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      paymentMethods = [
        PaymentModel(
          id: 0,
          title: 0.formatUzs,
          subtitle: context.x.l10n.quizlyMarketCard,
          icon: Assets.lib.images.robot.path,
          type: .card,
        ),
        PaymentModel(id: 1, title: context.x.l10n.payme, icon: Assets.lib.images.payme2.path, type: .provider),
        PaymentModel(id: 2, title: context.x.l10n.clickSuperApp, icon: Assets.lib.images.click2.path, type: .provider),
      ];
      selectedPayment = ValueNotifier(paymentMethods[0]);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    currentPage.dispose();
    selectedPayment.dispose();
    confirmCubit.close();
    pricingCubit.close();
    super.dispose();
  }

  void onReportError() {
    context.octopus.push(Routes.supportChat);
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
            child: ValueListenableBuilder<PaymentModel>(
              valueListenable: selectedPayment,
              builder: (context, isSelected, child) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      context.x.l10n.currentPaymentType,
                      style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    PaymentCard(
                      hasShadow: true,
                      imagePadding: isSelected.id != 0
                          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5)
                          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                      title: isSelected.title,
                      subtitle: isSelected.subtitle,
                      image: Image.asset(isSelected.icon, package: 'ui', width: isSelected.type == .card ? 44 : 54),
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.x.l10n.paymentViaProvider,
                      style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18),
                    ),
                    for (final payment in paymentMethods.where((e) => e.id != isSelected.id && e.id != 0))
                      Padding(
                        padding: const .only(bottom: 8),
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
                      Text(context.x.l10n.wallet, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18)),
                      PaymentCard(
                        hasShadow: true,
                        title: paymentMethods.first.title,
                        subtitle: paymentMethods.first.subtitle,
                        image: Image.asset(paymentMethods.first.icon, package: 'ui', width: 44),
                        onTap: () => Navigator.pop<PaymentModel>(ctx, paymentMethods.first),
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

  Future<void> onConfirmUpload() async {
    final testId = widget.testId;
    if (testId == null || testId.isEmpty) {
      context.octopus.navigate(Routes.home.name);
      return;
    }

    final isWallet = selectedPayment.value.type == .card || selectedPayment.value.id == 0;

    if (isWallet) {
      await confirmCubit.publishFromWallet(testId);
      final state = confirmCubit.state;
      if (state.publishStatus.isSuccess && mounted) {
        context.x.showNotification(message: context.x.l10n.testSuccessfullyPublished);
        context.octopus.navigate(Routes.home.name);
      } else if (state.isInsufficientBalance && mounted) {
        context.x.showNotification(
          message: state.errorMessage ?? context.x.l10n.insufficientWalletBalance,
          isError: true,
        );
      } else if (state.errorMessage != null && mounted) {
        context.x.showNotification(message: state.errorMessage!, isError: true);
      }
    } else {
      final isPayme = selectedPayment.value.id == 1;
      final provider = isPayme ? 'payme' : 'click';
      final url = await confirmCubit.publishViaCheckout(testId, provider: provider);

      if (url != null && url.isNotEmpty) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }

        final paymentId = confirmCubit.state.checkoutResult?.paymentId;
        if (paymentId != null) {
          confirmCubit.startPaymentPolling(
            paymentId,
            onCompleted: () {
              if (mounted) {
                context.x.showNotification(message: context.x.l10n.testSuccessfullyPublished);
                context.octopus.navigate(Routes.home.name);
              }
            },
            onFailed: () {
              if (mounted) {
                context.x.showNotification(
                  message: context.x.l10n.paymentCancelledOrFailed,
                  isError: true,
                );
              }
            },
          );
        }
      }
    }
  }
}
