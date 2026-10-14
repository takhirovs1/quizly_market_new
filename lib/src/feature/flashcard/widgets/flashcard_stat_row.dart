import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// A labeled statistic row (icon + label + value) on the result screen.
class FlashcardStatRow extends StatelessWidget {
  const FlashcardStatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: context.x.textStyle.sfW400s16.copyWith(fontSize: 15, color: colors.text)),
          ),
          Text(value, style: context.x.textStyle.sfW600s16.copyWith(fontSize: 15, color: colors.text)),
        ],
      ),
    );
  }
}
