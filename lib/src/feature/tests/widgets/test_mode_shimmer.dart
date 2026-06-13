import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import 'test_result_item_widget.dart';

class TestModeShimmer extends StatelessWidget {
  const TestModeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    Widget descriptionShimmer() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 22, radius: 4),
                  SizedBox(height: 6),
                  ShimmerBox(width: 180, height: 22, radius: 4),
                ],
              ),
            ),
            ShimmerBox(width: 40, height: 40, radius: 20),
            ShimmerBox(width: 40, height: 40, radius: 20),
            ShimmerBox(width: 40, height: 40, radius: 20),
          ],
        ),
        ShimmerBox(width: 220, height: 16, radius: 4),
        SizedBox(height: 4),
        ShimmerBox(width: 150, height: 16, radius: 4),
      ],
    );

    if (isMobile) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          shimmerWrapper(descriptionShimmer()),
          const SizedBox(height: 16),
          shimmerWrapper(const ShimmerBox(width: 150, height: 22, radius: 4)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: context.x.colors.cardBackground2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.x.colors.divider.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(12),
              child: shimmerWrapper(
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerBox(width: 44, height: 44, radius: 22),
                    SizedBox(height: 10),
                    ShimmerBox(width: 80, height: 14, radius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: double.infinity, height: 10, radius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Web Layout
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Column (Web info card)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.x.colors.cardBackground2,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.x.colors.primary.withValues(alpha: 0.1), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banner
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [context.x.colors.primary, context.x.colors.primary.withValues(alpha: 0.7)],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(23),
                                  topRight: Radius.circular(23),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: shimmerWrapper(
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ShimmerBox(width: 80, height: 11, radius: 4),
                                          SizedBox(height: 4),
                                          ShimmerBox(width: 60, height: 13, radius: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(padding: const EdgeInsets.all(20), child: shimmerWrapper(descriptionShimmer())),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Right Column (Mode selection cards)
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          shimmerWrapper(const ShimmerBox(width: 250, height: 24, radius: 4)),
                          const SizedBox(height: 20),
                          for (int i = 0; i < 4; i++) ...[
                            if (i > 0) const SizedBox(height: 14),
                            Container(
                              decoration: BoxDecoration(
                                color: context.x.colors.cardBackground2,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: context.x.colors.black.withValues(alpha: 0.06)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Row(
                                children: [
                                  shimmerWrapper(const ShimmerBox(width: 52, height: 52, radius: 26)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: shimmerWrapper(
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ShimmerBox(width: 120, height: 15, radius: 4),
                                          SizedBox(height: 6),
                                          ShimmerBox(width: double.infinity, height: 12, radius: 4),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  shimmerWrapper(const ShimmerBox(width: 16, height: 16, radius: 4)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class TestCustomModeShimmer extends StatelessWidget {
  const TestCustomModeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    Widget descriptionShimmer() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 22, radius: 4),
                  SizedBox(height: 6),
                  ShimmerBox(width: 180, height: 22, radius: 4),
                ],
              ),
            ),
            ShimmerBox(width: 40, height: 40, radius: 20),
            ShimmerBox(width: 40, height: 40, radius: 20),
            ShimmerBox(width: 40, height: 40, radius: 20),
          ],
        ),
        ShimmerBox(width: 220, height: 16, radius: 4),
        SizedBox(height: 4),
        ShimmerBox(width: 150, height: 16, radius: 4),
      ],
    );

    Widget setupConfigShimmer({required bool showButton}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        shimmerWrapper(const ShimmerBox(width: 280, height: 24, radius: 4)),
        const SizedBox(height: 24),
        shimmerWrapper(const ShimmerBox(width: 200, height: 14, radius: 4)),
        const SizedBox(height: 8),
        shimmerWrapper(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(6, (index) => const ShimmerBox(width: 60, height: 36, radius: 8)),
          ),
        ),
        const SizedBox(height: 24),
        shimmerWrapper(const ShimmerBox(width: 240, height: 14, radius: 4)),
        const SizedBox(height: 8),
        shimmerWrapper(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(4, (index) => const ShimmerBox(width: 90, height: 36, radius: 8)),
          ),
        ),
        const SizedBox(height: 24),
        shimmerWrapper(const ShimmerBox(width: 160, height: 14, radius: 4)),
        const SizedBox(height: 8),
        shimmerWrapper(
          Row(
            spacing: 12,
            children: [
              const ShimmerBox(width: 20, height: 16, radius: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const ShimmerBox(width: 30, height: 16, radius: 4),
            ],
          ),
        ),
        if (showButton) ...[
          const SizedBox(height: 36),
          shimmerWrapper(const ShimmerBox(width: double.infinity, height: 48, radius: 12)),
        ],
      ],
    );

    if (isMobile) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          shimmerWrapper(descriptionShimmer()),
          const SizedBox(height: 24),
          setupConfigShimmer(showButton: false),
          const SizedBox(height: 24),
          shimmerWrapper(const ShimmerBox(width: 150, height: 20, radius: 4)),
          const SizedBox(height: 12),
          const HistoryAttemptShimmer(),
          const SizedBox(height: 8),
          const HistoryAttemptShimmer(),
        ],
      );
    } else {
      // Web Layout
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Column (Web info card)
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.x.colors.cardBackground2,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: context.x.colors.primary.withValues(alpha: 0.1), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Banner
                                Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        context.x.colors.primary,
                                        context.x.colors.primary.withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: shimmerWrapper(
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ShimmerBox(width: 80, height: 11, radius: 4),
                                              SizedBox(height: 4),
                                              ShimmerBox(width: 60, height: 13, radius: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.all(20), child: shimmerWrapper(descriptionShimmer())),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        // Right Column (Config card)
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.x.colors.cardBackground2,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: context.x.colors.black.withValues(alpha: 0.06)),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: setupConfigShimmer(showButton: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  shimmerWrapper(const ShimmerBox(width: 150, height: 20, radius: 4)),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, attemptConstraints) {
                      final cardWidth = attemptConstraints.maxWidth >= 800
                          ? (attemptConstraints.maxWidth - 28) / 2
                          : attemptConstraints.maxWidth;
                      return Wrap(
                        spacing: 28,
                        runSpacing: 16,
                        children: [
                          SizedBox(width: cardWidth, child: const HistoryAttemptShimmer()),
                          SizedBox(width: cardWidth, child: const HistoryAttemptShimmer()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class HistoryAttemptShimmer extends StatelessWidget {
  const HistoryAttemptShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: context.x.colors.textFieldBackground),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            spacing: 4,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ShimmerBox(width: 50, height: 16, radius: 4), ShimmerBox(width: 80, height: 16, radius: 4)],
              ),
              SizedBox(height: 8),
              _ShimmerInfoRow(labelWidth: 80),
              _ShimmerInfoRow(labelWidth: 70),
              _ShimmerInfoRow(labelWidth: 90),
              _ShimmerInfoRow(labelWidth: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerInfoRow extends StatelessWidget {
  const _ShimmerInfoRow({required this.labelWidth});
  final double labelWidth;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const ShimmerBox(width: 14, height: 14, radius: 7),
        const SizedBox(width: 8),
        ShimmerBox(width: labelWidth, height: 12, radius: 4),
        Expanded(child: DottedDivider(color: context.x.colors.gray.withValues(alpha: 0.15))),
        const ShimmerBox(width: 30, height: 12, radius: 4),
      ],
    ),
  );
}

class TestSolvingShimmer extends StatelessWidget {
  const TestSolvingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    Widget shimmerWrapper(Widget child) =>
        Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: child);

    Widget questionContentShimmer() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Finish Button row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            shimmerWrapper(const ShimmerBox(width: 150, height: 22, radius: 4)),
            shimmerWrapper(const ShimmerBox(width: 80, height: 32, radius: 20)),
          ],
        ),
        const SizedBox(height: 16),
        // Question number row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            shimmerWrapper(const ShimmerBox(width: 60, height: 14, radius: 4)),
            shimmerWrapper(const ShimmerBox(width: 40, height: 14, radius: 4)),
          ],
        ),
        const SizedBox(height: 24),
        // Question image placeholder
        shimmerWrapper(ShimmerBox(width: double.infinity, height: isMobile ? 200 : 320, radius: 12)),
        const SizedBox(height: 16),
        // Question text lines
        shimmerWrapper(const ShimmerBox(width: double.infinity, height: 18, radius: 4)),
        const SizedBox(height: 8),
        shimmerWrapper(const ShimmerBox(width: 240, height: 18, radius: 4)),
        const SizedBox(height: 24),
        // 4 options shimmers
        Column(
          spacing: 12,
          children: List.generate(
            4,
            (index) => shimmerWrapper(const ShimmerBox(width: double.infinity, height: 60, radius: 12)),
          ),
        ),
      ],
    );

    if (isMobile) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [questionContentShimmer()],
      );
    } else {
      // Web layout card wrapper
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: context.x.colors.cardBackground2,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0x0F000000)
                        : const Color(0x1FFFFFFF),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: questionContentShimmer(),
              ),
            ),
          ),
        ),
      );
    }
  }
}
