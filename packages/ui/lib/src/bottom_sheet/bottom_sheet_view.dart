import '../../../ui.dart';
import '../extension/context_extension.dart';

/// {@template bottom_sheet_view}
/// BottomSheetView widget.
/// {@endtemplate}
class BottomSheetView extends StatelessWidget {
  /// {@macro bottom_sheet_view}
  const BottomSheetView({
    required this.title,
    required this.child,
    this.backgroundColor,
    this.isCenterTitle = true,
    this.headerCrossAxisAlignment = CrossAxisAlignment.center,
    this.onClose,
    this.leading,
    super.key, // ignore: unused_element
  });

  final bool isCenterTitle;
  final String title;
  final Widget child;
  final Widget? leading;
  final Color? backgroundColor;
  final void Function()? onClose;
  final CrossAxisAlignment headerCrossAxisAlignment;

  @override
  Widget build(BuildContext context) => Material(
    color: backgroundColor ?? Theme.of(context).appColors.scaffoldBackground,
    shape: const SmoothRectangleBorders(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: headerCrossAxisAlignment,
            children: [
              if (isCenterTitle) Expanded(child: leading ?? const SizedBox.shrink()),
              Text(title, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18)),
              Expanded(
                child: onClose == null
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: onClose,
                          // style: IconButton.styleFrom(backgroundColor: Theme.of(context).appColors.divider),
                          icon: SizedBox.square(
                            dimension: 10,
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: CustomCloseIconPainter(color: Theme.of(context).appColors.onSecondary),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        Divider(color: ThemeColors.of(context).buttonBorder),
        child,
      ],
    ),
  );
}

class CustomCloseIconPainter extends CustomPainter {
  const CustomCloseIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawLine(Offset.zero, Offset(size.width, size.height), paint)
      ..drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
