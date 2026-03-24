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
  });
  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? width;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.x.colors.white,
          borderRadius: .circular(8),
          border: .all(color: isSelected ? context.x.colors.primary : context.x.colors.gray, width: 1),
        ),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}
