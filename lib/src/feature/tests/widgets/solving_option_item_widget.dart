import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/demo_test_model.dart';

class SolvingOptionItemWidget extends StatelessWidget {
  const SolvingOptionItemWidget({
    required this.option,
    required this.isSelected,
    required this.isChecked,
    required this.onTap,
    super.key,
  });

  final DemoOption option;
  final bool isSelected;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default states
    Color backgroundColor = isDark ? colors.scaffoldBackground : const Color(0xFFF8F9FA);
    Color borderColor = isDark ? colors.divider : colors.gray.withValues(alpha: 0.2);
    Color textColor = colors.text;

    // When the answer is checked (submitted)
    if (isChecked) {
      if (option.isCorrect ?? false) {
        backgroundColor = isDark ? const Color(0xFF163C24) : const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF43C04D); // Success Green
      } else if (isSelected) {
        backgroundColor = isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE53935); // Error Red
      }
    } else {
      // Selected state before check
      if (isSelected) {
        backgroundColor = colors.primary.withValues(alpha: isDark ? 0.15 : 0.08);
        borderColor = colors.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isChecked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: colors.primary.withValues(alpha: isDark ? 0.08 : 0.03),
          splashColor: colors.primary.withValues(alpha: 0.1),
          highlightColor: colors.primary.withValues(alpha: 0.05),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected || (isChecked && (option.isCorrect ?? false)) ? 2.0 : 1.0,
              ),
              boxShadow: isSelected && !isChecked
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                _buildIndicator(context, colors, isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.text ?? '',
                    style: context.x.textStyle.sfW500s14.copyWith(color: textColor, fontSize: 15.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, dynamic colors, bool isDark) {
    if (isChecked) {
      if (option.isCorrect ?? false) {
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Color(0xFF43C04D), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      } else if (isSelected) {
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 14),
        );
      }
    }

    // Default indicators (circular dot)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(
          color: isSelected ? context.x.colors.primary : context.x.colors.gray.withValues(alpha: 0.4),
          width: isSelected ? 6 : 2,
        ),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
    );
  }
}
