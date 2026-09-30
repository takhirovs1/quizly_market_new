import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

class UploadTypeTile extends StatelessWidget {
  const UploadTypeTile({required this.title, required this.icon, this.onTap, this.isComingSoon = false, super.key});

  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final bool isComingSoon;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isDark = context.x.isDarkMode;

    return CupertinoButton(
      onPressed: isComingSoon ? null : (onTap ?? () {}),
      padding: .zero,
      child: Container(
        height: 56,
        padding: const .symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: colors.buttonFill, borderRadius: .circular(12)),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(shape: .circle, color: isDark ? colors.cardBackground2 : colors.white),
              child: SizedBox(width: 40, height: 40, child: Center(child: icon)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: textStyle.sfW500s16.copyWith(color: colors.text)),
            ),
            if (isComingSoon)
              Text(
                context.x.l10n.comingSoon,
                style: textStyle.sfW600s16.copyWith(color: colors.bannerPriceText, fontSize: 14, fontWeight: .w600),
              )
            else
              Icon(Icons.keyboard_arrow_right_rounded, color: colors.text, size: 24),
          ],
        ),
      ),
    );
  }
}
