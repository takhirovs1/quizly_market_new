import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QuizAppBar({this.title = '', this.bottom, super.key, this.telegramWebAppSafeAreaInsetTop});

  final String title;
  final double? telegramWebAppSafeAreaInsetTop;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: context.x.colors.appBarBackground,
    automaticallyImplyLeading: false,
    scrolledUnderElevation: 0,
    elevation: 0,
    toolbarHeight: (telegramWebAppSafeAreaInsetTop ?? kToolbarHeight) + 56,
    surfaceTintColor: context.x.colors.transparent,

    title: Column(
      children: [
        SizedBox(height: telegramWebAppSafeAreaInsetTop?.toDouble() ?? 0),
        Center(
          child: Text(
            title,
            style: context.x.textStyle.w400s24.copyWith(color: context.x.colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
    bottom: bottom,
  );

  @override
  Size get preferredSize =>
      _PreferredAppBarSize((telegramWebAppSafeAreaInsetTop ?? kToolbarHeight) + 56, bottom?.preferredSize.height);
}

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
    : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}
