import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../gen/assets.gen.dart';

class MiniTestCardWidget extends StatelessWidget {
  const MiniTestCardWidget({
    required this.title,
    required this.companyName,
    required this.description,
    required this.price,
    required this.questionAmount,
    required this.buyButtonText,
    required this.onBuyButtonPressed,
    this.onShareButtonPressed,
    this.onLikeButtonPressed,
    this.isPurchased = false,
    this.isLiked = false,
    super.key,
  });

  final String title;
  final String companyName;
  final String description;
  final String price;
  final String questionAmount;
  final String buyButtonText;
  final VoidCallback onBuyButtonPressed;
  final VoidCallback? onShareButtonPressed;
  final VoidCallback? onLikeButtonPressed;
  final bool isPurchased;
  final bool isLiked;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.x.colors.bannerBackground,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.x.textStyle.sfW400s18.copyWith(
                    color: context.x.colors.bannerText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onLikeButtonPressed != null) ...[
                IconButton(
                  onPressed: onLikeButtonPressed,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? context.x.colors.error : context.x.colors.bannerIcon,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            companyName,
            style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Assets.lib.images.memo.image(width: 16, height: 16, package: 'ui'),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  questionAmount,
                  overflow: TextOverflow.ellipsis,
                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
                ),
              ),
            ],
          ),
          if (!isPurchased) ...[
            Row(
              spacing: 4,
              children: [
                Assets.lib.images.money.image(width: 16, height: 16, package: 'ui'),
                Expanded(
                  child: Text(
                    price,
                    style: context.x.textStyle.sfW700s16.copyWith(
                      fontSize: 15,
                      color: context.x.colors.bannerPriceText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onShareButtonPressed != null) ...[
                IconButton(
                  onPressed: onShareButtonPressed,
                  icon: Assets.lib.vectors.share.svg(
                    width: 24,
                    height: 24,
                    package: 'ui',
                    colorFilter: ColorFilter.mode(context.x.colors.bannerIcon, BlendMode.srcATop),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.x.colors.bannerPriceText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsetsGeometry.zero,
                  ),
                  onPressed: onBuyButtonPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      buyButtonText,
                      style: context.x.textStyle.sfW500s16.copyWith(fontSize: 15, color: context.x.colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
