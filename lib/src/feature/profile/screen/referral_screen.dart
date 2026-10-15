import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/profile_cubit.dart';
import '../model/referral_model.dart';
import '../state/referral_screen_state.dart';

final NumberFormat _amountFormat = NumberFormat('#,###');
final DateFormat _dateFormat = DateFormat('HH:mm dd.MM.yyyy');

String _formatAmount(int value) => _amountFormat.format(value).replaceAll(',', ' ');

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ReferralScreenState {
  static const _maxWidth = BoxConstraints(maxWidth: 600);

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: hc.bg,
        resizeToAvoidBottomInset: false,
        appBar: QuizAppBar(
          title: context.x.l10n.referral,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: _maxWidth,
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: _ReferralTabBar()),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Rebuild only when data used by the referral tab changes,
                      // not on every pagination tick of the bonuses list.
                      BlocBuilder<ProfileCubit, ProfileState>(
                        buildWhen: (p, c) =>
                            p.user != c.user ||
                            p.status != c.status ||
                            p.referralSummary != c.referralSummary ||
                            p.referralStatus != c.referralStatus,
                        builder: (context, state) {
                          final summary = state.referralSummary;
                          if (state.user == null ||
                              state.status == StateStatus.loading ||
                              summary == null ||
                              state.referralStatus == StateStatus.loading) {
                            return const _ReferralShimmer();
                          }
                          return _ReferralTab(
                            referralLink: '${Constant.miniAppUrl}?startapp=r${state.user?.referralCode ?? ''}',
                            onCopy: onLinkCopy,
                            totalReferrals: summary.totalReferrals,
                            totalEarned: summary.totalEarned,
                          );
                        },
                      ),
                      const _AllBonusTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: hc.surface,
            border: Border(top: BorderSide(color: hc.border, width: 0.5)),
          ),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: _maxWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuizButton(
                          label: context.x.l10n.copy,
                          type: QuizButtonType.outline,
                          size: QuizButtonSize.l,
                          leadingIcon: Icons.copy_rounded,
                          expand: true,
                          onTap: onLinkCopy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuizButton(
                          label: context.x.l10n.send,
                          size: QuizButtonSize.l,
                          leadingLottie: QuizLottie.share,
                          expand: true,
                          onTap: onShareReferralLink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented tab switcher in the Home design language (track + raised pill).
class _ReferralTabBar extends StatelessWidget {
  const _ReferralTabBar();

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: hc.track, borderRadius: BorderRadius.circular(14)),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        splashFactory: NoSplash.splashFactory,
        dividerColor: context.x.colors.transparent,
        physics: const NeverScrollableScrollPhysics(),
        labelPadding: EdgeInsets.zero,
        overlayColor: WidgetStatePropertyAll(context.x.colors.transparent),
        indicator: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [hc.softShadow],
        ),
        labelColor: hc.text,
        unselectedLabelColor: hc.text3,
        labelStyle: quizText(15, wSemibold, hc.text),
        unselectedLabelStyle: quizText(15, wMedium, hc.text3),
        tabs: [
          Tab(text: context.x.l10n.referral),
          Tab(text: context.x.l10n.allBonuses),
        ],
      ),
    );
  }
}

class _ReferralTab extends StatelessWidget {
  const _ReferralTab({
    required this.referralLink,
    required this.onCopy,
    required this.totalReferrals,
    required this.totalEarned,
  });

  final String referralLink;
  final VoidCallback onCopy;
  final int totalReferrals;
  final int totalEarned;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // 1. Stats
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  icon: QuizLottie.addFriends,
                  accent: hc.primary,
                  tint: hc.primaryTint,
                  value: '$totalReferrals',
                  label: l10n.invitedFriends,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: QuizLottie.progress,
                  accent: hc.success,
                  tint: hc.successTint,
                  value: '${_formatAmount(totalEarned)} so‘m',
                  label: l10n.earnedBonus,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. How it works
        _Card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: hc.warningTint, borderRadius: BorderRadius.circular(14)),
                child: const QuizLottieIcon(QuizLottie.prize, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.howItWorks, style: quizText(16, wBold, hc.text)),
                    const SizedBox(height: 4),
                    Text(l10n.howItWorksDesc, style: quizText(14, wRegular, hc.text2, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Referral link
        _FieldLabel(l10n.referralLinkLabel),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: hc.primaryTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hc.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.link_rounded, size: 20, color: hc.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  referralLink,
                  style: quizText(14, wMedium, hc.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              QuizButton(label: l10n.copyShort, size: QuizButtonSize.s, leadingIcon: Icons.copy_rounded, onTap: onCopy),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. Share text preview
        _FieldLabel(l10n.shareTextLabel),
        _Card(
          child: Text.rich(
            TextSpan(
              style: quizText(15, wRegular, hc.text, height: 1.45),
              children: [
                TextSpan(text: l10n.shareTextMessage),
                TextSpan(text: referralLink, style: quizText(15, wMedium, hc.primary, height: 1.45)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow]),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text, style: quizText(13, wSemibold, context.x.homeColors.text3)),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.accent,
    required this.tint,
    required this.value,
    required this.label,
  });

  final QuizLottie icon;
  final Color accent;
  final Color tint;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Center(child: QuizLottieIcon(icon, size: 22, color: accent)),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: quizText(20, wBold, hc.text)),
          ),
          const SizedBox(height: 2),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: quizText(13, wRegular, hc.text3)),
        ],
      ),
    );
  }
}

