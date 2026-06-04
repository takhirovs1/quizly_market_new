import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../../recommendation/screen/more_recommendation_screen.dart';
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
    body: Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppTextField(
            controller: searchController,
            title: context.x.l10n.search,
            prefixWidget: Assets.lib.vectors.search.svg(package: 'ui', width: 24, height: 24),
          ),
        ),
        Expanded(
          child: BlocBuilder<MyTestCubit, MyTestState>(
            builder: (context, state) => switch (state.status) {
              .loading => RefreshIndicator.adaptive(
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
                      if (state.search.isNotEmpty && state.myTests.isEmpty) ...[
                        EmptyTestWidget(
                          title: context.x.l10n.noTestsFound,
                          description: context.x.l10n.trySearchingWithOtherKeywords,
                        ),
                      ] else ...[
                        ...switch (state.myTests.isEmpty) {
                          false => [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  context.x.l10n.myTestsHeader,
                                  style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.telegramWebApp.hapticImpact(.light);
                                    context.octopus.push(
                                      Routes.moreRecommendation,
                                      arguments: <String, String>{'type': TestCategoryType.myTests.name},
                                    );
                                  },
                                  child: Padding(
                                    padding: const .all(4),
                                    child: Assets.lib.vectors.chevronRight.svg(package: 'ui', width: 24, height: 24),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final test in state.myTests.take(2))
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
                                    buyButtonText: test.isPurchased == true
                                        ? context.x.l10n.enterTest
                                        : context.x.l10n.buy,
                                    onBuyButtonPressed: onBuyTestPressed,
                                    isFree: test.price == 0 || test.price == null,
                                    onShareButtonPressed: onShareTestPressed,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            const SizedBox(height: 6),
                            const AnimatedReferralBanner(),
                            const SizedBox(height: 16),
                            for (final test in state.myTests.skip(2).take(3))
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
                                    buyButtonText: test.isPurchased == true
                                        ? context.x.l10n.enterTest
                                        : context.x.l10n.buy,
                                    onBuyButtonPressed: onBuyTestPressed,
                                    isFree: test.price == 0 || test.price == null,
                                    onShareButtonPressed: onShareTestPressed,
                                  ),
                                  const SizedBox(height: 10),
                                ],
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
                                Text(
                                  context.x.l10n.tryItNow,
                                  style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22),
                                ),
                              ],
                            ),
                            TestCardWidget(
                              title: 'Example test',
                              companyName: 'QuizlyMarket',
                              description:
                                  'Example test description, Example test description, Example test description',
                              price: context.x.l10n.free,
                              questionAmount: context.x.l10n.questionAmountText(100),
                              buyButtonText: context.x.l10n.tryItNow,
                              onBuyButtonPressed: () {},
                              isFree: true,
                              onShareButtonPressed: onShareTestPressed,
                            ),
                            const SizedBox(height: 16),
                            const AnimatedReferralBanner(),
                          ],
                        },
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              context.x.l10n.recommendationsHeader,
                              style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.telegramWebApp.hapticImpact(.light);
                                context.octopus.push(
                                  Routes.moreRecommendation,
                                  arguments: <String, String>{'type': TestCategoryType.topTests.name},
                                );
                              },
                              child: Padding(
                                padding: const .all(4),
                                child: Assets.lib.vectors.chevronRight.svg(package: 'ui', width: 24, height: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...switch (state.topTests.isEmpty) {
                          true => [
                            for (var i = 0; i < 5; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)],
                          ],
                          false => [
                            for (final test in state.topTests.take(5))
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
                                    buyButtonText: test.isPurchased == true
                                        ? context.x.l10n.enterTest
                                        : context.x.l10n.buy,
                                    onBuyButtonPressed: onBuyTestPressed,
                                    isFree: test.price == 0 || test.price == null,
                                    onShareButtonPressed: onShareTestPressed,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                          ],
                        },
                      ],
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
        ),
      ],
    ),
  );
}
