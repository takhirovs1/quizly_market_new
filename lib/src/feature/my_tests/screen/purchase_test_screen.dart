import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/my_test_cubit.dart';
import '../models/demo_test_model.dart';
import '../models/test_model.dart';
import '../state/purchase_test_screen_state.dart';
import '../widgets/purchase_test_shimmer.dart';
import '../widgets/questions_carousel.dart';
import '../widgets/test_description_widget.dart';

class PurchaseTestScreen extends StatefulWidget {
  const PurchaseTestScreen({required this.testId, super.key});
  final String testId;

  @override
  State<PurchaseTestScreen> createState() => _PurchaseTestScreenState();
}

class _PurchaseTestScreenState extends PurchaseTestScreenState {
  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    return Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        title: context.x.l10n.buy,
      ),
      body: BlocListener<MyTestCubit, MyTestState>(
        listenWhen: (previous, current) =>
            previous.demoTestStatus != current.demoTestStatus ||
            previous.walletStatus != current.walletStatus ||
            previous.purchaseStatus != current.purchaseStatus,
        listener: onDemoTestStateChanged,
        child: BlocBuilder<MyTestCubit, MyTestState>(
          builder: (context, state) => switch (state.demoTestStatus) {
            .loading =>
              isMobile
                  ? const PurchaseTestShimmer()
                  : Center(
                      child: SingleChildScrollView(
                        padding: const .symmetric(vertical: 24, horizontal: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 650),
                          child: const PurchaseTestShimmer(),
                        ),
                      ),
                    ),
            .error || .noInternetConnection => Center(
              child: Padding(
                padding: const .all(24),
                child: EmptyTestWidget(
                  title: context.x.l10n.somethingWentWrong,
                  description: context.x.l10n.pleaseTryAgainLater,
                ),
              ),
            ),
            _ => () {
              final detail = state.demoTestDetail;
              if (detail == null) {
                return Center(
                  child: Padding(
                    padding: const .all(24),
                    child: EmptyTestWidget(
                      title: context.x.l10n.somethingWentWrong,
                      description: context.x.l10n.pleaseTryAgainLater,
                    ),
                  ),
                );
              }

              final languageCode = Localizations.localeOf(context).languageCode;
              final testModel = TestModel(
                id: detail.id,
                categoryId: detail.categoryId,
                createdBy: detail.createdBy,
                name: detail.name ?? '',
                description: detail.description ?? '',
                price: detail.price,
                isPurchased: detail.isPurchased,
                isLiked: detail.isLiked,
                questionCount: detail.questionCount,
                createdAt: detail.createdAt,
              );

              final questions = detail.questions ?? [];
              final content = _buildContent(
                context,
                state: state,
                testModel: testModel,
                questions: questions,
                languageCode: languageCode,
              );

              if (isMobile) {
                return ListView(children: content);
              } else {
                return Center(
                  child: SingleChildScrollView(
                    padding: const .symmetric(vertical: 24, horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(crossAxisAlignment: .stretch, mainAxisSize: .min, children: content),
                    ),
                  ),
                );
              }
            }(),
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<MyTestCubit, MyTestState>(
        builder: (context, state) {
          final detail = state.demoTestDetail;
          if (detail == null || state.demoTestStatus.isLoading || state.demoTestStatus.isError) {
            return const SizedBox.shrink();
          }

          final priceText = detail.price == 0 || detail.price == null ? context.x.l10n.free : detail.price!.formatUzs;

          if (isMobile) {
            return ColoredBox(
              color: context.x.colors.dialogBackground,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.x.colors.dialogBackground,
                  borderRadius: const .only(topLeft: .circular(16), topRight: .circular(16)),
                  border: Border.all(color: context.x.colors.divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: context.x.colors.black.withValues(alpha: .078),
                      offset: const Offset(0, -3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const .only(topLeft: .circular(15), topRight: .circular(15)),
                  child: Padding(
                    padding: .only(
                      bottom: context.telegramWebApp.isSupported
                          ? context.telegramWebApp.safeAreaInset.bottom.toDouble() + 16
                          : 16,
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceText,
                            style: context.x.textStyle.sfW700s16.copyWith(
                              fontSize: 24,
                              color: context.x.colors.primary,
                            ),
                            textAlign: .center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            borderRadius: 10,
                            onTap: onBuyPressed,
                            title: context.x.l10n.buy,
                            isLoading: state.purchaseStatus.isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const .only(bottom: 24, left: 16, right: 16),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.x.colors.dialogBackground,
                      borderRadius: .circular(24),
                      border: Border.all(color: context.x.colors.divider, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const .symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              priceText,
                              style: context.x.textStyle.sfW700s16.copyWith(
                                fontSize: 24,
                                color: context.x.colors.primary,
                              ),
                              textAlign: .center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              borderRadius: 12,
                              onTap: onBuyPressed,
                              title: context.x.l10n.buy,
                              isLoading: state.purchaseStatus.isLoading,
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
        },
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context, {
    required MyTestState state,
    required TestModel testModel,
    required List<DemoQuestion> questions,
    required String languageCode,
  }) => [
    const SizedBox(height: 16),
    Padding(
      padding: const .symmetric(horizontal: 16),
      child: TestDescriptionWidget(test: testModel, onPressLike: onPressLike, onPressShare: onPressShare),
    ),
    if (questions.isNotEmpty)
      QuestionsCarousel(questions: questions, languageCode: languageCode, currentPage: currentTest),
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
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
          hasShadow: true,
          title: payment.title,
          titleWidget: (payment.id == 0 && state.walletStatus.isLoading)
              ? Shimmer.fromColors(
                  baseColor: context.x.colors.indicatorBackground,
                  highlightColor: context.x.colors.scaffoldBackground,
                  child: const ShimmerBox(width: 80, height: 18, radius: 4),
                )
              : null,
          subtitle: payment.subtitle,
          image: Image.asset(payment.icon, package: 'ui', width: payment.type == .card ? 32 : 54),
          onTap: onSwitchPaymentPressed,
          action: IconButton(onPressed: onSwitchPaymentPressed, icon: const Icon(Icons.unfold_more)),
        ),
      ),
    ),
    const SizedBox(height: 24),
  ];
}
