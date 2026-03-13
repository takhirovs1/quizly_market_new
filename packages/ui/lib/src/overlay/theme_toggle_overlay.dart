import 'package:flutter/foundation.dart' show kDebugMode;

import '../../ui.dart';

/// The duration of the animation
const _$animationDuration = Duration(milliseconds: 300);

/// {@template theme_toggle_overlay}
/// A persistent overlay widget that allows users to toggle between light and dark themes.
/// This overlay stays at the top of the screen across all app screens and can be dragged around.
/// {@endtemplate}
class ThemeToggleOverlay extends StatefulWidget {
  /// {@macro theme_toggle_overlay}
  const ThemeToggleOverlay({required this.setThemeMode, super.key});

  /// The function to set the theme mode
  final void Function(bool isDarkMode) setThemeMode;

  /// The current overlay entry
  static OverlayEntry? _currentOverlay;

  /// Show the theme toggle overlay
  static void show(
    BuildContext context, {

    /// The function to set the theme mode
    required void Function(bool isDarkMode) setThemeMode,
  }) {
    if (!kDebugMode) return;

    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(builder: (context) => ThemeToggleOverlay(setThemeMode: setThemeMode));

    _currentOverlay = overlayEntry;
    overlayState.insert(overlayEntry);
  }

  /// Hide the theme toggle overlay
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  @override
  State<ThemeToggleOverlay> createState() => _ThemeToggleOverlayState();
}

/// State for [ThemeToggleOverlay]
abstract class ThemeToggleOverlayState extends State<ThemeToggleOverlay> with TickerProviderStateMixin {
  /// The x position of the widget
  double _xPosition = 0;

  /// The y position of the widget
  double _yPosition = 0;

  /// Whether the widget is being dragged
  bool _isDragging = false;

  /// Whether the widget is in dark mode
  bool _isDarkMode = false;

  /// The width of the widget
  static const double _widgetWidth = 45;

  /// The height of the widget
  static const double _widgetHeight = 40;

  /// Toggle the theme
  void _toggleTheme({required void Function(bool isDarkMode) setThemeMode}) {
    if (_isDragging) return;

    HapticsService.selectionClick();

    final isDarkMode = Theme.brightnessOf(context) == Brightness.dark;

    _isDarkMode = !isDarkMode;
    setThemeMode(!isDarkMode);
  }

  /// Handle the drag start event
  void _onDragStart(DragStartDetails _) {
    setState(() => _isDragging = true);
    HapticsService.selectionClick();
  }

  /// Handle the drag update event
  void _onDragUpdate(DragUpdateDetails details) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    setState(() {
      _xPosition = (_xPosition + details.delta.dx).clamp(0, size.width - _widgetWidth);
      _yPosition = (_yPosition + details.delta.dy).clamp(padding.top, size.height - _widgetHeight - padding.bottom);
    });
  }

  /// Handle the drag end event
  void _onDragEnd(DragEndDetails _) {
    setState(() => _isDragging = false);
    _snapToNearestEdge();
  }

  /// Snap the widget to the nearest edge
  void _snapToNearestEdge() {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final centerX = size.width / 2;

    // Snap to left or right edge based on current position
    final targetX = _xPosition < centerX ? 16.0 : size.width - _widgetWidth - 16;

    // Ensure Y position is within bounds
    final targetY = _yPosition.clamp(padding.top + 10, size.height - _widgetHeight - padding.bottom - 10);

    // Animate to target position
    final currentX = _xPosition;
    final currentY = _yPosition;

    final animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    final xAnimation = Tween<double>(
      begin: currentX,
      end: targetX,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    final yAnimation = Tween<double>(
      begin: currentY,
      end: targetY,
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    animationController.addListener(() {
      _xPosition = xAnimation.value;
      _yPosition = yAnimation.value;
      setState(() {});
    });

    animationController.forward().then((_) => animationController.dispose());
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize the isDarkMode
      _isDarkMode = Theme.brightnessOf(context) == Brightness.dark;

      // Initialize the position of the widget
      final padding = MediaQuery.paddingOf(context);

      setState(() {
        _xPosition = MediaQuery.sizeOf(context).width - _widgetWidth - 16;
        _yPosition = padding.top + 10;
      });
    });
  }

  @override
  void dispose() {
    // implement dispose
    super.dispose();
  }

  /* #endregion */
}

/// Implementation of [ThemeToggleOverlayState]
class _ThemeToggleOverlayState extends ThemeToggleOverlayState {
  @override
  Widget build(BuildContext context) => Positioned(
    left: _xPosition,
    top: _yPosition,
    child: GestureDetector(
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      onTap: () => _toggleTheme(setThemeMode: widget.setThemeMode),
      child: AnimatedScale(
        scale: _isDragging ? 1.15 : 1.0,
        duration: _$animationDuration,
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).appColors.onSecondary.withAlpha(70),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AnimatedSwitcher(
                duration: _$animationDuration,
                child: Icon(
                  _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(Theme.brightnessOf(context).index),
                  color: Theme.of(context).appColors.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
