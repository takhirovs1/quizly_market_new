import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class ProfilePaymentCard extends StatelessWidget {
  const ProfilePaymentCard({
    required this.balance,
    required this.cardNumber,
    required this.onCopyCardNumber,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final String balance;
  final String cardNumber;
  final VoidCallback onCopyCardNumber;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == .dark;
    final baseColor = isDark ? const Color(0x40FFFFFF) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0x60FFFFFF) : const Color(0xFFF1F5F9);

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: .circular(16),
          image: DecorationImage(
            image: Assets.lib.images.paymeBg.provider(package: 'ui'),
            fit: .cover,
          ),
        ),
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 4,
                      children: [
                        Text(
                          context.x.l10n.cardBalance,
                          style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.white),
                        ),
                        if (isLoading)
                          Shimmer.fromColors(
                            baseColor: baseColor,
                            highlightColor: highlightColor,
                            child: const ShimmerBox(width: 150, height: 32, radius: 4),
                          )
                        else
                          FittedBox(
                            fit: .scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              balance,
                              style: context.x.textStyle.sfW700s28.copyWith(color: context.x.colors.white),
                            ),
                          ),
                        Text(
                          context.x.l10n.quizlyMarket,
                          style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Assets.lib.images.logoPng.image(package: 'ui', width: 75, height: 75),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 6,
                children: [
                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: const ShimmerBox(width: 100, height: 18, radius: 4),
                    )
                  else
                    Expanded(
                      child: Row(
                        spacing: 6,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ID: $cardNumber',
                                style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.white),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onCopyCardNumber,
                            child: Assets.lib.vectors.copyId.svg(package: 'ui', width: 24, height: 24),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
