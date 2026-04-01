import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../gen/assets.gen.dart';

class QuizNavigationBar extends StatefulWidget {
  const QuizNavigationBar({required this.labels, required this.currentIndex, required this.onTap, super.key});

  final List<String> labels;
  final int currentIndex;
  final void Function(int) onTap;

  @override
  State<QuizNavigationBar> createState() => _QuizNavigationBarState();
}

class _QuizNavigationBarState extends State<QuizNavigationBar> {
  bool bottomNavigationAnimated = true;
  int selectedIndex = 0;

  Future<void> onItemTapped(int index) async {
    bottomNavigationAnimated = false;
    setState(() {});
    selectedIndex = index;
    widget.onTap(index);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    bottomNavigationAnimated = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Assets.lib.vectors.home2,
      Assets.lib.vectors.market,
      Assets.lib.vectors.upload2,
      Assets.lib.vectors.person,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.x.colors.dialogBackground,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onItemTapped,
          backgroundColor: context.x.colors.dialogBackground,
          indicatorColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.bottomNavigationBarSelectedColor);
            }
            return context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.bottomNavigationBarUnselectedColor);
          }),
          destinations: List.generate(
            icons.length,
            (i) => NavigationDestination(
              label: widget.labels[i],
              icon: icons[i].svg(
                width: 24,
                height: 24,
                package: 'ui',
                colorFilter: ColorFilter.mode(context.x.colors.bottomNavigationBarUnselectedColor, BlendMode.srcIn),
              ),
              selectedIcon: icons[i].svg(
                width: 24,
                height: 24,
                package: 'ui',
                colorFilter: ColorFilter.mode(context.x.colors.bottomNavigationBarSelectedColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
