import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class AnimatedReferralBanner extends StatefulWidget {
  const AnimatedReferralBanner({super.key});

  @override
  State<AnimatedReferralBanner> createState() => _AnimatedReferralBannerState();
}

class _AnimatedReferralBannerState extends State<AnimatedReferralBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _gradientColors = [
    Color(0xffD4FF00),
    Color(0xff8FFF3A),
    Color(0xff1BFF72),
    Color(0xff8FFF3A),
    Color(0xffD4FF00),
  ];

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
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final stops = _calculateStops(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _gradientColors,
              stops: stops,
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: const .all(.circular(16)),
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 4,
          mainAxisAlignment: .spaceBetween,
          children: [
            Lottie.asset(Assets.lib.lottie.fireEmoji, width: 36, height: 36, package: 'ui'),
            Expanded(
              child: Column(
                // spacing: 2,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    context.x.l10n.inviteFriendGetBonus,
                    style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.black),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                  RichText(
                    text: TextSpan(
                      style: context.x.textStyle.sfW500s16.copyWith(
                        color: context.x.colors.bannerSecondaryText,
                        fontStyle: .normal,
                        overflow: .ellipsis,
                      ),
                      children: [
                        TextSpan(text: '${context.x.l10n.forEachFriend} '),
                        TextSpan(
                          text: ' 1 000 ',
                          style: context.x.textStyle.sfW500s16.copyWith(
                            color: context.x.colors.primary,
                            fontWeight: .w700,
                          ),
                        ),
                        TextSpan(
                          text: ' ${context.x.l10n.uzs}',
                          style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.chevron_right, color: context.x.colors.black),
            ),
          ],
        ),
      ),
    ),
  );
}
