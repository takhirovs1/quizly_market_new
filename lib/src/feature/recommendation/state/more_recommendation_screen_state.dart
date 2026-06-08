import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/bloc/my_test_cubit.dart';
import '../../my_tests/models/test_model.dart';
import '../bloc/recommendation_cubit.dart';
import '../screen/more_recommendation_screen.dart';
import '../widget/test_view_mode_toggle.dart';

abstract class MoreRecommendationScreenState extends State<MoreRecommendationScreen> {
  late final MyTestCubit myTestCubit;
  late final RecommendationCubit recommendationCubit;
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  late final ValueNotifier<TestViewMode> viewModeNotifier;
  Timer? _debounceTimer;
  var _isLoadingMore = false;

  /// Max card width for list view mode (in logical pixels).
  static const double maxCardWidth = 360;

  /// Horizontal padding (left + right) applied to the grid/list.
  static const double horizontalPadding = 32; // 16 * 2

  /// Computes the adaptive layout for the list view mode.
  ({int crossAxisCount, double mainAxisExtent}) computeListLayout(double screenWidth) {
    final availableWidth = screenWidth - horizontalPadding;
    final crossAxisCount = (availableWidth / maxCardWidth).floor().clamp(1, 10);
    const mainAxisExtent = 185.0;
    return (crossAxisCount: crossAxisCount, mainAxisExtent: mainAxisExtent);
  }

  /// Min card width for grid view mode (in logical pixels).
  static const double minGridCardWidth = 180;

  /// Computes the adaptive layout for the grid view mode.
  ({int crossAxisCount, double mainAxisExtent}) computeGridLayout(double screenWidth) {
    final availableWidth = screenWidth - horizontalPadding;
    final crossAxisCount = (availableWidth / minGridCardWidth).floor().clamp(2, 4);
    const mainAxisExtent = 260.0;
    return (crossAxisCount: crossAxisCount, mainAxisExtent: mainAxisExtent);
  }

  void onSortPressed() {
    context.telegramWebApp.hapticImpact(.medium);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => BottomSheetView(
        backgroundColor: context.x.colors.bottomSheetSurface,
        onClose: () => Navigator.pop(context),
        isCenterTitle: false,
        title: context.x.l10n.sort,
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 10,
            children: [
              for (var i = 0; i < 2; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.x.colors.scaffoldBackground,
                    borderRadius: const .all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 12),
                        blurRadius: 56,
                        color: context.x.colors.black.withValues(alpha: .08),
                      ),
                      BoxShadow(
                        offset: const Offset(0, 3),
                        blurRadius: 3,
                        color: context.x.colors.black.withValues(alpha: .05),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(context.x.l10n.recentlyAdded, style: context.x.textStyle.sfW400s14.copyWith(fontSize: 18)),
                        Assets.lib.vectors.checkCircle.svg(package: 'ui', width: 24, height: 24),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              CustomButton(
                onTap: () {},
                color: context.x.colors.primary,
                textColor: context.x.colors.white,
                title: context.x.l10n.sort,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    viewModeNotifier = ValueNotifier<TestViewMode>(TestViewMode.grid);
    scrollController = ScrollController()..addListener(_onScroll);
    myTestCubit = context.read<MyTestCubit>();
    recommendationCubit = context.read<RecommendationCubit>();

    if (widget.type == TestCategoryType.myTests) {
      myTestCubit.getMyTests();
    } else if (widget.type == TestCategoryType.topTests || widget.type == TestCategoryType.recommendation) {
      recommendationCubit.getRecommendationTests();
    } else if (widget.type == TestCategoryType.liked) {
      recommendationCubit.getLikedTests();
    } else if (widget.type == TestCategoryType.allTests) {
      recommendationCubit.getAllTests();
    }

    searchController = TextEditingController()..addListener(_onSearchChanged);
    _lastText = searchController.text;
    context.setupTelegramBackButton();
  }

  String _lastText = '';

  void _onSearchChanged() {
    final text = searchController.text;
    if (text == _lastText) return;
    _lastText = text;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final query = text.trim();
    if (query.isNotEmpty && query.length <= 3) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (widget.type == TestCategoryType.myTests) {
        myTestCubit.getMyTests(search: query);
      } else if (widget.type == TestCategoryType.topTests || widget.type == TestCategoryType.recommendation) {
        recommendationCubit.getRecommendationTests(search: query);
      } else if (widget.type == TestCategoryType.liked) {
        recommendationCubit.getLikedTests(search: query);
      } else if (widget.type == TestCategoryType.allTests) {
        recommendationCubit.getAllTests(search: query);
      }
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _isLoadingMore = true;
      final Future<void> future;
      if (widget.type == TestCategoryType.myTests) {
        future = myTestCubit.getMyTests(loadMore: true);
      } else if (widget.type == TestCategoryType.topTests || widget.type == TestCategoryType.recommendation) {
        future = recommendationCubit.getRecommendationTests(loadMore: true);
      } else if (widget.type == TestCategoryType.liked) {
        future = recommendationCubit.getLikedTests(loadMore: true);
      } else {
        future = recommendationCubit.getAllTests(loadMore: true);
      }
      future.whenComplete(() => _isLoadingMore = false);
    }
  }

  void onBuyTestPressed(TestModel test) =>
      context.octopus.push(Routes.purchaseTest, arguments: <String, String>{'id': test.id?.toString() ?? ''});

  void onShareTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      test.name ?? '',
      test.categoryName ?? '',
      test.description ?? '',
      test.price?.toString() ?? '0',
      test.questionCount?.toString() ?? '0',
    );
  }

  void onLikeTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    if (widget.type == .myTests) {
      myTestCubit.toggleLikeTest(test);
    } else {
      recommendationCubit.toggleLikeTest(test);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    scrollController.dispose();
    viewModeNotifier.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
