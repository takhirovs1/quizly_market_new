import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../my_tests/models/test_model.dart';

class CustomPageView extends StatefulWidget {
  const CustomPageView({
    required this.tests,
    required this.title,
    super.key,
    this.onShowMore,
    this.onBuyButtonPressed,
    this.onShareButtonPressed,
    this.onLikeButtonPressed,
  });

  final String title;
  final VoidCallback? onShowMore;
  final List<TestModel> tests;
  final void Function(TestModel test)? onBuyButtonPressed;
  final void Function(TestModel test)? onShareButtonPressed;
  final void Function(TestModel test)? onLikeButtonPressed;

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  late final ValueNotifier<int> selectedPage;
  late final ValueNotifier<double> overscrollAmount;
  late final ScrollController scrollController;

  bool hasTriggeredShowMore = false;
  bool scrollingListenerAttached = false;

  static const double _cardWidth = 350;
  static const double _cardSpacing = 12;
  static const double _horizontalPadding = 16;

  void attachScrollingListener() {
    if (!scrollController.hasClients || scrollingListenerAttached) return;
    scrollingListenerAttached = true;
    scrollController.position.isScrollingNotifier.addListener(onScrollingChanged);
  }

  void onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    attachScrollingListener();
    final maxPage = (widget.tests.length - 1).clamp(0, widget.tests.length);
    final cardWidth = pos.viewportDimension > 0 ? pos.viewportDimension * 0.95 : _cardWidth;
    final page = (pos.pixels / (cardWidth + _cardSpacing)).round().clamp(0, maxPage);
    if (selectedPage.value != page) selectedPage.value = page;
    if (pos.maxScrollExtent <= 0) return;
    final overscroll = pos.pixels - pos.maxScrollExtent;
    if (overscroll > 0) {
      overscrollAmount.value = overscroll;
      if (overscroll >= 40 && !hasTriggeredShowMore) {
        hasTriggeredShowMore = true;
        widget.onShowMore?.call();
      }
    } else {
      overscrollAmount.value = 0;
    }
  }

  void onScrollingChanged() {
    if (!scrollController.position.isScrollingNotifier.value) {
      overscrollAmount.value = 0;
      hasTriggeredShowMore = false;
    }
  }

  void scrollToPage(int pageIndex) {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    final cardWidth = pos.viewportDimension > 0 ? pos.viewportDimension * 0.95 : _cardWidth;
    final targetOffset = pageIndex * (cardWidth + _cardSpacing);
    scrollController.animateTo(
      targetOffset.toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    selectedPage = ValueNotifier(0);
    overscrollAmount = ValueNotifier(0);
    scrollController = ScrollController()..addListener(onScroll);
  }

  @override
  void dispose() {
    if (scrollingListenerAttached && scrollController.hasClients) {
      scrollController.position.isScrollingNotifier.removeListener(onScrollingChanged);
    }
    scrollController
      ..removeListener(onScroll)
      ..dispose();
    selectedPage.dispose();
    overscrollAmount.dispose();
    super.dispose();
  }

  Widget _buildTestCard(TestModel test) => TestCardWidget(
    title: test.name ?? '',
    companyName: test.categoryName ?? '',
    description: test.description ?? '',
    price: test.isPurchased == true
        ? context.x.l10n.purchased
        : (test.price == 0 || test.price == null ? context.x.l10n.free : test.price!.formatUzs),
    questionAmount: context.x.l10n.questionAmountText(test.questionCount ?? 0),
    buyButtonText: test.isPurchased == true ? context.x.l10n.enterTest : context.x.l10n.buy,
    onBuyButtonPressed: () => widget.onBuyButtonPressed?.call(test),
    isFree: test.price == 0 || test.price == null,
    isPurchased: test.isPurchased == true,
    onShareButtonPressed: () => widget.onShareButtonPressed?.call(test),
    isLiked: test.isLiked == true,
    onLikeButtonPressed: widget.onLikeButtonPressed != null ? () => widget.onLikeButtonPressed?.call(test) : null,
    textBought: context.x.l10n.textBought,
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final visibleCards = ((availableWidth - _horizontalPadding * 2 + _cardSpacing) / (_cardWidth + _cardSpacing))
          .floor()
          .clamp(1, widget.tests.length);
      final isMultiCard = visibleCards > 1;

      // If multiple cards fit, show them in a responsive grid row instead of a horizontal PageView
      if (isMultiCard) {
        return Column(
          children: [
            Padding(
              padding: const .symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: context.x.textStyle.w700s28.copyWith(fontSize: 22, color: context.x.colors.bannerText),
                  ),
                  GestureDetector(
                    onTap: widget.onShowMore,
                    child: Assets.lib.vectors.chevronRight.svg(
                      package: 'ui',
                      width: 24,
                      height: 24,
                      colorFilter: .mode(context.x.colors.bannerText, .srcATop),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const .symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: .stretch,
                  children: [
                    for (var i = 0; i < widget.tests.take(visibleCards).length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: _buildTestCard(widget.tests[i])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // Single card visible — use horizontal scrolling PageView with indicator
      return Column(
        children: [
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: context.x.textStyle.w700s28.copyWith(fontSize: 22, color: context.x.colors.bannerText),
                ),
                GestureDetector(
                  onTap: widget.onShowMore,
                  child: Assets.lib.vectors.chevronRight.svg(
                    package: 'ui',
                    width: 24,
                    height: 24,
                    colorFilter: .mode(context.x.colors.bannerText, .srcATop),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                scrollDirection: .horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: .stretch,
                      children: [
                        for (var i = 0; i < widget.tests.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          SizedBox(width: availableWidth * 0.95, child: _buildTestCard(widget.tests[i])),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: ValueListenableBuilder<double>(
                  valueListenable: overscrollAmount,
                  builder: (context, amount, _) {
                    if (amount <= 0) return const SizedBox.shrink();
                    final size = (12 + amount * 0.4).clamp(12, 46);
                    return Center(
                      child: Assets.lib.vectors.bigChevronRight.svg(
                        package: 'ui',
                        width: size * 0.26,
                        height: size.toDouble(),
                        colorFilter: .mode(context.x.colors.bannerText, .srcATop),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (widget.tests.length > 1) ...[
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: selectedPage,
              builder: (context, value, child) =>
                  PageIndicator(selectedPage: value, totalPages: widget.tests.length, onPageSelected: scrollToPage),
            ),
          ],
        ],
      );
    },
  );
}
