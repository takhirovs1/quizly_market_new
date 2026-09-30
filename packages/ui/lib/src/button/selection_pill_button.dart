import 'package:flutter/cupertino.dart';

import '../../ui.dart';
import '../extension/context_extension.dart';

/// A large rounded selection button (pill-like) with optional trailing check.
class SelectionPillButton extends StatelessWidget {
  const SelectionPillButton({required this.label, required this.isSelected, this.onTap, this.height = 56, super.key});

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? context.x.colors.primary : context.x.colors.selectionPillUnselectedBackground;
    final fg = isSelected ? context.x.colors.white : context.x.colors.text;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.x.textStyle.sfW400s16.copyWith(color: fg),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 12),
              Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 24, color: context.x.colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
