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
    appBar: const QuizAppBar(title: 'QuizlyMarket'),
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
                  title: 'Search',
                  prefixWidget: Assets.lib.vectors.search.svg(
                    package: 'ui',
                    width: 24,
                    height: 24,
                    colorFilter: .mode(context.x.colors.bannerSecondaryText, .srcATop),
                  ),
                ),
              ),
              Assets.lib.vectors.filter.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: .mode(context.x.colors.bannerText, .srcATop),
              ),
              InkWell(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => BottomSheetView(
                    backgroundColor: context.x.colors.bottomSheetBackground,
                    onClose: () => Navigator.pop(context),
                    isCenterTitle: false,
                    title: 'Saralash',
                    child: Padding(
                      padding: const .symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        spacing: 10,
                        children: [
                          for (var i = 0; i < 2; i++)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: context.x.colors.white,
                                borderRadius: const .all(.circular(16)),
                              ),
                              child: Padding(
                                padding: const .symmetric(horizontal: 16, vertical: 24),
                                child: Row(
                                  mainAxisAlignment: .spaceBetween,
                                  children: [
                                    Text(
                                      'Yaqinda qo’shilgan',
                                      style: context.x.textStyle.w400s14.copyWith(fontSize: 18),
                                    ),
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
                            title: 'Saralash',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Assets.lib.vectors.sort.svg(
                  package: 'ui',
                  width: 24,
                  height: 24,
                  colorFilter: .mode(context.x.colors.bannerText, .srcATop),
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
                mainAxisExtent: 215,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => MiniBannerWidget(
                title: 'Example test',
                companyName: 'QuizlyMarket',
                description: 'Example test description, Example test description, Example test description',
                price: 'Tekin',
                questionAmount: '100 ta savol',
                buyButtonText: 'Sinab ko’rish',
                onBuyButtonPressed: () {},
                onShareButtonPressed: () {},
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
