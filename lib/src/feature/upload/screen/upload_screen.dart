import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        title: context.x.l10n.downlods,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
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
                  tabs: const [
                    Tab(text: 'Mening testlarim'),
                    Tab(text: 'Yangi yuklash'),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                EmptyTestWidget(
                  title: 'Siz hali test yuklamadingiz',
                  description:
                      'Test yuklash orqali QuizlyMarket’da o’z testingizni yarating va harbir sotuvdan 20% cashback oling',
                ),
                EmptyTestWidget(
                  title: 'Siz hali test yuklamadingiz',
                  description:
                      'Test yuklash orqali QuizlyMarket’da o’z testingizni yarating va harbir sotuvdan 20% cashback oling',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
