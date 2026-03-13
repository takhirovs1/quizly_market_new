import '../../ui.dart';
import '../extension/context_extension.dart';

class PageIndicator extends StatefulWidget {
  const PageIndicator({required this.selectedPage, required this.totalPages, super.key});
  final int totalPages;
  final int selectedPage;
  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: context.x.colors.indicatorBackground, borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i <= widget.totalPages - 1; i++)
            SizedBox(
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
        ],
      ),
    ),
  );
}
