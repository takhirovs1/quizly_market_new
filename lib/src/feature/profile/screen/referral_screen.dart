import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/profile_cubit.dart';
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
      final link = 'https://t.me/prjkttest_bot?startapp=r$referralCode';
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
                        if (state.user == null || state.status == StateStatus.loading)
                          const _ReferralShimmer()
                        else
                          _ReferralTap(referralLink: link, onCopy: onLinkCopy),
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
  const _ReferralTap({required this.referralLink, required this.onCopy});

  final String referralLink;
  final VoidCallback onCopy;

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
                      Text('20', style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text)),
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
                      Text('20 000 so‘m', style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text)),
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

class _AllBonusTap extends StatelessWidget {
  const _AllBonusTap();

  @override
  Widget build(BuildContext context) {
    // ignore: literal_only_boolean_expressions
    if (true)
      return ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) => Padding(
          padding: const .symmetric(horizontal: 16),
          child: Row(
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: .circular(100),
                child: Image.asset(Assets.lib.images.logo.path, width: 40, height: 40, package: Constant.packageUi),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Takhirovs', style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text)),
                  Text('23:30 12.11.2026', style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text('+1,000 UZS', style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.primary)),
                  Text(
                    context.x.l10n.referral,
                    style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        separatorBuilder: (context, index) => Padding(
          padding: const .only(left: 66),
          child: Divider(height: 20, color: context.x.colors.divider),
        ),
      );
    else
      // ignore: dead_code
      return Padding(
        padding: const .all(16),
        child: EmptyTestWidget(title: context.x.l10n.noInvitationsYet, description: context.x.l10n.referralInfo),
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
