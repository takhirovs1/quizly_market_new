import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/context_extension.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuizAppBar({
    this.title = '',
    this.subtitle,
    this.bottom,
    this.showBackButton,
    this.onBackPressed,
    super.key,
    this.telegramWebAppSafeAreaInsetTop,
  });

  /// A static configuration callback to check if Telegram is supported/active.
  /// This allows decoupling the Telegram service from the UI package.
  static bool Function(BuildContext)? isTelegramSupported;

  final String title;
  final Widget? subtitle;
  final double? telegramWebAppSafeAreaInsetTop;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final hasTelegram = isTelegramSupported?.call(context) ?? false;
    final shouldShowBackButton = showBackButton ?? (canPop && !hasTelegram);

    return AppBar(
      backgroundColor: context.x.colors.appBarBackground,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: (telegramWebAppSafeAreaInsetTop ?? kToolbarHeight) + 56,
      surfaceTintColor: context.x.colors.transparent,
      centerTitle: true,
      leadingWidth: 56,
      leading: shouldShowBackButton
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: telegramWebAppSafeAreaInsetTop?.toDouble() ?? 0),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (onBackPressed != null) {
                      onBackPressed!();
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.x.colors.white, size: 20),
                ),
              ],
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: telegramWebAppSafeAreaInsetTop?.toDouble() ?? 0),
          Text(
            title,
            style: context.x.textStyle.nunitoW600s24.copyWith(
              color: context.x.colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) subtitle as Widget,
        ],
      ),
      bottom:
          bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: context.x.colors.divider),
          ),
    );
  }

  @override
  Size get preferredSize => _PreferredAppBarSize(
    (telegramWebAppSafeAreaInsetTop ?? kToolbarHeight) + 56,
    bottom?.preferredSize.height ?? 1.0,
  );
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
    : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

class AppBarTypingIndicator extends StatelessWidget {
  const AppBarTypingIndicator({required this.text, this.color = Colors.white, super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text, style: TextStyle(color: color, fontSize: 11)),
      const SizedBox(width: 3),
      AppBarBouncingDots(color: color),
    ],
  );
}

class AppBarBouncingDots extends StatefulWidget {
  const AppBarBouncingDots({required this.color, super.key});
  final Color color;

  @override
  State<AppBarBouncingDots> createState() => _AppBarBouncingDotsState();
}

class _AppBarBouncingDotsState extends State<AppBarBouncingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final double value = (sin((_controller.value * 2 * pi) - (delay * 2 * pi)) + 1) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              width: 3.0,
              height: 3.0,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.3 + 0.7 * value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
