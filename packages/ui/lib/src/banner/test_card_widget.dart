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
    this.onBuyButtonPressed,
    this.onShareButtonPressed,
    this.onLikeButtonPressed,
    this.isFree = false,
    this.isPurchased = false,
    this.isLiked = false,
    this.textBought,
    super.key,
  });

  final String title;
  final String companyName;
  final String description;
  final String price;
  final String questionAmount;
  final String buyButtonText;
  final VoidCallback? onBuyButtonPressed;
  final VoidCallback? onShareButtonPressed;
  final VoidCallback? onLikeButtonPressed;
  final bool isFree;
  final bool isPurchased;
  final bool isLiked;
  final String? textBought;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.x.colors.bannerBackground,
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
                        color: context.x.colors.bannerText,
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
                        style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.bannerSecondaryText),
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
                style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
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
                    style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (!isPurchased) ...[
                  if (!isFree)
                    Assets.lib.images.money.image(width: 16, height: 16, package: 'ui')
                  else
                    Assets.lib.images.partyPopper.image(width: 16, height: 16, package: 'ui'),
                  const SizedBox(width: 4),
                  Text(
                    price,
                    style: context.x.textStyle.sfW700s16.copyWith(
                      fontSize: 15,
                      color: context.x.colors.bannerPriceText,
                    ),
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
                        IconButton(
                          onPressed: onShareButtonPressed,
                          icon: Assets.lib.vectors.share.svg(
                            width: 24,
                            height: 24,
                            package: 'ui',
                            colorFilter: ColorFilter.mode(context.x.colors.bannerIcon, BlendMode.srcATop),
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
                        ],
                        const SizedBox(width: 4),
                        Flexible(
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
                                style: context.x.textStyle.sfW500s16.copyWith(
                                  fontSize: 15,
                                  color: context.x.colors.white,
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
