import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../bloc/my_test_cubit.dart';
import '../state/my_tests_screen_state.dart';
import '../widgets/animated_referral_banner.dart';

class MyTestsScreen extends StatefulWidget {
  const MyTestsScreen({super.key});

  @override
  State<MyTestsScreen> createState() => _MyTestsScreenState();
}

class _MyTestsScreenState extends MyTestsScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      title: context.x.l10n.myTests,
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: BlocBuilder<MyTestCubit, MyTestState>(
      builder: (context, state) => switch (state.status) {
        .loading when state.myTests.isEmpty && state.topTests.isEmpty => RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 16),
                for (var i = 0; i < 6; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)],
              ],
            ),
          ),
        ),
        .success => RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: ListView(
              controller: scrollController,
              children: [
                const SizedBox(height: 16),
                ...switch (state.myTests.isEmpty) {
                  false => [
                    for (final test in state.myTests)
                      Column(
                        children: [
                          TestCardWidget(
                            title: test.name ?? '',
                            companyName: test.categoryName ?? '',
                            description: test.description ?? '',
                            price: test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs,
                            questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
                            buyButtonText: test.isPurchased == true ? context.x.l10n.tryItNow : context.x.l10n.buy,
                            onBuyButtonPressed: onBuyTestPressed,
                            isFree: test.price == 0 || test.price == null,
                            onShareButtonPressed: onShareTestPressed,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (state.isMyTestsLoadingMore)
                      const Padding(
                        padding: .symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator.adaptive()),
                      ),
                  ],
                  true => [
                    EmptyTestWidget(
                      title: context.x.l10n.youDontHaveAnyTestsYet,
                      description: context.x.l10n.thereAreTestsOnaVarietyOfTopicsAvailableOnTheMarket,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(context.x.l10n.tryItNow, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22)),
                      ],
                    ),
                    TestCardWidget(
                      title: 'Example test',
                      companyName: 'QuizlyMarket',
                      description: 'Example test description, Example test description, Example test description',
                      price: context.x.l10n.free,
                      questionAmount: context.x.l10n.questionAmountText(100),
                      buyButtonText: context.x.l10n.tryItNow,
                      onBuyButtonPressed: () {},
                      isFree: true,
                      onShareButtonPressed: onShareTestPressed,
                    ),
                    const SizedBox(height: 22),
                    const AnimatedReferralBanner(),
                    const SizedBox(height: 24),
                    Text(context.x.l10n.recommendation, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22)),
                    const SizedBox(height: 12),
                    ...switch (state.topTests.isEmpty) {
                      true => [
                        for (var i = 0; i < 5; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)],
                      ],
                      false => [
                        for (final test in state.topTests)
                          Column(
                            children: [
                              TestCardWidget(
                                title: test.name ?? '',
                                companyName: test.categoryName ?? '',
                                description: test.description ?? '',
                                price: test.price == 0 || test.price == null
                                    ? context.x.l10n.free
                                    : test.price!.formatUzs,
                                questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
                                buyButtonText: test.isPurchased == true ? context.x.l10n.tryItNow : context.x.l10n.buy,
                                onBuyButtonPressed: onBuyTestPressed,
                                isFree: test.price == 0 || test.price == null,
                                onShareButtonPressed: onShareTestPressed,
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        if (state.isTopTestsLoadingMore)
                          const Padding(
                            padding: .symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator.adaptive()),
                          ),
                      ],
                    },
                  ],
                },
              ],
            ),
          ),
        ),
        _ => RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: Padding(
            padding: const .symmetric(horizontal: 16),
            child: ListView(controller: scrollController, children: const [SizedBox(height: 16)]),
          ),
        ),
      },
    ),
  );
}
