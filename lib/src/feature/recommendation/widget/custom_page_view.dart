import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class CustomPageView extends StatefulWidget {
  const CustomPageView({required this.items, required this.title, super.key, this.onShowMore});

  final String title;
  final VoidCallback? onShowMore;
  final List<String> items;

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  late final ValueNotifier<bool> isPageControllerEnded;
  late final ValueNotifier<int> selectedPage;
  late final PageController pageController = PageController(viewportFraction: (context.x.width - 24) / context.x.width)
    ..addListener(pageControllerListener);

  void pageControllerListener() {
    selectedPage.value = (pageController.page ?? 0).round();
    if ((pageController.page ?? 0) > widget.items.length - 1.13)
      isPageControllerEnded.value = true;
    else
      isPageControllerEnded.value = false;
  }

  @override
  void initState() {
    super.initState();
    isPageControllerEnded = ValueNotifier(false);
    selectedPage = ValueNotifier(0);
  }

  @override
  void dispose() {
    isPageControllerEnded.dispose();
    selectedPage.dispose();
    pageController
      ..removeListener(pageControllerListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: widget.onShowMore,
        child: Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                widget.title,
                style: context.x.textStyle.w700s28.copyWith(fontSize: 22, color: context.x.colors.bannerText),
              ),
              Assets.lib.vectors.chevronRight.svg(
                package: 'ui',
                width: 24,
                height: 24,
                colorFilter: .mode(context.x.colors.bannerText, .srcATop),
              ),
            ],
          ),
        ),
      ),
      Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              SizedBox(
                height: 144,
                width: context.x.width - 44,
                child: PageView(
                  padEnds: false,
                  controller: pageController,
                  clipBehavior: .none,
                  children: [
                    for (var i = 0; i < widget.items.length; i++)
                      Padding(
                        padding: .only(left: 4, right: i == widget.items.length - 1 ? 16 : 4),
                        child: BannerWidget(
                          title: 'Test nomi',
                          companyName: 'Tashkilot nomi',
                          description: 'Test description Test description Test description Test description',
                          price: '10 000 UZS',
                          questionAmount: '100 ta savol',
                          buyButtonText: 'Sotib olish',
                          onBuyButtonPressed: () {},
                          onShareButtonPressed: () {},
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: isPageControllerEnded,
            builder: (context, value, child) => !value
                ? const SizedBox.shrink()
                : Positioned(
                    top: 49,
                    right: 0,
                    child: InkWell(
                      onTap: widget.onShowMore,
                      child: SizedBox(
                        width: 32,
                        child: Assets.lib.vectors.bigChevronRight.svg(
                          package: 'ui',
                          width: 12,
                          height: 46,
                          colorFilter: .mode(context.x.colors.bannerText, .srcATop),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder(
        valueListenable: selectedPage,
        builder: (context, value, child) => PageIndicator(selectedPage: value, totalPages: widget.items.length),
      ),
    ],
  );
}
