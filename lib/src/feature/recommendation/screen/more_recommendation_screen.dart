import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../my_tests/bloc/my_test_cubit.dart';
import '../../my_tests/models/test_model.dart';
import '../bloc/recommendation_cubit.dart';
import '../state/more_recommendation_screen_state.dart';
import '../widget/test_view_mode_toggle.dart';

enum TestCategoryType { myTests, topTests, recommendation, liked, allTests }

class MoreRecommendationScreen extends StatefulWidget {
  const MoreRecommendationScreen({required this.type, super.key});

  final TestCategoryType type;

  @override
  State<MoreRecommendationScreen> createState() => _MoreRecommendationScreenState();
}

class _MoreRecommendationScreenState extends MoreRecommendationScreenState {
  Widget _buildTestCard(TestModel test) {
    final isPurchased = test.isPurchased == true;
    final buyText = isPurchased
        ? context.x.l10n.enterTest
        : (test.price == 0 || test.price == null ? context.x.l10n.tryItNow : context.x.l10n.buy);

    return TestCardWidget(
      title: test.name ?? '',
      companyName: test.categoryName ?? '',
      description: test.description ?? '',
      price: isPurchased
          ? context.x.l10n.purchased
          : (test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs),
      questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
      buyButtonText: buyText,
      onBuyButtonPressed: () => onBuyTestPressed(test),
      onShareButtonPressed: () => onShareTestPressed(test),
      isFree: test.price == 0 || test.price == null,
      isPurchased: isPurchased,
    );
  }

  Widget _buildMiniTestCard(TestModel test) {
    final isPurchased = test.isPurchased == true;
    final buyText = isPurchased
        ? context.x.l10n.enterTest
        : (test.price == 0 || test.price == null ? context.x.l10n.tryItNow : context.x.l10n.buy);

    return MiniTestCardWidget(
      title: test.name ?? '',
      companyName: test.categoryName ?? '',
      description: test.description ?? '',
      price: isPurchased
          ? context.x.l10n.purchased
          : (test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs),
      questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
      buyButtonText: buyText,
      onBuyButtonPressed: () => onBuyTestPressed(test),
      isPurchased: isPurchased,
    );
  }

  Widget _buildListContent(List<TestModel> tests) => LayoutBuilder(
    builder: (context, constraints) {
      final layout = computeListLayout(constraints.maxWidth + MoreRecommendationScreenState.horizontalPadding);

      if (layout.crossAxisCount == 1) {
        return ListView.separated(
          controller: scrollController,
          padding: const .only(left: 16, right: 16, bottom: 16),
          itemCount: tests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _buildTestCard(tests[index]),
        );
      }

      return GridView.builder(
        controller: scrollController,
        padding: const .only(left: 16, right: 16, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: layout.crossAxisCount,
          mainAxisExtent: layout.mainAxisExtent,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: tests.length,
        itemBuilder: (_, index) => _buildTestCard(tests[index]),
      );
    },
  );

  Widget _buildListShimmer() => LayoutBuilder(
    builder: (context, constraints) {
      final layout = computeListLayout(constraints.maxWidth + MoreRecommendationScreenState.horizontalPadding);

      if (layout.crossAxisCount == 1) {
        return ListView.separated(
          padding: const .symmetric(horizontal: 16),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, _) => const Center(
            child: SizedBox(width: MoreRecommendationScreenState.maxCardWidth, child: TestCardShimmer()),
          ),
        );
      }

      return GridView.builder(
        padding: const .symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: layout.crossAxisCount,
          mainAxisExtent: layout.mainAxisExtent,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const Center(
          child: SizedBox(width: MoreRecommendationScreenState.maxCardWidth, child: TestCardShimmer()),
        ),
      );
    },
  );

  Widget _buildContent({
    required TestViewMode viewMode,
    required List<TestModel> tests,
    required bool isLoading,
    required bool hasMoreLoading,
  }) {
    if (isLoading) {
      if (viewMode == .grid) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = computeGridLayout(constraints.maxWidth + MoreRecommendationScreenState.horizontalPadding);
            return GridView.builder(
              padding: const .symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: layout.crossAxisCount,
                mainAxisExtent: layout.mainAxisExtent,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (_, _) => const MiniTestCardShimmer(),
            );
          },
        );
      }
      return _buildListShimmer();
    }

    if (tests.isEmpty) {
      final isSearching = searchController.text.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 24),
          child: EmptyTestWidget(
            title: isSearching
                ? context.x.l10n.noTestsFound
                : (widget.type == .myTests ? context.x.l10n.youDontHaveAnyTestsYet : context.x.l10n.noTestsFound),
            description: isSearching ? context.x.l10n.trySearchingWithOtherKeywords : '',
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: viewMode == .grid
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final layout = computeGridLayout(
                      constraints.maxWidth + MoreRecommendationScreenState.horizontalPadding,
                    );
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: layout.crossAxisCount,
                        mainAxisExtent: layout.mainAxisExtent,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: tests.length,
                      itemBuilder: (_, index) => _buildMiniTestCard(tests[index]),
                    );
                  },
                )
              : _buildListContent(tests),
        ),
        if (hasMoreLoading)
          const Padding(
            padding: .symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.type) {
      .myTests => context.x.l10n.myTestsHeader,
      .topTests => context.x.l10n.topTests,
      .recommendation => context.x.l10n.recommendationsHeader,
      .liked => context.x.l10n.likedTests,
      .allTests => context.x.l10n.allTests,
    };

    return Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: title,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: Column(
        crossAxisAlignment: .stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: AppTextField(
                      controller: searchController,
                      title: context.x.l10n.search,
                      prefixWidget: Assets.lib.vectors.search.svg(package: 'ui', width: 24, height: 24),
                    ),
                  ),
                ),
                TestViewModeToggle(notifier: viewModeNotifier),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<TestViewMode>(
              valueListenable: viewModeNotifier,
              builder: (context, viewMode, _) {
                if (widget.type == .myTests) {
                  return BlocBuilder<MyTestCubit, MyTestState>(
                    builder: (context, state) => _buildContent(
                      viewMode: viewMode,
                      tests: state.myTests,
                      isLoading: state.status.isLoading,
                      hasMoreLoading: state.isMyTestsLoadingMore,
                    ),
                  );
                } else {
                  return BlocBuilder<RecommendationCubit, RecommendationState>(
                    builder: (context, state) {
                      final List<TestModel> tests;
                      final bool hasMoreLoading;
                      switch (widget.type) {
                        case .recommendation || .topTests:
                          tests = state.recommendations;
                          hasMoreLoading = false;
                        case .liked:
                          tests = state.liked;
                          hasMoreLoading = false;
                        default:
                          tests = state.allTests;
                          hasMoreLoading = state.isAllTestsLoadingMore;
                      }
                      return _buildContent(
                        viewMode: viewMode,
                        tests: tests,
                        isLoading: state.status.isLoading,
                        hasMoreLoading: hasMoreLoading,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
