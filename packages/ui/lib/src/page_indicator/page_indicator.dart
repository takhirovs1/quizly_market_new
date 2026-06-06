import '../../ui.dart';
import '../extension/context_extension.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator({required this.selectedPage, required this.totalPages, this.onPageSelected, super.key});
  final int totalPages;
  final int selectedPage;
  final ValueChanged<int>? onPageSelected;
  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: context.x.colors.indicatorBackground, borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        spacing: 0,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i <= widget.totalPages - 1; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onPageSelected?.call(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: SizedBox(
                  width: 8,
                  height: 8,
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
