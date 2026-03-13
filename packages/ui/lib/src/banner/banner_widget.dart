import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../extension/context_extension.dart';
import '../gen/assets.gen.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({
    required this.title,
    required this.companyName,
    required this.description,
    required this.price,
    required this.questionAmount,
    required this.buyButtonText,
    this.onBuyButtonPressed,
    this.onShareButtonPressed,
    this.isFree = false,
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
  final bool isFree;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.x.theme.textTheme.titleMedium?.copyWith(color: context.x.colors.bannerText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    companyName,
                    style: context.x.theme.textTheme.titleMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: context.x.theme.textTheme.bodyMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
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
                style: context.x.theme.textTheme.bodyMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                if (!isFree)
                  Lottie.asset(Assets.lib.lottie.money, width: 16, height: 16, package: 'ui')
                else
                  const Icon(Icons.photo_library_outlined),
                const SizedBox(width: 4),
                Text(
                  price,
                  style: context.x.theme.textTheme.labelLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.x.colors.bannerPriceText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: onShareButtonPressed,
                          child: Assets.lib.vectors.share.svg(
                            width: 24,
                            height: 24,
                            package: 'ui',
                            colorFilter: ColorFilter.mode(context.x.colors.bannerIcon, BlendMode.srcATop),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.x.colors.bannerPriceText,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: onBuyButtonPressed,
                            child: Text(
                              buyButtonText,
                              style: context.x.theme.textTheme.labelLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.x.colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
