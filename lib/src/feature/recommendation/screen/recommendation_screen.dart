import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/widgets/animated_referral_banner.dart';
import '../state/recommendation_screen_state.dart';
import '../widget/custom_page_view.dart';

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
              Assets.lib.vectors.filter.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: .mode(context.x.colors.primary, .srcATop),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              CustomPageView(
                items: const ['Test 1', 'Test 2', 'Test 3'],
                title: context.x.l10n.recommendation,
                onShowMore: () => context.octopus.pushNamed(Routes.moreRecommendation.name),
                onShareButtonPressed: onShareButtonPressed,
              ),
              const SizedBox(height: 16),
              const Padding(padding: .symmetric(horizontal: 16), child: AnimatedReferralBanner()),
              CustomPageView(items: const ['Test 1', 'Test 2'], title: context.x.l10n.popular),
              Padding(
                padding: const .symmetric(horizontal: 16),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text(
                          context.x.l10n.allTests,
                          style: context.x.textStyle.sfW700s28.copyWith(
                            fontSize: 22,
                            color: context.x.colors.bannerText,
                          ),
                        ),
                        Assets.lib.vectors.chevronRight.svg(
                          package: 'ui',
                          width: 24,
                          height: 24,
                          colorFilter: .mode(context.x.colors.bannerText, .srcATop),
                        ),
                      ],
                    ),
                    for (var i = 0; i < 10; i++)
                      TestCardWidget(
                        title: 'Test $i',
                        companyName: 'Company $i',
                        description: 'Description $i',
                        price: '100000',
                        questionAmount: '10',
                        buyButtonText: context.x.l10n.buy,
                        onBuyButtonPressed: () {},
                        onShareButtonPressed: () {
                          onShareButtonPressed('Test $i', 'Company $i', 'Description $i', '100000', '10');
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
