import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';

/// Figma "Skeleton" component (Hero / Actions / TestCard / Card / ProductRow)
/// and the full loading state (A4). Reuses [QuizShimmer] + [ShimmerBox].
Widget _shimmer(BuildContext context, Widget child) => QuizShimmer(child: child);

BoxDecoration _cardSkeletonDecoration(BuildContext context) =>
    BoxDecoration(color: context.x.homeColors.surface, borderRadius: BorderRadius.circular(20));

class HomeHeroSkeleton extends StatelessWidget {
  const HomeHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _shimmer(
    context,
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: context.x.colors.homeHeroSkeleton, borderRadius: BorderRadius.circular(24)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 24, radius: 100),
          SizedBox(height: 14),
          ShimmerBox(width: 220, height: 24, radius: 8),
          SizedBox(height: 10),
          ShimmerBox(width: 140, height: 14, radius: 8),
          SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 8, radius: 4),
          SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 50, radius: 14),
        ],
      ),
    ),
  );
}

class HomeActionsSkeleton extends StatelessWidget {
  const HomeActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: _cardSkeletonDecoration(context),
            child: _shimmer(
              context,
              const Column(
                children: [
                  ShimmerBox(width: 52, height: 52, radius: 100),
                  SizedBox(height: 8),
                  ShimmerBox(width: 70, height: 12, radius: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

class HomeTestCardSkeleton extends StatelessWidget {
  const HomeTestCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardSkeletonDecoration(context),
    child: _shimmer(
      context,
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 52, height: 52, radius: 100),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 180, height: 16, radius: 8),
                    SizedBox(height: 6),
                    ShimmerBox(width: 110, height: 12, radius: 8),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              ShimmerBox(width: 90, height: 22, radius: 100),
              SizedBox(width: 6),
              ShimmerBox(width: 80, height: 22, radius: 100),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 6, radius: 3)),
              SizedBox(width: 14),
              ShimmerBox(width: 110, height: 38, radius: 12),
            ],
          ),
        ],
      ),
    ),
  );
}

class HomeCardSkeleton extends StatelessWidget {
  const HomeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardSkeletonDecoration(context),
    child: _shimmer(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 150, height: 18, radius: 8),
          const SizedBox(height: 12),
          const ShimmerBox(width: 80, height: 12, radius: 8),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in const [20.0, 36.0, 16.0, 30.0, 14.0, 26.0, 60.0]) ...[
                  Expanded(
                    child: ShimmerBox(width: double.infinity, height: h, radius: 8),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeProductRowSkeleton extends StatelessWidget {
  const HomeProductRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 220,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 2,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, _) => SizedBox(
        width: 196,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: _cardSkeletonDecoration(context),
          child: _shimmer(
            context,
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 96, radius: 0),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 90, height: 10, radius: 8),
                      SizedBox(height: 8),
                      ShimmerBox(width: 160, height: 14, radius: 8),
                      SizedBox(height: 8),
                      ShimmerBox(width: 60, height: 10, radius: 8),
                      SizedBox(height: 8),
                      ShimmerBox(width: 100, height: 18, radius: 8),
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

/// Full-screen loading state (Figma A4).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    children: const [
      HomeHeroSkeleton(),
      SizedBox(height: 20),
      HomeActionsSkeleton(),
      SizedBox(height: 24),
      HomeTestCardSkeleton(),
      SizedBox(height: 16),
      HomeCardSkeleton(),
      SizedBox(height: 24),
      HomeProductRowSkeleton(),
    ],
  );
}
