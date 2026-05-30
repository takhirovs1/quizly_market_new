import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/more_recommendation_screen_state.dart';

class MoreRecommendationScreen extends StatefulWidget {
  const MoreRecommendationScreen({super.key});

  @override
  State<MoreRecommendationScreen> createState() => _MoreRecommendationScreenState();
}

class _MoreRecommendationScreenState extends MoreRecommendationScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      title: context.x.l10n.quizlyMarket,
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
                child: AppTextField(
                  controller: searchController,
                  title: context.x.l10n.search,
                  prefixWidget: Assets.lib.vectors.search.svg(
                    package: 'ui',
                    width: 24,
                    height: 24,
                    colorFilter: .mode(context.x.colors.bannerSecondaryText, .srcATop),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.telegramWebApp.hapticImpact(TelegramHapticImpact.medium),
                child: Assets.lib.vectors.filter.svg(
                  package: 'ui',
                  width: 24,
                  height: 24,
                  colorFilter: .mode(context.x.colors.primary, .srcATop),
                ),
              ),
              GestureDetector(
                onTap: onSortPressed,
                child: Assets.lib.vectors.sort.svg(
                  package: 'ui',
                  width: 24,
                  height: 24,
                  colorFilter: .mode(context.x.colors.primary, .srcATop),
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) => Expanded(
            child: GridView.builder(
              padding: const .symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 210,
                mainAxisExtent: 245,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => MiniTestCardWidget(
                title: 'Example test',
                companyName: 'QuizlyMarket',
                description: 'Example test description, Example test description, Example test description',
                price: context.x.l10n.free,
                questionAmount: '100 ta savol',
                buyButtonText: context.x.l10n.tryItNow,
                onBuyButtonPressed: () => context.telegramWebApp.hapticImpact(TelegramHapticImpact.medium),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
