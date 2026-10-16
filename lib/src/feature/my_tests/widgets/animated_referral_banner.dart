import 'package:flutter/cupertino.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';

class AnimatedReferralBanner extends StatefulWidget {
  const AnimatedReferralBanner({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  State<AnimatedReferralBanner> createState() => _AnimatedReferralBannerState();
}

class _AnimatedReferralBannerState extends State<AnimatedReferralBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<Color> _gradientColors(BuildContext context) {
    final colors = context.x.colors;
    return [
      colors.referralBannerLime,
      colors.referralBannerGreen,
      colors.referralBannerMint,
      colors.referralBannerGreen,
      colors.referralBannerLime,
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _calculateStops(double animationValue) {
    const baseStops = [-0.5, -0.25, 0.0, 0.25, 0.5];
    return baseStops.map((stop) => (stop + animationValue * 1.5).clamp(0.0, 1.0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final handleTap = widget.onTap ?? () => context.octopus.push(Routes.referral);
    final isMobile = context.x.isMobile;
    return GestureDetector(
      onTap: handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final stops = _calculateStops(_controller.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors(context),
                stops: stops,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isMobile)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          const QuizLottieIcon(QuizLottie.fire, size: 36),
                          Expanded(
                            child: Text(
                              context.x.l10n.referralBannerTitle,
                              style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.x.l10n.referralBannerSubtitle,
                        style: context.x.textStyle.sfW500s14.copyWith(
                          color: context.x.colors.black.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              else ...[
                const QuizLottieIcon(QuizLottie.fire, size: 36),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.x.l10n.referralBannerTitle,
                        style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.x.l10n.referralBannerSubtitle,
                        style: context.x.textStyle.sfW500s14.copyWith(
                          color: context.x.colors.black.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              IconButton(
                onPressed: handleTap,
                icon: Icon(CupertinoIcons.chevron_right, color: context.x.colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
