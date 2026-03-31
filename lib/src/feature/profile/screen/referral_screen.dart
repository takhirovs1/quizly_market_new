import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../state/referral_screen_state.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ReferralScreenState {
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: context.x.colors.primary,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: context.telegramWebApp.safeAreaInset.top + 56,
        surfaceTintColor: context.x.colors.transparent,
        title: Column(
          children: [
            SizedBox(height: context.telegramWebApp.safeAreaInset.top.toDouble()),
            Center(
              child: Text(
                context.x.l10n.referral,
                style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const .all(16),
            child: DecoratedBox(
              decoration: BoxDecoration(color: context.x.colors.bannerBackground, borderRadius: .circular(10)),
              child: SizedBox(
                height: 45,
                child: TabBar(
                  padding: const .all(4),
                  indicatorSize: .tab,
                  splashFactory: NoSplash.splashFactory,
                  dividerColor: context.x.colors.transparent,
                  isScrollable: false,
                  physics: const NeverScrollableScrollPhysics(),
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: EdgeInsets.zero,
                  overlayColor: WidgetStatePropertyAll(context.x.colors.transparent),
                  indicator: BoxDecoration(
                    color: context.x.colors.white,
                    borderRadius: .circular(8),
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
          const Expanded(
            child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [_ReferralTap(), _AllBonusTap()]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const .only(left: 16, right: 16, bottom: 16),
          child: CustomButton2(
            onRightPressed: onShareReferralLink,
            onLeftPressed: onLinkCopy,
            rightText: context.x.l10n.send,
            leftText: context.x.l10n.copy,
            width: context.x.width,
            rightButtonType: .active,
          ),
        ),
      ),
    ),
  );
}

class _ReferralTap extends StatelessWidget {
  const _ReferralTap();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .all(16),
    child: Column(
      crossAxisAlignment: .start,
      children: [
        Text(context.x.l10n.warning, style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text),
            children: [
              TextSpan(text: context.x.l10n.inviteFriends),
              TextSpan(text: context.x.l10n.quizlyMarket, style: context.x.textStyle.sfW700s16),
              TextSpan(text: context.x.l10n.inviteTo),
              TextSpan(text: context.x.l10n.referral, style: context.x.textStyle.sfW700s16),
              TextSpan(text: context.x.l10n.shareLinkDesc),
              TextSpan(text: context.x.l10n.link, style: context.x.textStyle.sfW700s16),
              TextSpan(text: context.x.l10n.registrationViaLink),
              TextSpan(text: '+1000 so‘m ', style: context.x.textStyle.sfW700s16),
              TextSpan(text: context.x.l10n.balanceAdded),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.x.l10n.shareTextLabel,
          style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text),
            children: [
              TextSpan(text: context.x.l10n.shareTextMessage),
              TextSpan(
                text: 'https://t.me/quizlymarketbot?startapp=r1251798314',
                style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.primary),
              ),
            ],
          ),
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
