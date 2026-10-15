import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extension/context_extension.dart';

/// Theme-aware shimmer wrapper for skeleton loaders. Pair with [ShimmerBox].
class QuizShimmer extends StatelessWidget {
  const QuizShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.x.colors.shimmerBase,
      highlightColor: context.x.colors.shimmerHighlight,
      child: child,
    );
  }
}
