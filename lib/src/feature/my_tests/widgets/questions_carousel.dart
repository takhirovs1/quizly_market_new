import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/demo_test_model.dart';
import 'question_card_widget.dart';

class QuestionsCarousel extends StatefulWidget {
  const QuestionsCarousel({required this.questions, required this.languageCode, required this.currentPage, super.key});

  final List<DemoQuestion> questions;
  final String languageCode;
  final ValueNotifier<int> currentPage;

  @override
  State<QuestionsCarousel> createState() => _QuestionsCarouselState();
}

class _QuestionsCarouselState extends State<QuestionsCarousel> {
  late final PageController _pageController;
  late List<GlobalKey> _measureKeys;
  double? _maxHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _measureKeys = .generate(widget.questions.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant QuestionsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questions != oldWidget.questions) {
      _measureKeys = .generate(widget.questions.length, (_) => GlobalKey());
      _maxHeight = null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _measureHeights(_) {
    if (!mounted || widget.questions.isEmpty) return;
    var max = 0.0;
    for (final key in _measureKeys) {
      final h = key.currentContext?.size?.height ?? 0.0;
      if (h > max) max = h;
    }
    final targetHeight = max > 0 ? max.ceilToDouble() : null;
    if (targetHeight != null && _maxHeight != targetHeight) {
      setState(() => _maxHeight = targetHeight);
    }
  }

  BoxDecoration _cardDecoration(BuildContext context, {required bool isActive}) => BoxDecoration(
    color: context.x.colors.cardBackground2,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: context.x.colors.divider),
    boxShadow: isActive
        ? [BoxShadow(color: context.x.colors.black.withValues(alpha: .06), offset: const Offset(0, 4), blurRadius: 16)]
        : null,
  );

  Widget _buildCard(BuildContext context, DemoQuestion question, {required bool isActive, Key? key}) => Padding(
    key: key,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: DecoratedBox(
      decoration: _cardDecoration(context, isActive: isActive),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: QuestionCardWidget(question: question, languageCode: widget.languageCode),
      ),
    ),
  );

  Widget _buildChevronButton({required BuildContext context, required IconData icon, required VoidCallback? onTap}) =>
      Container(
        decoration: BoxDecoration(
          color: onTap != null
              ? context.x.colors.cardBackground2
              : context.x.colors.cardBackground2.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.1)),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: context.x.colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          color: context.x.colors.primary,
          disabledColor: context.x.colors.bannerSecondaryText.withValues(alpha: 0.3),
          splashRadius: 20,
          constraints: const .tightFor(width: 40, height: 40),
          padding: EdgeInsets.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback(_measureHeights);
    final showChevrons = !context.x.isMobile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Offstage(
          child: Row(
            children: [
              if (showChevrons) ...[const SizedBox(width: 8), const SizedBox(width: 40)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < widget.questions.length; i++)
                      _buildCard(context, widget.questions[i], isActive: true, key: _measureKeys[i]),
                  ],
                ),
              ),
              if (showChevrons) ...[const SizedBox(width: 40), const SizedBox(width: 8)],
            ],
          ),
        ),
        if (_maxHeight != null) ...[
          if (showChevrons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable: widget.currentPage,
                  builder: (context, current, _) {
                    final hasPrevious = current > 0;
                    return _buildChevronButton(
                      context: context,
                      icon: Icons.chevron_left,
                      onTap: hasPrevious
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
                    );
                  },
                ),
                Expanded(
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: _maxHeight,
                        child: PageView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.none,
                          controller: _pageController,
                          itemCount: widget.questions.length,
                          onPageChanged: (index) => widget.currentPage.value = index,
                          itemBuilder: (context, index) => ValueListenableBuilder<int>(
                            valueListenable: widget.currentPage,
                            builder: (context, current, _) =>
                                _buildCard(context, widget.questions[index], isActive: index == current),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: widget.currentPage,
                  builder: (context, current, _) {
                    final hasNext = current < widget.questions.length - 1;
                    return _buildChevronButton(
                      context: context,
                      icon: Icons.chevron_right,
                      onTap: hasNext
                          ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          else
            ClipRect(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: _maxHeight,
                  child: PageView.builder(
                    clipBehavior: Clip.none,
                    controller: _pageController,
                    itemCount: widget.questions.length,
                    onPageChanged: (index) => widget.currentPage.value = index,
                    itemBuilder: (context, index) => ValueListenableBuilder<int>(
                      valueListenable: widget.currentPage,
                      builder: (context, current, _) =>
                          _buildCard(context, widget.questions[index], isActive: index == current),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: widget.currentPage,
            builder: (context, current, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PageIndicator(
                  selectedPage: current,
                  totalPages: widget.questions.length,
                  onPageSelected: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
