import '../../ui.dart';
import '../extension/context_extension.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator({
    required this.selectedPage,
    required this.totalPages,
    this.onPageSelected,
    this.maxVisibleDots = 7,
    super.key,
  });
  final int totalPages;
  final int selectedPage;
  final ValueChanged<int>? onPageSelected;

  /// Maximum number of dots rendered at once. When [totalPages] exceeds this,
  /// a sliding window centered on [selectedPage] is shown, with the dots at the
  /// window edges shrunk to hint that more pages exist.
  final int maxVisibleDots;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) {
    final total = widget.totalPages;
    final maxVisible = widget.maxVisibleDots;
    final showWindow = total > maxVisible;

    // First page index to render within the sliding window.
    var start = 0;
    if (showWindow) {
      start = widget.selectedPage - maxVisible ~/ 2;
      if (start < 0) start = 0;
      if (start > total - maxVisible) start = total - maxVisible;
    }
    final end = showWindow ? start + maxVisible : total;

    return DecoratedBox(
      decoration: BoxDecoration(color: context.x.colors.indicatorBackground, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          spacing: 0,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = start; i < end; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onPageSelected?.call(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: SizedBox(
                    width: _dotSize(i, start, end, showWindow),
                    height: _dotSize(i, start, end, showWindow),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: i == widget.selectedPage
                            ? context.x.colors.white
                            : context.x.colors.white.withValues(alpha: .25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Shrinks the edge dots of the window (when there are hidden pages beyond
  /// them) so the indicator reads as a scrollable strip.
  double _dotSize(int index, int start, int end, bool showWindow) {
    if (!showWindow) return 8;
    if (index == start && start > 0) return 4;
    if (index == end - 1 && end < widget.totalPages) return 4;
    if (index == start + 1 && start > 0) return 6;
    if (index == end - 2 && end < widget.totalPages) return 6;
    return 8;
  }
}
