import '../../ui.dart';
import '../check_box/check_box.dart';
import '../extension/context_extension.dart';

//
/// {@template payment_card}
/// PaymentCard widget.
/// {@endtemplate}
class PaymentCard extends StatelessWidget {
  const PaymentCard({
    required this.title,
    this.image,
    this.onTap,
    this.subtitle,
    this.isActive = false,
    this.backgroundColor,
    this.action,
    this.hasShadow = false,
    super.key,
  });

  /// {@macro payment_card}
  final String title;
  final String? subtitle;
  final bool isActive;
  final Widget? image;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Widget? action;
  final bool hasShadow;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.of(context).cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: context.x.colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        // boxShadow: [
        //   BoxShadow(color: context.x.colors.black.withValues(alpha: .1), blurRadius: 10, offset: const Offset(0, 4)),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.x.colors.dialogCancelButton,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(padding: const EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 8), child: image),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.w700s18(title),
                if (subtitle != null) AppText.w400s14(subtitle!, color: ThemeColors.of(context).gray),
              ],
            ),
            const Spacer(),
            action ?? (isActive ? const CheckBox() : const SizedBox()),
          ],
        ),
      ),
    ),
  );
}
