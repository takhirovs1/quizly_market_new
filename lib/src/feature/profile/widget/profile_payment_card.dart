import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class ProfilePaymentCard extends StatelessWidget {
  const ProfilePaymentCard({
    required this.balance,
    required this.cardNumber,
    required this.onCopyCardNumber,
    super.key,
  });
  final String balance;
  final String cardNumber;
  final VoidCallback onCopyCardNumber;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .symmetric(horizontal: 16),
    child: Stack(
      children: [
        Assets.lib.images.paymeBg.image(package: 'ui'),
        Positioned(top: 16, right: 16, child: Assets.lib.images.logoPng.image(package: 'ui', width: 75, height: 75)),

        Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 4,
            children: [
              Text('Card Balance', style: context.x.textStyle.w500s14.copyWith(color: context.x.colors.white)),
              Text(balance, style: context.x.textStyle.w700s28.copyWith(color: context.x.colors.white)),
              Text('QuizlyMarket Card', style: context.x.textStyle.w500s14.copyWith(color: context.x.colors.white)),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Row(
            spacing: 6,
            children: [
              Text('ID: $cardNumber', style: context.x.textStyle.w500s16.copyWith(color: context.x.colors.white)),
              GestureDetector(
                onTap: onCopyCardNumber,
                child: Assets.lib.vectors.copyId.svg(package: 'ui', width: 24, height: 24),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
