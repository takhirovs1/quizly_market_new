import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../extension/context_extension.dart';

class TestCardShimmer extends StatelessWidget {
  const TestCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.x.colors.bannerBackground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 2, child: ShimmerBox(height: 20, radius: 4)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Align(alignment: Alignment.centerRight, child: ShimmerBox(width: 72, height: 20, radius: 4)),
                  ),
                ],
              ),
              SizedBox(height: 6),
              SizedBox(height: 4),
              ShimmerBox(width: 200, height: 14, radius: 4),
              SizedBox(height: 4),
              ShimmerBox(width: 200, height: 14, radius: 4),
              SizedBox(height: 6),
              Row(
                children: [
                  ShimmerBox(width: 16, height: 16, radius: 4),
                  SizedBox(width: 4),
                  ShimmerBox(width: 90, height: 14, radius: 4),
                ],
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ShimmerBox(width: 16, height: 16, radius: 4),
                    SizedBox(width: 4),
                    ShimmerBox(width: 80, height: 15, radius: 4),
                    Spacer(),
                    ShimmerBox(width: 24, height: 24, radius: 12),
                    SizedBox(width: 8),
                    ShimmerBox(width: 110, height: 36, radius: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({required this.height, this.width, this.radius = 4});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(radius))),
    child: SizedBox(width: width, height: height),
  );
}
