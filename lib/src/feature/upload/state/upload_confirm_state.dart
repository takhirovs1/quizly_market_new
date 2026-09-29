import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/payment_model.dart';
import '../../my_tests/models/wallet_model.dart';
import '../bloc/upload_confirm_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../screen/upload_confirm_screen.dart';
import 'file_upload_state.dart' show UZSFormatter;

abstract class UploadConfirmState extends State<UploadConfirmScreen> {
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final List<PaymentModel> paymentMethods;
  bool _isInitialized = false;

  late final UploadConfirmCubit confirmCubit;
  late final UploadPricingCubit pricingCubit;

  List<DemoQuestion> questions = const [];

  /// True while the preview questions are being fetched, so the carousel shows
  /// a shimmer placeholder instead of popping in once loaded.
  bool isLoadingQuestions = false;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    currentPage = ValueNotifier<int>(0);

    final repo = context.x.dependencies.repository.uploadRepository;
    confirmCubit = UploadConfirmCubit(uploadRepository: repo)..setSalePrice(_parsePrice(widget.price));
    pricingCubit = UploadPricingCubit(uploadRepository: repo)..fetchPricing();

    if (widget.testId != null && widget.testId!.isNotEmpty) {
      confirmCubit.fetchQuote(widget.testId!);
      isLoadingQuestions = true;
    }

