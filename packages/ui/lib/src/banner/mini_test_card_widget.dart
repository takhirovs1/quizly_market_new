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
    this.isPurchased = false,
    super.key,
  });

  final String title;
  final String companyName;
  final String description;
  final String price;
  final String questionAmount;
  final String buyButtonText;
  final VoidCallback onBuyButtonPressed;
  final bool isPurchased;

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
          Text(
            title,
            style: context.x.textStyle.sfW400s18.copyWith(
              color: context.x.colors.bannerText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 4),
          Row(
            spacing: 4,
            children: [
              if (isPurchased)
                Assets.lib.images.partyPopper.image(width: 16, height: 16, package: 'ui')
              else
                Assets.lib.images.money.image(width: 16, height: 16, package: 'ui'),
              Expanded(
                child: Text(
                  price,
                  style: context.x.textStyle.sfW700s16.copyWith(fontSize: 15, color: context.x.colors.bannerPriceText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Spacer(),
          FilledButton(
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
        ],
      ),
    ),
  );
}