class _AllBonusTab extends StatefulWidget {
  const _AllBonusTab();

  @override
  State<_AllBonusTab> createState() => _AllBonusTabState();
}

class _AllBonusTabState extends State<_AllBonusTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 200) return;
    final state = context.read<ProfileCubit>().state;
    if (!state.referralHasMore || state.isReferralListLoadingMore) return;
    context.read<ProfileCubit>().loadMoreReferrals();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    buildWhen: (p, c) =>
        p.referralListStatus != c.referralListStatus ||
        p.referralItems != c.referralItems ||
        p.referralTotal != c.referralTotal,
    builder: (context, state) {
      if (state.referralListStatus == StateStatus.loading) {
        return const _AllBonusShimmer();
      }

      final items = state.referralItems;
      if (items.isEmpty) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [EmptyTestWidget(title: context.x.l10n.noInvitationsYet, description: context.x.l10n.referralInfo)],
        );
      }

      final hasMore = state.referralHasMore;
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox.square(dimension: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
              ),
            );
          }
          return _ReferralListItem(key: ValueKey(items[index].referredUserId), item: items[index]);
        },
      );
    },
  );
}

class _ReferralListItem extends StatelessWidget {
  const _ReferralListItem({required this.item, super.key});
  final ReferralItem item;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final signedUpAt = item.signedUpAt;
    final dateStr = signedUpAt != null ? _dateFormat.format(signedUpAt.toLocal()) : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(16), boxShadow: [hc.softShadow]),
      child: Row(
        children: [
          _Avatar(url: item.referredAvatar, name: item.referredName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.referredName.isNotEmpty ? item.referredName : '—',
                  style: quizText(15, wSemibold, hc.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(dateStr, style: quizText(12, wRegular, hc.text3)),
                ],
              ],
            ),
          ),
          if (item.bonusAmount > 0) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                QuizPill(
                  text: '+${_formatAmount(item.bonusAmount)} ${context.x.l10n.uzs}',
                  background: hc.successTint,
                  foreground: hc.success,
                  fontSize: 13,
                ),
                const SizedBox(height: 4),
                Text(context.x.l10n.referral, style: quizText(12, wRegular, hc.text3)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});
  final String url;
  final String name;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final fallback = QuizInitialAvatar(
      initial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      color: hc.primary,
      background: hc.primaryTint,
      size: _size,
      borderWidth: 0,
    );
    if (url.isEmpty) return fallback;

    final cacheSize = (_size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipOval(
      child: Image.network(
        url,
        width: _size,
        height: _size,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

// ── Skeletons ────────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.child, this.radius = 20, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(color: context.x.homeColors.surface, borderRadius: BorderRadius.circular(radius)),
    child: QuizShimmer(child: child),
  );
}

class _AllBonusShimmer extends StatelessWidget {
  const _AllBonusShimmer();

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    itemCount: 8,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (_, _) => const _SkeletonCard(
      radius: 16,
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          ShimmerBox(width: 44, height: 44, radius: 100),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14, radius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 12, radius: 6),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 80, height: 22, radius: 100),
              SizedBox(height: 4),
              ShimmerBox(width: 50, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ReferralShimmer extends StatelessWidget {
  const _ReferralShimmer();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    children: const [
      Row(
        children: [
          Expanded(child: _StatSkeleton()),
          SizedBox(width: 12),
          Expanded(child: _StatSkeleton()),
        ],
      ),
      SizedBox(height: 16),
      _SkeletonCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 48, height: 48, radius: 14),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 16, radius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: double.infinity, height: 12, radius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(width: double.infinity, height: 12, radius: 6),
                  SizedBox(height: 6),
                  ShimmerBox(width: 160, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      QuizShimmer(child: ShimmerBox(width: 110, height: 13, radius: 6)),
      SizedBox(height: 8),
      _SkeletonCard(
        radius: 14,
        padding: EdgeInsets.all(8),
        child: ShimmerBox(width: double.infinity, height: 32, radius: 10),
      ),
      SizedBox(height: 20),
      QuizShimmer(child: ShimmerBox(width: 130, height: 13, radius: 6)),
      SizedBox(height: 8),
      _SkeletonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: double.infinity, height: 14, radius: 6),
            SizedBox(height: 8),
            ShimmerBox(width: double.infinity, height: 14, radius: 6),
            SizedBox(height: 8),
            ShimmerBox(width: 180, height: 14, radius: 6),
          ],
        ),
      ),
    ],
  );
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) => const _SkeletonCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 36, height: 36, radius: 12),
        SizedBox(height: 12),
        ShimmerBox(width: 70, height: 20, radius: 6),
        SizedBox(height: 6),
        ShimmerBox(width: 100, height: 12, radius: 6),
      ],
    ),
  );
}
