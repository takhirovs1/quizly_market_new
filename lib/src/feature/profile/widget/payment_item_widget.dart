import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class PaymentItemWidget extends StatelessWidget {
  const PaymentItemWidget({
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
    this.width,
    this.backgroundColor,
  });
  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? width;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.x.colors.white,
          borderRadius: .circular(8),
          border: .all(color: isSelected ? context.x.colors.primary : context.x.colors.gray, width: isSelected ? 2 : 1),
        ),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}
