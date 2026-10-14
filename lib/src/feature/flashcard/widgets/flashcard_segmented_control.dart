import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Two-option segmented switcher styled like the app's tab bar
/// (see `upload_screen.dart`). The white pill indicator **slides** smoothly
/// between segments (AnimatedAlign), and the labels cross-fade their
/// weight/color — matching the feel of a native TabBar.
class FlashcardSegmentedControl extends StatelessWidget {
  const FlashcardSegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final count = options.length;
    final selected = selectedIndex.clamp(0, count - 1);
    // Map the selected index to an X alignment in [-1, 1].
    final alignX = count <= 1 ? 0.0 : (selected / (count - 1)) * 2 - 1;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bannerBackground, borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: 45,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Sliding white indicator.
              AnimatedAlign(
                duration: _duration,
                curve: _curve,
                alignment: Alignment(alignX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / count,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Labels on top.
              Row(
                children: [
                  for (int i = 0; i < count; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i == selected) return;
                          context.telegramWebApp.hapticImpact(.light);
                          onChanged(i);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: _duration,
                            curve: _curve,
                            style: i == selected
                                ? textStyle.sfW600s16.copyWith(color: colors.black)
                                : textStyle.sfW400s16.copyWith(color: colors.bannerSecondaryText),
                            child: Text(
                              options[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
