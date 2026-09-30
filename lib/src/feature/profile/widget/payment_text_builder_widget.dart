import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class PaymentTextBuilderWidget extends StatelessWidget {
  const PaymentTextBuilderWidget({required this.text, super.key, this.isImportant = false});
  final String text;
  final bool isImportant;
  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.bannerSecondaryText),
      children: [
        TextSpan(text: text),
        if (isImportant)
          TextSpan(
            text: ' *',
            style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.error),
          ),
      ],
    ),
  );
}
