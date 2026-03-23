import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/my_tests_screen_state.dart';
import '../widgets/animated_referral_banner.dart';

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
      title: 'Testlarim',
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: Padding(
        padding: const .symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            EmptyTestWidget(
              title: context.x.l10n.youDontHaveAnyTestsYet,
              description: context.x.l10n.thereAreTestsOnaVarietyOfTopicsAvailableOnTheMarket,
            ),

            const SizedBox(height: 20),
            Row(children: [Text(context.x.l10n.tryItNow, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22))]),
            for (var i = 0; i < 1; i++)
              BannerWidget(
                title: 'Example test',
                companyName: 'QuizlyMarket',
                description: 'Example test description, Example test description, Example test description',
                price: context.x.l10n.free,
                questionAmount: '100 ta savol',
                buyButtonText: context.x.l10n.tryItNow,
                onBuyButtonPressed: () {},
                isFree: true,
              ),
            const SizedBox(height: 22),
            const AnimatedReferralBanner(),
            const SizedBox(height: 24),
            Text(context.x.l10n.recommendation, style: context.x.textStyle.sfW700s16.copyWith(fontSize: 22)),
            for (var i = 0; i < 4; i++)
              Column(
                children: [
                  BannerWidget(
                    title: 'Example test',
                    companyName: 'QuizlyMarket',
                    description: 'Example test description, Example test description, Example test description',
                    price: context.x.l10n.free,
                    questionAmount: '100 ta savol',
                    buyButtonText: context.x.l10n.tryItNow,
                    onBuyButtonPressed: onBuyTestPressed,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