    _loadQuestions();
    _loadWalletBalance();
  }

  Future<void> _loadQuestions() async {
    final testId = widget.testId;
    if (testId == null || testId.isEmpty) return;
    try {
      final loaded = await context.x.dependencies.repository.uploadRepository.getTestQuestions(testId);
      if (!mounted) return;
      setState(() {
        questions = loaded;
        isLoadingQuestions = false;
      });
    } on Object catch (_) {
      if (mounted) setState(() => isLoadingQuestions = false);
    }
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
    context.teardownTelegramBackButton();
    currentPage.dispose();
    selectedPayment.dispose();
    confirmCubit.close();
    pricingCubit.close();
    super.dispose();
  }

  // ── Sale price ("Test narxi") ─────────────────────────────────────────

  /// Digits-only parse of a possibly formatted price string ("20 000 so'm").
  int? _parsePrice(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Sale price currently in effect (cubit state → route arg fallback).
  int? get currentSalePrice => confirmCubit.state.salePrice ?? _parsePrice(widget.price);

  /// Question count used for suggested-price math (quote → route arg fallback).
  int get _questionCount {
    final fromQuote = confirmCubit.state.quote?.questionCount ?? 0;
    return fromQuote > 0 ? fromQuote : widget.questionCount;
  }

  /// Hard floor for the sale price (quote → pricing settings fallback).
  int get minTestPrice => confirmCubit.state.quote?.minTestPrice ?? pricingCubit.state.pricing.minTestPrice;

  /// Recommended sale price (quote's value → computed from pricing settings).
  int get suggestedSalePrice {
    final fromQuote = confirmCubit.state.quote?.suggestedPrice ?? 0;
    return fromQuote > 0 ? fromQuote : pricingCubit.state.pricing.suggestedPrice(_questionCount);
  }

  /// Opens the sheet to change the sale price and persists it via `PUT /api/tests/:id`.
  Future<void> onEditPrice() async {
    final testId = widget.testId;
    if (testId == null || testId.isEmpty) return;
    context.telegramWebApp.hapticImpact(.light);

    final min = minTestPrice;
    final suggested = suggestedSalePrice;
    final controller = TextEditingController(
      text: currentSalePrice != null ? "${currentSalePrice!.splitPerThree} so'm" : '',
    );
    final errorText = ValueNotifier<String?>(null);

    Future<void> submit() async {
      final value = _parsePrice(controller.text);
      if (value == null || value < min) {
        errorText.value = context.x.l10n.priceBelowMinError(min.formatUzs);
        return;
      }
      final navigator = Navigator.of(context);
      final ok = await confirmCubit.updateSalePrice(
        testId: testId,
        name: widget.testName ?? '',
        description: widget.description,
        price: value,
        locale: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      if (ok) {
        navigator.pop();
        context.x.showNotification(
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
          message: context.x.l10n.priceUpdated,
        );
      } else {
        errorText.value = ErrorUtil.localizeError(context, confirmCubit.state.errorMessage);
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: .only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: BottomSheetView(
          isCenterTitle: false,
          onClose: () => Navigator.pop(sheetContext),
          title: sheetContext.x.l10n.editSalePriceTitle,
          child: Padding(
            padding: const .fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                CustomTextFiled(
                  controller: controller,
                  hintText: "${suggested.splitPerThree} so'm",
                  keyboardType: .number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                    UZSFormatter(),
                  ],
                  style: sheetContext.x.textStyle.sfW500s16.copyWith(color: sheetContext.x.colors.text),
                  fillColor: sheetContext.x.colors.buttonFill,
                  enabledBorderColor: sheetContext.x.colors.transparent,
                  borderColor: sheetContext.x.colors.primary,
                  borderWidth: 1.2,
                  borderRadius: .circular(12),
                  contentPadding: const .symmetric(horizontal: 16, vertical: 14),
                  onChanged: (_) => errorText.value = null,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String?>(
                  valueListenable: errorText,
                  builder: (context, error, _) => Text(
                    error ?? sheetContext.x.l10n.minTestPriceInfo(min.formatUzs),
                    style: sheetContext.x.textStyle.sfW400s14.copyWith(
                      color: error != null ? sheetContext.x.colors.error : sheetContext.x.colors.bannerSecondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    controller
                      ..text = "${suggested.splitPerThree} so'm"
                      ..selection = .collapsed(offset: controller.text.length - 5);
                    errorText.value = null;
                  },
                  behavior: .opaque,
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: sheetContext.x.colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${sheetContext.x.l10n.recommendedPrice}: ${suggested.formatUzs}',
                        style: sheetContext.x.textStyle.sfW500s14.copyWith(color: sheetContext.x.colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: .infinity,
                  height: 48,
                  child: BlocBuilder<UploadConfirmCubit, UploadConfirmCubitState>(
                    bloc: confirmCubit,
                    builder: (context, state) => FilledButton(
                      onPressed: state.priceUpdateStatus.isLoading ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: sheetContext.x.colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                      ),
                      child: state.priceUpdateStatus.isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation<Color>(sheetContext.x.colors.white),
                              ),
                            )
                          : Text(
                              sheetContext.x.l10n.save,
                              style: sheetContext.x.textStyle.sfW600s16.copyWith(
                                color: sheetContext.x.colors.white,
                                fontWeight: .w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.dispose();
    errorText.dispose();
    if (mounted) setState(() {});
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
    context.telegramWebApp.hapticImpact(.medium);
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
        context.x.showNotification(
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
          message: context.x.l10n.testSuccessfullyPublished,
        );
        context.octopus.navigate(Routes.home.name);
      } else if (state.isInsufficientBalance && mounted) {
        context.x.showNotification(
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
          message: state.errorMessage == null
              ? context.x.l10n.insufficientWalletBalance
              : ErrorUtil.localizeError(context, state.errorMessage),
          isError: true,
        );
      } else if (state.errorMessage != null && mounted) {
        context.x.showNotification(
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
          message: ErrorUtil.localizeError(context, state.errorMessage),
          isError: true,
        );
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
                context.x.showNotification(
                  top: switch (context.telegramWebApp.isSupported) {
                    true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
                    false => MediaQuery.paddingOf(context).top + 56,
                  },
                  message: context.x.l10n.testSuccessfullyPublished,
                );
                context.octopus.navigate(Routes.home.name);
              }
            },
            onFailed: () {
              if (mounted) {
                context.x.showNotification(
                  top: switch (context.telegramWebApp.isSupported) {
                    true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
                    false => MediaQuery.paddingOf(context).top + 56,
                  },
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
