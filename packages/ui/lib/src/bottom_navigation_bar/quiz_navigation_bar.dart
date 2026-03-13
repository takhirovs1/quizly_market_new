import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../gen/assets.gen.dart';

class QuizNavigationBar extends StatefulWidget {
  const QuizNavigationBar({required this.currentIndex, required this.onTap, super.key});

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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      boxShadow: [BoxShadow(color: context.x.colors.gray.withValues(alpha: .1), blurRadius: 10, offset: Offset.zero)],
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: NavigationBar(
        overlayColor: WidgetStateColor.transparent,
        indicatorColor: Colors.transparent,
        shadowColor: context.x.colors.gray,
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        backgroundColor: context.x.colors.dialogBackground,
        destinations: [
          for (final i in [
            Assets.lib.vectors.home,
            Assets.lib.vectors.cart,
            Assets.lib.vectors.upload,
            Assets.lib.vectors.profile,
          ])
            NavigationDestination(
              icon: SizedBox(
                width: 24,
                child: i.svg(
                  width: 24,
                  height: 24,
                  package: 'ui',
                  colorFilter: ColorFilter.mode(context.x.colors.bottomNavigationBarUnselectedColor, BlendMode.srcIn),
                ),
              ),
              selectedIcon: SizedBox(
                width: 24,
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: i.svg(
                          width: 24,
                          height: 24,
                          package: 'ui',
                          colorFilter: ColorFilter.mode(context.x.colors.text, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: SizedBox(
                        width: 24,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: bottomNavigationAnimated ? 10 : 0,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.x.colors.text,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              label: '',
            ),
        ],
      ),
    ),
  );
}
