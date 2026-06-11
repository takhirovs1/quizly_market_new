import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/state_status.dart';
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
      isLiked: test.isLiked == true,
      onLikeButtonPressed: () => onLikeTestPressed(test),
      textBought: context.x.l10n.textBought,
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
      onShareButtonPressed: () => onShareTestPressed(test),
      onLikeButtonPressed: () => onLikeTestPressed(test),
      isPurchased: isPurchased,
      isLiked: test.isLiked == true,
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
    required bool isError,
    required String? errorMessage,
    required VoidCallback onRefresh,
  }) {
    if (isLoading && tests.isEmpty) {
      if (viewMode == TestViewMode.grid) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = computeGridLayout(constraints.maxWidth + MoreRecommendationScreenState.horizontalPadding);
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

    if (isError && tests.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Center(
            child: EmptyTestWidget(
              title: context.x.l10n.somethingWentWrong,
              description: ErrorUtil.localizeError(context, errorMessage ?? 'pleaseTryAgainLater'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(onPressed: onRefresh, child: Text(context.x.l10n.retry)),
          ),
        ],
      );
    }

    if (tests.isEmpty) {
      final isSearching = searchController.text.trim().isNotEmpty;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: EmptyTestWidget(
                title: isSearching
                    ? context.x.l10n.noTestsFound
                    : (widget.type == TestCategoryType.myTests
                          ? context.x.l10n.youDontHaveAnyTestsYet
                          : context.x.l10n.noTestsFound),
                description: isSearching ? context.x.l10n.trySearchingWithOtherKeywords : '',
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: viewMode == TestViewMode.grid
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
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.type) {
      TestCategoryType.myTests => context.x.l10n.myTestsHeader,
      TestCategoryType.topTests => context.x.l10n.topTests,
      TestCategoryType.recommendation => context.x.l10n.recommendationsHeader,
      TestCategoryType.liked => context.x.l10n.likedTests,
      TestCategoryType.allTests => context.x.l10n.allTests,
    };

    return Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: title,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                if (widget.type == TestCategoryType.myTests) {
                  return BlocConsumer<MyTestCubit, MyTestState>(
                    listener: (context, state) {
                      if (state.status == StateStatus.error && state.myTests.isNotEmpty) {
                        ErrorUtil.showSnackBar(context, state.errorMessage ?? context.x.l10n.somethingWentWrong);
                      }
                    },
                    builder: (context, state) {
                      Future<void> refreshCallback() => myTestCubit.getMyTests(search: searchController.text);
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => refreshCallback(),
                        child: _buildContent(
                          viewMode: viewMode,
                          tests: state.myTests,
                          isLoading: state.status.isLoading,
                          hasMoreLoading: state.isMyTestsLoadingMore,
                          isError: state.status == StateStatus.error,
                          errorMessage: state.errorMessage,
                          onRefresh: refreshCallback,
                        ),
                      );
                    },
                  );
                } else {
                  return BlocConsumer<RecommendationCubit, RecommendationState>(
                    listener: (context, state) {
                      final List<TestModel> tests;
                      switch (widget.type) {
                        case TestCategoryType.recommendation || TestCategoryType.topTests:
                          tests = state.recommendations;
                        case TestCategoryType.liked:
                          tests = state.liked;
                        default:
                          tests = state.allTests;
                      }
                      if (state.status.isError && tests.isNotEmpty) {
                        ErrorUtil.showSnackBar(context, state.errorMessage ?? context.x.l10n.somethingWentWrong);
                      }
                    },
                    builder: (context, state) {
                      final List<TestModel> tests;
                      final bool hasMoreLoading;
                      final VoidCallback refreshCallback;
                      switch (widget.type) {
                        case TestCategoryType.recommendation || TestCategoryType.topTests:
                          tests = state.recommendations;
                          hasMoreLoading = false;
                          refreshCallback = () =>
                              recommendationCubit.getRecommendationTests(search: searchController.text);
                        case TestCategoryType.liked:
                          tests = state.liked;
                          hasMoreLoading = false;
                          refreshCallback = () => recommendationCubit.getLikedTests(search: searchController.text);
                        default:
                          tests = state.allTests;
                          hasMoreLoading = state.isAllTestsLoadingMore;
                          refreshCallback = () => recommendationCubit.getAllTests(search: searchController.text);
                      }
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => refreshCallback(),
                        child: _buildContent(
                          viewMode: viewMode,
                          tests: tests,
                          isLoading: state.status.isLoading,
                          hasMoreLoading: hasMoreLoading,
                          isError: state.status.isError,
                          errorMessage: state.errorMessage,
                          onRefresh: refreshCallback,
                        ),
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
