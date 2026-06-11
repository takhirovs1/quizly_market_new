import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/state_status.dart';
import '../../recommendation/screen/more_recommendation_screen.dart';
import '../bloc/my_test_cubit.dart';
import '../models/test_model.dart';
import '../state/my_tests_screen_state.dart';
import '../widgets/animated_referral_banner.dart';
import '../widgets/responsive_recommendations_list.dart';
import '../widgets/responsive_test_row.dart';
import '../widgets/section_header_widget.dart';

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
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: AppTextField(
            controller: searchController,
            title: context.x.l10n.search,
            prefixWidget: Assets.lib.vectors.search.svg(package: 'ui', width: 24, height: 24),
          ),
        ),
        Expanded(
          child: BlocConsumer<MyTestCubit, MyTestState>(
            listener: (context, state) {
              final hasData = state.myTests.isNotEmpty || state.topTests.isNotEmpty;
              if (state.status == StateStatus.error && hasData) {
                ErrorUtil.showSnackBar(context, state.errorMessage ?? context.x.l10n.somethingWentWrong);
              }
            },
            builder: (context, state) => LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth + MyTestsScreenState.horizontalPadding;
                final layout = computeListLayout(screenWidth);
                final crossAxisCount = layout.crossAxisCount;
                final mainAxisExtent = layout.mainAxisExtent;

                final hasData = state.myTests.isNotEmpty || state.topTests.isNotEmpty;
                if (state.status == StateStatus.success || hasData) {
                  return RefreshIndicator.adaptive(
                    onRefresh: onRefresh,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: context.x.isMobile ? 16 : 80),
                      children: [
                        if (state.search.isNotEmpty && state.myTests.isEmpty) ...[
                          EmptyTestWidget(
                            title: context.x.l10n.noTestsFound,
                            description: context.x.l10n.trySearchingWithOtherKeywords,
                          ),
                        ] else ...[
                          ...switch (state.myTests.isEmpty) {
                            false => [
                              // My Tests header
                              SectionHeaderWidget(
                                title: context.x.l10n.myTestsHeader,
                                onTap: () => context.octopus.push(
                                  Routes.moreRecommendation,
                                  arguments: <String, String>{'type': TestCategoryType.myTests.name},
                                ),
                              ),
                              const SizedBox(height: 12),

                              // First 2 rows of my tests
                              ResponsiveTestRow(
                                tests: state.myTests.take(2 * crossAxisCount).toList(),
                                crossAxisCount: crossAxisCount,
                                onBuyButtonPressed: onBuyTestPressed,
                                onShareButtonPressed: onShareTestPressed,
                                onLikeButtonPressed: onLikeTestPressed,
                              ),

                              const SizedBox(height: 6),
                              const AnimatedReferralBanner(),
                              const SizedBox(height: 16),

                              // Next 3 rows of my tests
                              ResponsiveTestRow(
                                tests: state.myTests.skip(2 * crossAxisCount).take(3 * crossAxisCount).toList(),
                                crossAxisCount: crossAxisCount,
                                onBuyButtonPressed: onBuyTestPressed,
                                onShareButtonPressed: onShareTestPressed,
                                onLikeButtonPressed: onLikeTestPressed,
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
                                onShareButtonPressed: () => onShareTestPressed(
                                  TestModel(
                                    name: 'Example test',
                                    categoryName: 'QuizlyMarket',
                                    description:
                                        'Example test description, Example test description, Example test description',
                                    price: 0,
                                    questionCount: 100,
                                  ),
                                ),
                                textBought: context.x.l10n.textBought,
                                isLiked: false,
                                onLikeButtonPressed: () {},
                              ),
                              const SizedBox(height: 16),
                              const AnimatedReferralBanner(),
                            ],
                          },

                          // Recommendations section
                          const SizedBox(height: 22),
                          SectionHeaderWidget(
                            title: context.x.l10n.recommendationsHeader,
                            onTap: () => context.octopus.push(
                              Routes.moreRecommendation,
                              arguments: <String, String>{'type': TestCategoryType.topTests.name},
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...switch (state.topTests.isEmpty) {
                            true => [
                              if (state.status == StateStatus.error) ...[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    child: EmptyTestWidget(
                                      title: context.x.l10n.somethingWentWrong,
                                      description: ErrorUtil.localizeError(
                                        context,
                                        state.errorMessage ?? 'pleaseTryAgainLater',
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                if (crossAxisCount == 1)
                                  for (var i = 0; i < 5; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)]
                                else
                                  for (var i = 0; i < 6; i += crossAxisCount) ...[
                                    SizedBox(
                                      height: mainAxisExtent,
                                      child: Row(
                                        children: [
                                          for (var j = 0; j < crossAxisCount; j++) ...[
                                            if (j > 0) const SizedBox(width: 10),
                                            const Expanded(child: TestCardShimmer()),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                              ],
                            ],
                            false => [
                              ResponsiveRecommendationsList(
                                tests: state.topTests,
                                crossAxisCount: crossAxisCount,
                                onBuyButtonPressed: onBuyTestPressed,
                                onShareButtonPressed: onShareTestPressed,
                                onLikeButtonPressed: onLikeTestPressed,
                              ),
                              if (state.isTopTestsLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator.adaptive()),
                                ),
                            ],
                          },
                        ],
                      ],
                    ),
                  );
                } else if (state.status == StateStatus.loading) {
                  return RefreshIndicator.adaptive(
                    onRefresh: onRefresh,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: context.x.isMobile ? 16 : 80),
                      children: [
                        if (crossAxisCount == 1)
                          for (var i = 0; i < 6; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)]
                        else
                          for (var i = 0; i < 6; i += crossAxisCount) ...[
                            SizedBox(
                              height: mainAxisExtent,
                              child: Row(
                                children: [
                                  for (var j = 0; j < crossAxisCount; j++) ...[
                                    if (j > 0) const SizedBox(width: 10),
                                    const Expanded(child: TestCardShimmer()),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator.adaptive(
                    onRefresh: onRefresh,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: context.x.isMobile ? 16 : 80),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
                        Center(
                          child: EmptyTestWidget(
                            title: context.x.l10n.somethingWentWrong,
                            description: ErrorUtil.localizeError(context, state.errorMessage ?? 'connectionError'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: FilledButton(onPressed: onRefresh, child: Text(context.x.l10n.retry)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}
