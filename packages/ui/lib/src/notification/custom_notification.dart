import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

/// A widget that displays a notification message on the screen.
///
/// Features:
/// - Appears temporarily and disappears automatically after a set duration
/// - Can be dismissed by tapping on it
/// - Customizable appearance (background color, text style, border radius)
/// - Supports an optional icon
/// - Can be positioned at different locations on the screen
/// - Can add a callback to be called when the notification is tapped
///
/// Example usage:
/// ```dart
/// CustomNotification.show(
///   context: context,
///   message: 'Hello, world!',
/// );
/// ```
///
/// or using the context extension:
/// ```dart
/// context.showCustomNotification(
///   message: 'Hello, world!',
/// );
/// ```
class CustomNotification extends StatefulWidget {
  /// Constructor for the [CustomNotification] widget.
  const CustomNotification({
    required this.message,
    required this.textStyle,
    required this.radius,
    super.key,
    this.isError = false,
    this.iconBackgroundColor,
    this.duration = const Duration(seconds: 3),
    this.leadingIcon,
    this.testMode = false,
    this.padding,
    this.onNotificationTap,
    this.top,
  });

  /// The top position of the notification.
  final double? top;

  /// The message to display in the notification.
  final String message;

  /// The text style of the notification.
  final TextStyle textStyle;

  /// The duration of the notification.
  final Duration duration;

  /// The radius of the notification.
  final BorderRadius radius;

  /// Whether the notification is an error notification.
  final bool isError;

  /// The icon background color of the notification.
  final Color? iconBackgroundColor;

  /// The icon to display in the notification.
  final Widget? leadingIcon;

  /// The padding of the notification.
  final EdgeInsets? padding;

  /// The callback to be called when the notification is tapped.
  final void Function()? onNotificationTap;

  /// Whether the notification is in test mode.
  final bool testMode;

  static OverlayEntry? _currentOverlay;

  /// Static method to show a notification.
  static OverlayEntry? show({
    required BuildContext context,
    required String message,
    Color? iconBackgroundColor,
    TextStyle? textStyle,
    Duration? duration,
    Widget? leadingIcon,
    BorderRadius? radius,
    bool? isError,
    EdgeInsets? padding,
    void Function()? onNotificationTap,
    bool testMode = false,
    double? top,
  }) {
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CustomNotification(
        message: message,
        iconBackgroundColor: iconBackgroundColor ?? const Color(0xff040A14).withValues(alpha: 0.12),
        textStyle: textStyle ?? context.x.textStyle.w500s12.copyWith(color: context.x.colors.white),
        duration: duration ?? const Duration(seconds: 3),
        leadingIcon: leadingIcon,
        radius: radius ?? const BorderRadius.all(Radius.circular(16)),
        isError: isError ?? false,
        padding: padding,
        testMode: testMode,
        onNotificationTap: onNotificationTap,
        top: top,
      ),
    );

    _currentOverlay = overlayEntry;
    overlayState.insert(overlayEntry);

    return overlayEntry;
  }

  /// Method to hide the current notification.
  static void hideCurrentNotification() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> with SingleTickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn, reverseCurve: Curves.easeOut));

    _animationController.forward();

    if (!widget.testMode) {
      Future<void>.delayed(widget.duration - const Duration(milliseconds: 150), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            CustomNotification._currentOverlay?.remove();
            CustomNotification._currentOverlay = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      Positioned(
        top: widget.top ?? MediaQuery.paddingOf(context).top,
        left: 20,
        right: 20,
        child: GestureDetector(
          onTap: widget.onNotificationTap ?? CustomNotification.hideCurrentNotification,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.isError ? const Color(0xFFD92D20) : const Color(0xFF14C732),
                        borderRadius: widget.radius,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: widget.isError
                                ? const Color(0xFFD92D20).withValues(alpha: 0.24)
                                : const Color(0xFF14C732).withValues(alpha: 0.24),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: widget.iconBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(6),
                              width: 36,
                              height: 36,
                              child: widget.isError
                                  ? widget.leadingIcon ?? Icon(CupertinoIcons.info, color: context.x.colors.white)
                                  : Icon(CupertinoIcons.checkmark_circle, color: context.x.colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: widget.textStyle,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                _animationController.reverse().then((_) {
                                  CustomNotification.hideCurrentNotification();
                                  CustomNotification._currentOverlay = null;
                                });
                              },
                              child: Icon(Icons.close, color: context.x.colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
