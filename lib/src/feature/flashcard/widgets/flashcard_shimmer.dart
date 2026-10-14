import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

/// Loading-state skeleton for the flashcard study screen. Mirrors the real
/// layout: a top progress bar, the center card (with peeking ghost cards) and
/// the two footer answer buttons — so the transition into the loaded deck has
/// no layout jump.
class FlashcardShimmer extends StatelessWidget {
  const FlashcardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          children: [
            // Progress bar: undo button · track · counter (matches FlashcardProgressBar).
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: shimmerWrapper(
                const Row(
                  children: [
                    ShimmerBox(width: 36, height: 36, radius: 18),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerBox(width: double.infinity, height: 8, radius: 4)),
                    SizedBox(width: 12),
                    ShimmerBox(width: 48, height: 16, radius: 4),
                  ],
                ),
              ),
            ),

            // Card area: ghost cards peeking behind the (shimmering) top card.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final cardW = (c.maxWidth - 32).clamp(0.0, 420.0);
                    final cardH = (c.maxHeight - 44).clamp(0.0, 520.0);
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          _GhostCard(width: cardW - 44, height: cardH, translateY: 22),
                          _GhostCard(width: cardW - 22, height: cardH, translateY: 11),
                          shimmerWrapper(ShimmerBox(width: cardW, height: cardH, radius: 24)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Footer: swipe hints + the two answer buttons (matches FlashcardFooter).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  shimmerWrapper(
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerBox(width: 120, height: 13, radius: 4),
                          ShimmerBox(width: 120, height: 13, radius: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  shimmerWrapper(
                    const Row(
                      children: [
                        Expanded(child: ShimmerBox(width: double.infinity, height: 64, radius: 999)),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerBox(width: double.infinity, height: 64, radius: 999)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A static blank "next card" behind the top card — mirrors [FlashcardGhostCard]
/// but without importing it (no swipe/shadow coupling needed for the skeleton).
class _GhostCard extends StatelessWidget {
  const _GhostCard({required this.width, required this.height, required this.translateY});

  final double width;
  final double height;
  final double translateY;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Transform.translate(
      offset: Offset(0, translateY),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.cardBackground2,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
