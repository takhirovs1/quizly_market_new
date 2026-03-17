import 'package:flutter/material.dart';
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
  late final ValueNotifier<double> overscrollAmount;
  late final ScrollController scrollController;

  bool hasTriggeredShowMore = false;
  bool scrollingListenerAttached = false;

  void attachScrollingListener() {
    if (!scrollController.hasClients || scrollingListenerAttached) return;
    scrollingListenerAttached = true;
    scrollController.position.isScrollingNotifier.addListener(onScrollingChanged);
  }

  void onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    attachScrollingListener();
    final maxPage = (widget.items.length - 1).clamp(0, widget.items.length);
    final page = (pos.pixels / 350).floor().clamp(0, maxPage);
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

  @override
  void initState() {
    super.initState();
    isPageControllerEnded = ValueNotifier(false);
    selectedPage = ValueNotifier(0);
    overscrollAmount = ValueNotifier(0);
    scrollController = ScrollController();
    scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    if (scrollingListenerAttached && scrollController.hasClients) {
      scrollController.position.isScrollingNotifier.removeListener(onScrollingChanged);
    }
    scrollController.removeListener(onScroll);
    isPageControllerEnded.dispose();
    selectedPage.dispose();
    overscrollAmount.dispose();
    scrollController.dispose();
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
      SizedBox(
        height: 144,
        child: Stack(
          children: [
            ListView.separated(
              controller: scrollController,
              scrollDirection: .horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const .symmetric(horizontal: 16),
              itemBuilder: (context, index) => SizedBox(
                width: 350,
                child: BannerWidget(
                  title: 'Test nomi',
                  companyName: 'Tashkilot nomi',
                  description: 'Test description Test description Test description Test description',
                  price: '10 000 UZS',
                  questionAmount: '100 ta savol',
                  buyButtonText: context.x.l10n.buy,
                  onBuyButtonPressed: () {},
                  onShareButtonPressed: () {},
                ),
              ),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemCount: widget.items.length,
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
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<int>(
        valueListenable: selectedPage,
        builder: (context, value, child) => PageIndicator(selectedPage: value, totalPages: widget.items.length),
      ),
    ],
  );
}
