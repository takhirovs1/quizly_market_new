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
    this.imagePadding = const EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8.5),
    this.titleWidget,
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
  final EdgeInsetsGeometry imagePadding;
  final Widget? titleWidget;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.x.colors.cardBackground2,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  offset: const Offset(0, 12),
                  blurRadius: 56,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  offset: Offset.zero,
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
              ]
            : null,
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
              child: Padding(padding: imagePadding, child: image),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget ?? Text(title, style: context.x.textStyle.sfW700s18),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.bannerSecondaryText),
                  ),
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
