import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class PurchaseTestShimmer extends StatelessWidget {
  const PurchaseTestShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const .symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        // Title & Actions Shimmer
        shimmerWrapper(
          const Row(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    ShimmerBox(width: .infinity, height: 22, radius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 180, height: 22, radius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 40, height: 40, radius: 20),
              ShimmerBox(width: 40, height: 40, radius: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle & Description Shimmer
        shimmerWrapper(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 220, height: 16, radius: 4),
              SizedBox(height: 8),
              ShimmerBox(width: double.infinity, height: 12, radius: 4),
              SizedBox(height: 6),
              ShimmerBox(width: 280, height: 12, radius: 4),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Question Card Shimmer (Solid background, shimmering placeholders inside)
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.x.colors.cardBackground2,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: context.x.colors.black.withValues(alpha: .08),
                offset: const Offset(0, 12),
                blurRadius: 56,
              ),
              BoxShadow(color: context.x.colors.black.withValues(alpha: .05), offset: Offset.zero, blurRadius: 3),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Text Shimmer
                shimmerWrapper(
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: double.infinity, height: 16, radius: 4),
                      SizedBox(height: 6),
                      ShimmerBox(width: 150, height: 16, radius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Option 1
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: shimmerWrapper(const ShimmerBox(width: 120, height: 14, radius: 4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Option 2
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: shimmerWrapper(const ShimmerBox(width: 100, height: 14, radius: 4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Option 3
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: shimmerWrapper(const ShimmerBox(width: 130, height: 14, radius: 4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Option 4
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.x.colors.bannerSecondaryText.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: shimmerWrapper(const ShimmerBox(width: 90, height: 14, radius: 4)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // // Page Indicator Shimmer
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     DecoratedBox(
        //       decoration: BoxDecoration(
        //         color: context.x.colors.indicatorBackground,
        //         borderRadius: BorderRadius.circular(16),
        //       ),
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        //         child: Row(
        //           spacing: 6,
        //           mainAxisSize: MainAxisSize.min,
        //           children: List.generate(
        //             5,
        //             (index) => SizedBox(
        //               width: 8,
        //               height: 8,
        //               child: DecoratedBox(
        //                 decoration: BoxDecoration(
        //                   color: index == 0 ? context.x.colors.white : context.x.colors.white.withValues(alpha: .25),
        //                   shape: BoxShape.circle,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 20),
        // Payment Type Section Title
        shimmerWrapper(const ShimmerBox(width: 50, height: 24, radius: 4)),
        const SizedBox(height: 20),
        // Payment Card Shimmer
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.x.colors.cardBackground2,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.x.colors.black.withValues(alpha: .04),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                shimmerWrapper(const ShimmerBox(width: 40, height: 40, radius: 10)),
                const SizedBox(width: 12),
                Expanded(
                  child: shimmerWrapper(
                    const Column(
                      crossAxisAlignment: .start,
                      children: [
                        ShimmerBox(width: 120, height: 16, radius: 4),
                        SizedBox(height: 6),
                        ShimmerBox(width: 80, height: 12, radius: 4),
                      ],
                    ),
                  ),
                ),
                shimmerWrapper(const ShimmerBox(width: 24, height: 24, radius: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
