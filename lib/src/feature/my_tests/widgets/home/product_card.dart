import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/recommendations_model.dart';

/// Figma "Product Card" + horizontal carousel — recommended tests.
/// iOS: the displayed price must come from StoreKit later; [RecommendationItem.price]
/// is already a server string and [iosProductId] identifies the product.
// MOCK/iOS: swap `item.price` for the StoreKit localized price on iOS.
class RecommendationsCarousel extends StatelessWidget {
  const RecommendationsCarousel({required this.items, required this.onTapItem, required this.onFavorite, super.key});

  final List<RecommendationItem> items;
  final void Function(RecommendationItem item) onTapItem;
  final void Function(RecommendationItem item) onFavorite;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 244,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, i) => SizedBox(
        width: 196,
        child: ProductCard(item: items[i], onTap: () => onTapItem(items[i]), onFavorite: () => onFavorite(items[i])),
      ),
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.item, required this.onTap, required this.onFavorite, super.key});

  final RecommendationItem item;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: hc.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [context.x.colors.productCoverGradientStart, context.x.colors.violet],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 40,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(14)),
                      child: Text(item.initial, style: quizText(15, wBold, hc.purple)),
                    ),
                  ),
                  if (item.discountPercent != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: hc.danger, borderRadius: BorderRadius.circular(8)),
                        child: Text('−${item.discountPercent}%', style: quizText(12, wBold, hc.onAccent)),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: onFavorite,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: hc.onAccent.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: Icon(
                          item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: hc.danger,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.organizationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: quizText(12, wMedium, hc.text3),
                        ),
                      ),
                      if (item.organizationVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: hc.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: quizText(15, wSemibold, hc.text),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('★ ${item.rating}', style: quizText(12, wSemibold, hc.warning)),
                      const SizedBox(width: 4),
                      Text('(${item.ratingCount})', style: quizText(12, wRegular, hc.text3)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.oldPrice != null)
                              Text(
                                item.oldPrice!,
                                style: quizText(
                                  11,
                                  wRegular,
                                  hc.text3,
                                ).copyWith(decoration: TextDecoration.lineThrough),
                              ),
                            Text(
                              item.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: quizText(16, wBold, hc.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: hc.primary, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.add_rounded, size: 20, color: hc.onAccent),
                      ),
                    ],
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
