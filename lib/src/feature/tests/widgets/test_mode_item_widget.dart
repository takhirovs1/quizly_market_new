import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class TestModeItemWidget extends StatelessWidget {
  const TestModeItemWidget({
    required this.title,
    required this.description,
    required this.image,
    required this.onPressed,
    super.key,
  });
  final String title;
  final String description;
  final Widget image;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onPressed,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.x.colors.cardBackground2,
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            offset: const Offset(0, 12),
            blurRadius: 56,
            spreadRadius: 0,
          ),
          BoxShadow(color: Colors.black.withValues(alpha: .05), offset: .zero, blurRadius: 3, spreadRadius: 0),
        ],
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: context.x.colors.primary, shape: .circle),
              child: Padding(padding: const .all(11.5), child: image),
            ),
            const SizedBox(height: 6),
            Text(title, style: context.x.textStyle.sfW500s22, textAlign: .center),
            Text(
              description,
              style: context.x.textStyle.sfW400s12.copyWith(color: context.x.colors.gray),
              textAlign: .center,
            ),
          ],
        ),
      ),
    ),
  );
}
