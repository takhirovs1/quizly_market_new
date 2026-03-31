import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    required this.children,
    this.initialChildSize = .5,
    super.key,
    this.maxChildSize = .9,
    this.isScrollable = true,
    this.bottomNavigationBar,
    this.title,
  });

  final List<Widget> children;
  final double initialChildSize;
  final double maxChildSize;
  final bool isScrollable;
  final Widget? bottomNavigationBar;
  final Widget? title;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: initialChildSize,
    minChildSize: initialChildSize,
    maxChildSize: maxChildSize,
    builder: (ctx, scrollController) => Column(
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: context.x.colors.gray, borderRadius: BorderRadius.circular(100)),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.x.colors.dialogBackground,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(padding: const EdgeInsets.only(left: 16, top: 20, bottom: 16), child: title!),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    controller: scrollController,
                    physics: isScrollable ? null : const NeverScrollableScrollPhysics(),
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  );
}
