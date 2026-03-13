import 'package:flutter/material.dart';

import '../border/smooth_rectangle_border.dart';
import '../theme/theme.dart';

/// A widget that displays a notification with a given [message] and [backgroundColor].
///
/// The notification is displayed at the top of the screen with a fade-in animation.
/// After the given [duration], the notification is removed with a fade-out animation.
///
/// The notification is displayed with a [Material] widget and a [Container] widget.
/// The [Material] widget is used to provide a background color and a shadow.
/// The [Container] widget is used to provide padding and a border radius.
///
/// The notification is displayed with a [Text] widget.
/// The [Text] widget is used to display the given [message].
/// The [Text] widget is styled with the given [textStyle].
/// The [Text] widget is centered and has a maximum of 2 lines.
///
/// The notification is removed after the given [duration].
/// The notification is removed with a fade-out animation.
class CustomNotification extends StatefulWidget {
  const CustomNotification({
    required this.message,
    required this.textStyle,
    required this.radius,
    super.key,
    this.backgroundColor = Colors.black87,
    this.duration = const Duration(seconds: 3),
    this.icon,
    this.errorStatusCode,
  });

  final String message;
  final Color backgroundColor;
  final TextStyle textStyle;
  final Duration duration;
  final BorderRadius radius;
  final Widget? icon;
  final String? errorStatusCode;

  static OverlayEntry? _currentOverlay;

  static OverlayEntry? show({
    required BuildContext context,
    required String message,
    Color? backgroundColor,
    TextStyle? textStyle,
    Duration? duration,
    bool isSuccess = false,
    Widget? icon,
    BorderRadius radius = BorderRadius.zero,
    String? errorStatusCode,
  }) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomNotification(
        message: message,
        backgroundColor:
            backgroundColor ?? (isSuccess ? Theme.of(context).appColors.success : Theme.of(context).appColors.error),
        textStyle:
            textStyle ?? TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).appColors.white),
        duration: duration ?? const Duration(seconds: 3),
        icon: icon,
        radius: radius,
        errorStatusCode: errorStatusCode,
      ),
    );

    _currentOverlay = overlayEntry;
    overlayState.insert(overlayEntry);

    return overlayEntry;
  }

  static void hideCurrentNotification() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn, reverseCurve: Curves.easeOut));

    _animationController.forward();

    Future<void>.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.reverse().whenComplete(() {
          CustomNotification._currentOverlay?.remove();
          CustomNotification._currentOverlay = null;
        }).ignore();
      }
    }).ignore();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(_fadeAnimation),
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: widget.backgroundColor,
            shape: SmoothRectangleBorders(borderRadius: widget.radius),
            shadows: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) => CustomPaint(
                painter: widget.errorStatusCode != null
                    ? StatusPainter(size: constraints.biggest, statusCode: widget.errorStatusCode!)
                    : null,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 12,
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ),
                  child: switch (widget.icon == null) {
                    true => Text(
                      widget.message,
                      style: widget.textStyle,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    false => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.icon ?? const SizedBox(),
                        const SizedBox(width: 8),
                        Text(
                          widget.message,
                          style: widget.textStyle,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class StatusPainter extends CustomPainter {
  StatusPainter({required this.size, required this.statusCode});

  final Size size;

  final String statusCode;

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: statusCode,
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: Color.fromARGB(116, 255, 255, 255)),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width);

    // Paint the text at specific position
    final offset = Offset(size.width - textPainter.width - 8, size.height - textPainter.height - 4);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant StatusPainter oldDelegate) => oldDelegate.statusCode != statusCode;
}
