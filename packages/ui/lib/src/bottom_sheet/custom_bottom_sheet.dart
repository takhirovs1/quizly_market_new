import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    required this.children,
    super.key,
    this.maxHeightFactor = .9,
    this.isScrollable = true,
    this.bottomNavigationBar,
    this.title,
  });

  final List<Widget> children;
  final double maxHeightFactor;
  final bool isScrollable;
  final Widget? bottomNavigationBar;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: context.x.colors.bottomSheetSurface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 60,
                height: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: context.x.colors.gray, borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ),
          ),
          if (title != null)
            Column(
              children: [
                Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4), child: title!),
                Divider(color: context.x.colors.divider),
              ],
            ),
          Flexible(
            child: isScrollable
                ? ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), children: children)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(mainAxisSize: MainAxisSize.min, children: children),
                  ),
          ),
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: content),
            if (bottomNavigationBar != null)
              ColoredBox(
                color: context.x.colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(padding: const EdgeInsets.all(16), child: bottomNavigationBar!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
