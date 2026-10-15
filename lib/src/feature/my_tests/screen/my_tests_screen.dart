import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/my_test_cubit.dart';
import '../data/home_repository.dart';
import '../models/home/home_enums.dart';
import '../models/home/my_tests_preview_model.dart';
import '../state/my_tests_screen_state.dart';
import '../widgets/home/activity_card.dart';
import '../widgets/home/friends_rating_card.dart';
import '../widgets/home/hero_continue_card.dart';
import '../widgets/home/home_section.dart';
import '../widgets/home/home_skeletons.dart';
import '../widgets/home/home_status_chips.dart';
import '../widgets/home/home_test_card.dart';
import '../widgets/home/product_card.dart';
import '../widgets/home/quick_actions_row.dart';
import '../widgets/home/referral_card.dart';
import '../widgets/home/sponsor_carousel.dart';

class MyTestsScreen extends StatefulWidget {
  const MyTestsScreen({super.key});

  @override
  State<MyTestsScreen> createState() => _MyTestsScreenState();
}

class _MyTestsScreenState extends MyTestsScreenState {
  static const _hPad = EdgeInsets.symmetric(horizontal: 16);
  static const _gap = SizedBox(height: 16);
  static const _colGap = SizedBox(width: 20);

  /// Column count scales with the available width so the page fills the screen
  /// instead of a fixed centered strip: 1 column on phones / narrow Mini App,
  /// 2 on tablet-landscape, 3 on desktop. Each column stays ~420–520 px wide.
  int _columnCount(double width) => width >= 1340 ? 3 : (width >= 900 ? 2 : 1);

