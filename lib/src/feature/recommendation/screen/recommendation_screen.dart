import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/widgets/animated_referral_banner.dart';
import '../../my_tests/widgets/responsive_recommendations_list.dart';
import '../../my_tests/widgets/section_header_widget.dart';
import '../bloc/recommendation_cubit.dart';
import '../state/recommendation_screen_state.dart';
import '../widget/custom_page_view.dart';
import 'more_recommendation_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends RecommendationScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      title: context.x.l10n.quizlyMarket,
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: AppTextField(
                  controller: searchController,
                  title: context.x.l10n.search,
                  prefixWidget: Padding(
                    padding: const .all(4),
                    child: Assets.lib.vectors.search.svg(
                      package: 'ui',
                      width: 24,
                      height: 24,
                      colorFilter: .mode(context.x.colors.bannerSecondaryText, .srcATop),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.telegramWebApp.hapticImpact(.medium),
                child: Assets.lib.vectors.filter.svg(
                  package: 'ui',
                  width: 24,
                  height: 24,
                  colorFilter: .mode(context.x.colors.primary, .srcATop),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: onRefresh,
            child: BlocBuilder<RecommendationCubit, RecommendationState>(
              builder: (context, state) {
                if (state.status.isLoading && state.allTests.isEmpty) {
                  return Padding(
                    padding: const .symmetric(horizontal: 16),
                    child: ListView(
                      children: [
                        const SizedBox(height: 16),
                        for (var i = 0; i < 6; i++) ...[const TestCardShimmer(), const SizedBox(height: 10)],
                      ],
                    ),
                  );
                }

                // Search mode: search results from /api/tests
                if (state.search.isNotEmpty) {
                  if (state.allTests.isEmpty) {
                    return ListView(
                      controller: scrollController,
                      children: [
                        const SizedBox(height: 16),
                        Padding(
                          padding: const .symmetric(horizontal: 16),
                          child: EmptyTestWidget(
                            title: context.x.l10n.noTestsFound,
                            description: context.x.l10n.trySearchingWithOtherKeywords,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    controller: scrollController,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const .symmetric(horizontal: 16),
                        child: SectionHeaderWidget(
                          title: context.x.l10n.allTests,
                          onTap: () => context.octopus.push(
                            Routes.moreRecommendation,
                            arguments: <String, String>{'type': TestCategoryType.allTests.name},
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const .symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth + 32;
                            const maxCardWidth = 360.0;
                            final crossAxisCount = (availableWidth / maxCardWidth).floor().clamp(1, 10);

                            return ResponsiveRecommendationsList(
                              tests: state.allTests,
                              crossAxisCount: crossAxisCount,
                              onBuyButtonPressed: onBuyTestPressed,
                              onShareButtonPressed: onShareTestPressed,
                              onLikeButtonPressed: onLikeTestPressed,
                            );
                          },
                        ),
                      ),
                      if (state.isAllTestsLoadingMore)
                        const Padding(
                          padding: .symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        ),
                    ],
                  );
                }

                // Default mode: Recommendations, Banner, Liked Tests, All Tests
                return ListView(
                  controller: scrollController,
                  children: [
                    // Recommendations section (first 5 top tests)
                    if (state.recommendations.isNotEmpty)
                      CustomPageView(
                        tests: state.recommendations.take(5).toList(),
                        title: context.x.l10n.recommendation,
                        onShowMore: () {
                          context.octopus.push(
                            Routes.moreRecommendation,
                            arguments: <String, String>{'type': TestCategoryType.recommendation.name},
                          );
                          context.telegramWebApp.hapticImpact(.medium);
                        },
                        onBuyButtonPressed: onBuyTestPressed,
                        onShareButtonPressed: onShareTestPressed,
                        onLikeButtonPressed: onLikeTestPressed,
                      ),
                    const SizedBox(height: 16),

                    // Referral banner
                    const Padding(padding: .symmetric(horizontal: 16), child: AnimatedReferralBanner()),

                    // Liked section (first 5 liked tests)
                    if (state.liked.isNotEmpty)
                      CustomPageView(
                        tests: state.liked.take(5).toList(),
                        title: context.x.l10n.likedTestsHeader,
                        onShowMore: () {
                          context.octopus.push(
                            Routes.moreRecommendation,
                            arguments: <String, String>{'type': TestCategoryType.liked.name},
                          );
                          context.telegramWebApp.hapticImpact(.medium);
                        },
                        onBuyButtonPressed: onBuyTestPressed,
                        onShareButtonPressed: onShareTestPressed,
                        onLikeButtonPressed: onLikeTestPressed,
                      ),

                    // All tests section
                    if (state.allTests.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const .symmetric(horizontal: 16),
                        child: SectionHeaderWidget(
                          title: context.x.l10n.allTests,
                          onTap: () => context.octopus.push(
                            Routes.moreRecommendation,
                            arguments: <String, String>{'type': TestCategoryType.allTests.name},
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const .symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth + 32;
                            const maxCardWidth = 360.0;
                            final crossAxisCount = (availableWidth / maxCardWidth).floor().clamp(1, 10);
                            return ResponsiveRecommendationsList(
                              tests: state.allTests,
                              crossAxisCount: crossAxisCount,
                              onBuyButtonPressed: onBuyTestPressed,
                              onShareButtonPressed: onShareTestPressed,
                              onLikeButtonPressed: onLikeTestPressed,
                            );
                          },
                        ),
                      ),
                      if (state.isAllTestsLoadingMore)
                        const Padding(
                          padding: .symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
