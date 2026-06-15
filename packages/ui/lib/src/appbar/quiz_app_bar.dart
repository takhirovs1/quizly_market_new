import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/context_extension.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuizAppBar({
    this.title = '',
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
        children: [
          SizedBox(height: telegramWebAppSafeAreaInsetTop?.toDouble() ?? 0),
          Text(
            title,
            style: context.x.textStyle.nunitoW600s24.copyWith(
              color: context.x.colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
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
