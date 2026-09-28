import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extension/context_extension.dart';
import 'test_card_shimmer.dart';

/// Placeholder shown while the questions carousel content is loading, so the
/// real carousel fades in instead of popping in abruptly.
///
/// Dimensions mirror `QuestionsCarousel` / `QuestionCardWidget` so the layout
/// does not jump when the real content arrives:
/// - the card sits in the same `vertical: 8, horizontal: 4` padding as the
///   PageView + card,
/// - each option bar is 48px tall with an 8px gap (the real `_OptionRow` is
///   12+24+12 padding = 48px, plus an 8px bottom margin),
/// - followed by an 8px gap and a page-indicator pill.
class QuestionsCarouselShimmer extends StatelessWidget {
  const QuestionsCarouselShimmer({this.optionCount = 4, super.key});

  /// Number of option bars to render (real questions usually have 4).
  final int optionCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);
    final colors = context.x.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Matches the PageView's vertical padding + the card's horizontal padding.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.cardBackground2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question text (~2 lines) + the 12px gap before the options.
                    const ShimmerBox(height: 16, radius: 4),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 220, height: 16, radius: 4),
                    const SizedBox(height: 12),
                    // Option bars — same 48px height + 8px gap as the real rows.
                    for (var i = 0; i < optionCount; i++)
                      const Padding(padding: EdgeInsets.only(bottom: 8), child: ShimmerBox(height: 48, radius: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Page-indicator pill placeholder (mirrors PageIndicator).
        DecoratedBox(
          decoration: BoxDecoration(color: colors.indicatorBackground, borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [_IndicatorDot(), _IndicatorDot(), _IndicatorDot(), _IndicatorDot(), _IndicatorDot()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single dot cell matching `PageIndicator`'s 8px dot with 4px/6px padding.
class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: ShimmerBox(width: 8, height: 8, radius: 4),
  );
}
