import 'package:flutter/material.dart';

import '../extension/context_extension.dart';

class CustomButton2 extends StatelessWidget {
  const CustomButton2({
    required this.width,
    required this.onRightPressed,
    required this.rightText,
    this.leftButtonType = ButtonType.active,
    this.rightButtonType = ButtonType.active,
    this.onLeftPressed,
    this.leftText,
    super.key,
  });
  final VoidCallback? onLeftPressed;
  final VoidCallback onRightPressed;
  final ButtonType leftButtonType;
  final ButtonType rightButtonType;
  final String? leftText;
  final String rightText;
  final double width;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        if (leftText != null)
          Flexible(
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: leftButtonType == ButtonType.active
                    ? context.x.colors.primary.withValues(alpha: 0.1)
                    : leftButtonType == ButtonType.error
                    ? context.x.colors.error
                    : context.x.colors.gray.withValues(alpha: 0.1),
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                fixedSize: Size(width, 50),
              ),
              onPressed: leftButtonType != ButtonType.disabled ? onLeftPressed : null,
              child: Text(
                leftText ?? '',
                style: context.x.textStyle.sfW500s16.copyWith(
                  color: context.x.colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        Flexible(
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: rightButtonType == ButtonType.active
                  ? context.x.colors.primary
                  : rightButtonType == ButtonType.error
                  ? context.x.colors.error
                  : context.x.colors.gray.withValues(alpha: 0.1),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              fixedSize: Size(width, 50),
            ),
            onPressed: rightButtonType != ButtonType.disabled ? onRightPressed : null,
            child: Center(
              child: Text(
                rightText,
                style: context.x.textStyle.sfW500s16.copyWith(
                  color: context.x.colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

enum ButtonType { active, disabled, error }
