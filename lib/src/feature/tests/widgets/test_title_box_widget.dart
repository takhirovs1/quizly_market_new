import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class TestTitleBoxWidget extends StatelessWidget {
  const TestTitleBoxWidget({required this.title, required this.onPressed, this.isSelected = false, super.key});
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? context.x.colors.primary : context.x.colors.gray,
          width: isSelected ? 1.2 : 1,
        ),
        borderRadius: .circular(8),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 12, vertical: 6),
        child: Text(title, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 14)),
      ),
    ),
  );
}
