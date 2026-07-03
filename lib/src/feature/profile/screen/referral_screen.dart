import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/constant/constant.dart';
import '../../../common/util/state_status.dart';
import '../bloc/profile_cubit.dart';
import '../model/referral_model.dart';
import '../state/referral_screen_state.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ReferralScreenState {
  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) {
      final referralCode = state.user?.referralCode ?? '';
      final link = '${Constant.miniAppUrl}?startapp=r$referralCode';
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: context.x.colors.scaffoldBackground,
          resizeToAvoidBottomInset: false,
          appBar: QuizAppBar(
            title: context.x.l10n.referral,
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.x.colors.bannerBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        height: 45,
                        child: TabBar(
                          padding: const EdgeInsets.all(4),
                          indicatorSize: TabBarIndicatorSize.tab,
                          splashFactory: NoSplash.splashFactory,
                          dividerColor: context.x.colors.transparent,
                          isScrollable: false,
                          physics: const NeverScrollableScrollPhysics(),
                          labelPadding: EdgeInsets.zero,
                          indicatorPadding: EdgeInsets.zero,
                          overlayColor: WidgetStatePropertyAll(context.x.colors.transparent),
                          indicator: BoxDecoration(
                            color: context.x.colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: context.x.colors.black.withValues(alpha: .06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          labelColor: context.x.colors.black,
                          labelStyle: context.x.textStyle.sfW600s16,
                          unselectedLabelStyle: context.x.textStyle.sfW400s16,
                          tabs: [
                            Tab(text: context.x.l10n.referral),
                            Tab(text: context.x.l10n.allBonuses),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (state.user == null ||
                            state.status == StateStatus.loading ||
                            state.referralSummary == null ||
                            state.referralStatus == StateStatus.loading)
                          const _ReferralShimmer()
                        else
                          _ReferralTap(
                            referralLink: link,
                            onCopy: onLinkCopy,
                            totalReferrals: state.referralSummary!.totalReferrals,
                            totalEarned: state.referralSummary!.totalEarned,
                          ),
                        const _AllBonusTap(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: CustomButton2(
                    onRightPressed: onShareReferralLink,
                    onLeftPressed: onLinkCopy,
                    rightText: context.x.l10n.send,
                    leftText: context.x.l10n.copy,
                    width: context.x.width,
                    rightButtonType: ButtonType.active,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ReferralTap extends StatelessWidget {
  const _ReferralTap({
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
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. STATS ROW
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.x.colors.bannerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        '$totalReferrals',
                        style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.x.l10n.invitedFriends,
                        style: context.x.textStyle.sfW400s12.copyWith(color: context.x.colors.gray),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.x.colors.bannerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        '${NumberFormat('#,###').format(totalEarned).replaceAll(',', ' ')} so‘m',
                        style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.x.l10n.earnedBonus,
                        style: context.x.textStyle.sfW400s12.copyWith(color: context.x.colors.gray),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. INFO CARD
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.x.colors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.x.l10n.howItWorks,
                  style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.text),
                ),
                const SizedBox(height: 8),
                Text(
                  context.x.l10n.howItWorksDesc,
                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. REFERRAL LINK CARD
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                context.x.l10n.referralLinkLabel,
                style: context.x.textStyle.sfW500s12.copyWith(color: context.x.colors.gray),
              ),
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1C59F2).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF1C59F2), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        referralLink,
                        style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onCopy,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C59F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              context.x.l10n.copyShort,
                              style: context.x.textStyle.sfW500s12.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 4. SHARE TEXT CARD
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                context.x.l10n.shareTextLabel,
                style: context.x.textStyle.sfW500s12.copyWith(color: context.x.colors.gray),
              ),
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: context.x.colors.divider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RichText(
                  text: TextSpan(
                    style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text),
                    children: [
                      TextSpan(text: context.x.l10n.shareTextMessage),
                      TextSpan(
                        text: referralLink,
                        style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _AllBonusTap extends StatefulWidget {
  const _AllBonusTap();

  @override
  State<_AllBonusTap> createState() => _AllBonusTapState();
}

class _AllBonusTapState extends State<_AllBonusTap> {
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProfileCubit>().loadMoreReferrals();
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) {
      // Loading initial
      if (state.referralListStatus == StateStatus.loading) {
        return const _AllBonusShimmer();
      }

      // Empty
      if (state.referralItems.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyTestWidget(title: context.x.l10n.noInvitationsYet, description: context.x.l10n.referralInfo),
        );
      }

      return ListView.separated(
        controller: _scrollController,
        itemCount: state.referralItems.length + (state.referralHasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.referralItems.length) {
            // Load-more footer
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
              ),
            );
          }
          return _ReferralListItem(item: state.referralItems[index]);
        },
        separatorBuilder: (context, separatorIndex) {
          if (separatorIndex >= state.referralItems.length - 1) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(left: 66),
            child: Divider(height: 20, color: context.x.colors.divider),
          );
        },
      );
    },
  );
}

class _ReferralListItem extends StatelessWidget {
  const _ReferralListItem({required this.item});
  final ReferralItem item;

  @override
  Widget build(BuildContext context) {
    final dateStr = item.signedUpAt != null ? DateFormat('HH:mm dd.MM.yyyy').format(item.signedUpAt!.toLocal()) : '';
    final bonusStr = '+${NumberFormat('#,###').format(item.bonusAmount).replaceAll(',', ' ')} UZS';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 10,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: item.referredAvatar.isNotEmpty
                ? Image.network(
                    item.referredAvatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => _DefaultAvatar(name: item.referredName),
                  )
                : _DefaultAvatar(name: item.referredName),
          ),
          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.referredName.isNotEmpty ? item.referredName : '—',
                  style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateStr.isNotEmpty)
                  Text(dateStr, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
              ],
            ),
          ),
          // Bonus
          if (item.bonusAmount > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(bonusStr, style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.primary)),
                Text(
                  context.x.l10n.referral,
                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.primary),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.x.colors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Text(letter, style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.primary)),
    );
  }
}

class _AllBonusShimmer extends StatelessWidget {
  const _AllBonusShimmer();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey[300]! : Colors.grey[800]!;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.grey[700]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        itemCount: 8,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            spacing: 10,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 50,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ],
          ),
        ),
        separatorBuilder: (context, _) => Padding(
          padding: const EdgeInsets.only(left: 66),
          child: Divider(height: 20, color: Colors.white.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _ReferralShimmer extends StatelessWidget {
  const _ReferralShimmer();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey[300]! : Colors.grey[800]!;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.grey[700]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS ROW SHIMMER
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 76,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. INFO CARD SHIMMER
            Container(
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),

            // 3. REFERRAL LINK CARD SHIMMER
            Container(
              height: 20,
              width: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 6),
            Container(
              height: 60,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 16),

            // 4. SHARE TEXT CARD SHIMMER
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 6),
            Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }
}
