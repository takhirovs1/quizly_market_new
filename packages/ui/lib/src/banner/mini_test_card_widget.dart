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
    super.key,
  });

  final String title;
  final String companyName;
  final String description;
  final String price;
  final String questionAmount;
  final String buyButtonText;
  final VoidCallback onBuyButtonPressed;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 200, minHeight: 180),
    child: DecoratedBox(
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
              style: context.x.theme.textTheme.titleMedium?.copyWith(color: context.x.colors.bannerText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              companyName,
              style: context.x.theme.textTheme.titleMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: context.x.theme.textTheme.bodyMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
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
                    style: context.x.theme.textTheme.bodyMedium?.copyWith(color: context.x.colors.bannerSecondaryText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 4,
              children: [
                Assets.lib.images.money.image(width: 16, height: 16, package: 'ui'),
                Expanded(
                  child: Text(
                    price,
                    style: context.x.theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.x.colors.bannerPriceText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.x.colors.bannerPriceText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(8),
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
          ],
        ),
      ),
    ),
  );
}
