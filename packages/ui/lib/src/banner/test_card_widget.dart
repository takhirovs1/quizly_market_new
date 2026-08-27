import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../gen/assets.gen.dart';

class TestCardWidget extends StatelessWidget {
  const TestCardWidget({
    required this.title,
    required this.companyName,
    required this.description,
    required this.price,
    required this.questionAmount,
    required this.buyButtonText,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.onBuyButtonPressed,
    this.onShareButtonPressed,
    this.onLikeButtonPressed,
    this.isFree = false,
    this.isPurchased = false,
    this.isLiked = false,
    this.showPrice = true,
    this.textBought,
    super.key,
  });

  final String title;
  final String companyName;
  final String description;
  final String price;
  final String questionAmount;
  final String buyButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final VoidCallback? onBuyButtonPressed;
  final VoidCallback? onShareButtonPressed;
  final VoidCallback? onLikeButtonPressed;
  final bool isFree;
  final bool isPurchased;
  final bool isLiked;
  final bool showPrice;
  final String? textBought;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bannerBackground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        title,
                        style: context.x.textStyle.sfW400s18.copyWith(
                          color: colors.bannerText,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          companyName,
                          style: context.x.textStyle.sfW500s16.copyWith(color: colors.bannerSecondaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: context.x.textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Assets.lib.images.memo.image(width: 16, height: 16, package: 'ui'),
                    const SizedBox(width: 4),
                    Text(
                      questionAmount,
                      style: context.x.textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (showPrice && !isPurchased && price.isNotEmpty) ...[
                    if (!isFree)
                      Assets.lib.images.money.image(width: 16, height: 16, package: 'ui')
                    else
                      Assets.lib.images.partyPopper.image(width: 16, height: 16, package: 'ui'),
                    const SizedBox(width: 4),
                    Text(
                      price,
                      style: context.x.textStyle.sfW700s16.copyWith(fontSize: 15, color: colors.bannerPriceText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (secondaryButtonText != null) ...[
                            CupertinoButton(
                              onPressed: onSecondaryButtonPressed ?? () {},
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? colors.cardBackground2 : colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  secondaryButtonText!,
                                  style: context.x.textStyle.sfW500s16.copyWith(
                                    fontSize: 14,
                                    color: colors.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            if (onShareButtonPressed != null)
                              IconButton(
                                onPressed: onShareButtonPressed,
                                icon: Assets.lib.vectors.share.svg(
                                  width: 24,
                                  height: 24,
                                  package: 'ui',
                                  colorFilter: ColorFilter.mode(colors.bannerIcon, BlendMode.srcATop),
                                ),
                              ),
                            if (onLikeButtonPressed != null) ...[
                              IconButton(
                                onPressed: onLikeButtonPressed,
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? colors.error : colors.bannerIcon,
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.bannerPriceText,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: EdgeInsetsGeometry.zero,
                              ),
                              onPressed: onBuyButtonPressed,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Text(
                                  buyButtonText,
                                  style: context.x.textStyle.sfW500s16.copyWith(
                                    fontSize: 14,
                                    color: colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
