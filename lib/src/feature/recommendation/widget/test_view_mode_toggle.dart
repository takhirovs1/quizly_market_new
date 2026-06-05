import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

enum TestViewMode { grid, list }

class TestViewModeToggle extends StatelessWidget {
  const TestViewModeToggle({
    required this.notifier,
    super.key,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
  });

  final ValueNotifier<TestViewMode> notifier;
  final Duration duration;
  final Curve curve;

  void _select(BuildContext context, TestViewMode mode) {
    if (notifier.value == mode) return;
    context.telegramWebApp.hapticImpact(.light);
    notifier.value = mode;
  }

  static const double width = 96;
  static const double height = 56;
  static const double padding = 8;
  static const double outerRadius = 8;
  static const double innerRadius = 8;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<TestViewMode>(
    valueListenable: notifier,
    builder: (context, value, _) {
      final selectedIndex = value == .grid ? 0 : 1;
      final inactiveColor = context.x.colors.gray;
      final activeIconColor = context.x.colors.white;

      return SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: const .all(padding),
          child: DecoratedBox(
            decoration: BoxDecoration(color: context.x.colors.white, borderRadius: .circular(outerRadius)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final innerW = constraints.maxWidth;
                const innerH = height - padding * 2;
                final segW = innerW / 2;

                return Stack(
                  clipBehavior: .none,
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: curve,
                      left: selectedIndex * segW,
                      top: 0,
                      width: segW,
                      height: innerH,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.x.colors.primary,
                          borderRadius: .circular(innerRadius),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: context.x.colors.transparent,
                            child: InkWell(
                              onTap: () => _select(context, .grid),
                              borderRadius: .circular(innerRadius),
                              splashColor: context.x.colors.primary.withValues(alpha: 0.12),
                              highlightColor: context.x.colors.primary.withValues(alpha: 0.06),
                              child: SizedBox(
                                height: innerH,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.square_grid_2x2,
                                    color: selectedIndex == 0 ? activeIconColor : inactiveColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: context.x.colors.transparent,
                            child: InkWell(
                              onTap: () => _select(context, .list),
                              borderRadius: .circular(innerRadius),
                              splashColor: context.x.colors.primary.withValues(alpha: 0.12),
                              highlightColor: context.x.colors.primary.withValues(alpha: 0.06),
                              child: SizedBox(
                                height: innerH,
                                child: Center(
                                  child: Assets.lib.vectors.iconSlider.svg(
                                    width: 28,
                                    height: 28,
                                    package: 'ui',
                                    colorFilter: .mode(selectedIndex == 1 ? activeIconColor : inactiveColor, .srcIn),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