  /// Content is centered and capped so columns never stretch to an unreadable
  /// width on ultra-wide monitors; below the cap it tracks the real width.
  double _maxContentWidth(int columns) => switch (columns) {
    3 => 1560,
    2 => 1040,
    _ => 600,
  };

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        showBackButton: false,
        title: context.x.l10n.myTests,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        onTitlePointerDown: onTitlePointerDown,
        onTitlePointerUp: onTitlePointerUp,
        onTitlePointerCancel: onTitlePointerCancel,
      ),
      body: SafeArea(
        top: false,
        // Let the body flow behind the floating desktop nav bar (like the other
        // tabs); the ListView adds a desktop-only bottom padding to clear it.
        bottom: false,
        child: RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: BlocBuilder<MyTestCubit, MyTestState>(
            bloc: myTestCubit,
            builder: (context, state) => LayoutBuilder(
              builder: (context, constraints) {
                final columns = _columnCount(constraints.maxWidth);
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _maxContentWidth(columns)),
                    child: _buildList(state, columns),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Hero, sponsor and the recommendations carousel always span the full content
  /// width; the five stackable cards flow into [columns] columns in between.
  Widget _buildList(MyTestState state, int columns) {
    final continueWidget = _buildContinue(state);
    final adsWidget = _buildAds(state);
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.only(top: 16, bottom: context.x.isMobile ? 28 : 120),
      children: [
        if (continueWidget != null) ...[Padding(padding: _hPad, child: continueWidget), _gap],
        Padding(padding: _hPad, child: _cardGrid(state, columns)),
        _gap,
        if (adsWidget != null) ...[adsWidget, _gap],
        _buildRecommendations(state),
      ],
    );
  }

  /// The five stackable cards arranged into [columns] balanced columns. The
  /// per-column assignment keeps the tall "Mening testlarim" card on its own so
  /// the columns stay roughly the same height.
  Widget _cardGrid(MyTestState state, int columns) {
    final actions = _buildActions(state);
    final myTests = _buildMyTests(state);
    final activity = _buildActivity(state);
    final friends = _buildFriends(state);
    final referral = _buildReferral(state);

    if (columns == 1) {
      return _column([actions, myTests, activity, friends, referral]);
    }
    final layout = columns >= 3
        ? <List<Widget>>[
            [myTests],
            [actions, referral],
            [activity, friends],
          ]
        : <List<Widget>>[
            [actions, myTests],
            [activity, friends, referral],
          ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < layout.length; i++) ...[if (i > 0) _colGap, Expanded(child: _column(layout[i]))],
      ],
    );
  }

  Widget _column(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) _gap, children[i]],
    ],
  );

  // ── Continue (hidden on 204 / error) ────────────────────────────────────────
  Widget? _buildContinue(MyTestState state) {
    final status = state.statusOf(HomeEndpoints.continueCard);
    if (status.isLoading || status.isIdle) return const HomeHeroSkeleton();
    final card = state.continueCard;
    if (card == null) return null;
    return HeroContinueCard(card: card, onContinue: () => onContinue(card));
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Widget _buildActions(MyTestState state) {
    final actions = state.homeActions;
    final enabled = (actions?.hasPurchasedTests ?? false) || state.exampleTestDetail != null;
    return HomeSection(
      status: state.statusOf(HomeEndpoints.actions),
      errorMessage: state.sectionError(HomeEndpoints.actions),
      onRetry: () => onRetrySection(HomeEndpoints.actions),
      skeleton: const HomeActionsSkeleton(),
      child: QuickActionsRow(
        enabled: enabled,
        mistakesCount: actions?.mistakesCount ?? 0,
        onRandom: onRandomTest,
        onMistakes: onMistakes,
        onFlashcard: onFlashcard,
      ),
    );
  }

  // ── Mening testlarim ─────────────────────────────────────────────────────────
  Widget _buildMyTests(MyTestState state) {
    final preview = state.myTestsPreview;
    return HomeSection(
      status: state.statusOf(HomeEndpoints.myTests),
      errorMessage: state.sectionError(HomeEndpoints.myTests),
      onRetry: () => onRetrySection(HomeEndpoints.myTests),
      skeleton: const Column(children: [HomeTestCardSkeleton(), SizedBox(height: 12), HomeTestCardSkeleton()]),
      child: (preview != null && preview.items.isNotEmpty) ? _myTestsWithItems(preview) : _myTestsEmpty(state),
    );
  }

  Widget _myTestsWithItems(MyTestsPreviewResponse preview) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      QuizSectionHeader(
        title: context.x.l10n.myTestsHeader,
        seeAllLabel: context.x.l10n.homeSeeAll,
        onSeeAll: onSeeAllMyTests,
      ),
      const SizedBox(height: 12),
      // Chips filter the preview locally (no navigation). The notifier is owned
      // by the screen state so the selection survives BlocBuilder rebuilds.
      ValueListenableBuilder<MyTestStatus?>(
        valueListenable: myTestsFilterNotifier,
        builder: (context, selected, _) {
          final items = selected == null
              ? preview.items
              : preview.items.where((item) => item.status == selected).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeStatusChips(counts: preview.counts, selected: selected, onSelect: onMyTestsFilter),
              const SizedBox(height: 12),
              if (items.isEmpty)
                _myTestsFilterEmpty()
              else
                for (final item in items.take(3)) ...[
                  HomeTestCard(
                    title: item.name,
                    organizationName: item.organizationName,
                    organizationVerified: item.organizationVerified,
                    status: item.status,
                    answered: item.answered,
                    total: item.total,
                    percent: item.percent,
                    resultPercent: item.bestScorePercent,
                    ratingRank: item.ratingRank,
                    ratingTotalParticipants: item.ratingTotalParticipants,
                    onTap: () => onOpenPreviewTest(item),
                    onRatingTap: () =>
                        onOpenRating(item.testId, name: item.name, organizationName: item.organizationName),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    ],
  );

  /// Shown when the selected status chip matches none of the loaded preview
  /// items. The totals in the chips still reflect every test — "Barchasi ›"
  /// opens the full list.
  Widget _myTestsFilterEmpty() {
    final hc = context.x.homeColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: hc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hc.border),
      ),
      alignment: Alignment.center,
      child: Text(context.x.l10n.homeFilterEmpty, textAlign: TextAlign.center, style: quizText(14, wMedium, hc.text3)),
    );
  }

  Widget _myTestsEmpty(MyTestState state) {
    final l10n = context.x.l10n;
    final example = state.exampleTestDetail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizSectionHeader(title: l10n.myTestsHeader),
        const SizedBox(height: 12),
        if (example != null) ...[
          // The free example test behaves as the user's only test (task §2).
          HomeTestCard(
            title: example.name ?? '',
            organizationName: example.universityName ?? 'QuizlyMarket',
            organizationVerified: true,
            status: MyTestStatus.notStarted,
            answered: 0,
            total: example.questionCount ?? 0,
            percent: 0,
            isExample: true,
            onTap: onExampleStart,
          ),
          const SizedBox(height: 12),
          QuizEmptyState(
            card: false,
            title: l10n.homeEmptyTestsTitle,
            description: l10n.homeEmptyTestsDesc,
            illustration: const QuizLottieIcon(QuizLottie.bookCollection, size: 60),
            buttonLabel: l10n.homeGoToMarket,
            onPressed: onGoToMarket,
          ),
        ] else
          QuizEmptyState(
            title: l10n.homeEmptyTestsTitle,
            description: l10n.homeEmptyTestsDesc,
            illustration: const QuizLottieIcon(QuizLottie.bookCollection, size: 60),
            buttonLabel: l10n.homeGoToMarket,
            onPressed: onGoToMarket,
          ),
      ],
    );
  }

  // ── Activity ─────────────────────────────────────────────────────────────────
  Widget _buildActivity(MyTestState state) => HomeSection(
    status: state.statusOf(HomeEndpoints.activity),
    errorMessage: state.sectionError(HomeEndpoints.activity),
    onRetry: () => onRetrySection(HomeEndpoints.activity),
    skeleton: const HomeCardSkeleton(),
    child: state.homeActivity == null ? const SizedBox.shrink() : ActivityCard(data: state.homeActivity!),
  );

  // ── Friends ──────────────────────────────────────────────────────────────────
  Widget _buildFriends(MyTestState state) => HomeSection(
    status: state.statusOf(HomeEndpoints.friends),
    errorMessage: state.sectionError(HomeEndpoints.friends),
    onRetry: () => onRetrySection(HomeEndpoints.friends),
    skeleton: const HomeCardSkeleton(),
    child: state.friendsRating == null
        ? const SizedBox.shrink()
        : FriendsRatingCard(data: state.friendsRating!, onInvite: onOpenFriends, onOpenRating: onOpenLeaderboard),
  );

  // ── Referral ─────────────────────────────────────────────────────────────────
  Widget _buildReferral(MyTestState state) => HomeSection(
    status: state.statusOf(HomeEndpoints.referral),
    errorMessage: state.sectionError(HomeEndpoints.referral),
    onRetry: () => onRetrySection(HomeEndpoints.referral),
    skeleton: const HomeCardSkeleton(),
    child: state.referralSummary == null
        ? const SizedBox.shrink()
        : ReferralCard(data: state.referralSummary!, onShare: onShareReferral, onOpenAll: onOpenReferral),
  );

  // ── Sponsor ads (hidden when none) ───────────────────────────────────────────
  Widget? _buildAds(MyTestState state) {
    if (!state.statusOf(HomeEndpoints.ads).isSuccess) return null;
    final ads = state.visibleAds;
    if (ads.isEmpty) return null;
    return Padding(
      padding: _hPad,
      child: SponsorCarousel(ads: ads, onTapAd: onAdTap, onDismiss: onAdDismiss, onImpression: onAdImpression),
    );
  }

  // ── Recommendations ──────────────────────────────────────────────────────────
  Widget _buildRecommendations(MyTestState state) {
    final l10n = context.x.l10n;
    final rec = state.recommendations;
    final popular = rec?.isPopularFallback ?? false;
    return HomeSection(
      status: state.statusOf(HomeEndpoints.recommendations),
      errorMessage: state.sectionError(HomeEndpoints.recommendations),
      onRetry: () => onRetrySection(HomeEndpoints.recommendations),
      skeleton: const Padding(padding: _hPad, child: HomeProductRowSkeleton()),
      child: rec == null || rec.items.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: _hPad,
                  child: QuizSectionHeader(
                    title: popular ? l10n.homePopularTitle : l10n.homeRecommendationsTitle,
                    subtitle: popular ? l10n.homePopularSubtitle : l10n.homeRecommendationsSubtitle,
                    seeAllLabel: l10n.homeSeeAll,
                    onSeeAll: onGoToMarket,
                  ),
                ),
                const SizedBox(height: 12),
                RecommendationsCarousel(items: rec.items, onTapItem: onRecommendationTap, onFavorite: onToggleFavorite),
              ],
            ),
    );
  }
}
