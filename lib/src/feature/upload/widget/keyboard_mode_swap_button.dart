import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Compact 2-segment toggle that switches an [AnswerInputField] between the
/// native keyboard (⌨) and the math keyboard (fx).
///
/// When the field has content, the *unselected* segment turns into a clear (✕)
/// button so the active-mode indicator always stays visible. See
/// docs/math_native_keyboard_flow.md §6.2.
class KeyboardModeSwapButton extends StatelessWidget {
  const KeyboardModeSwapButton({
    required this.isMath,
    required this.onChanged,
    required this.onClear,
    this.enabled = true,
    this.showClear = false,
    super.key,
  });

  /// Whether the formula (math) mode is currently active.
  final bool isMath;

  /// Called with the requested target mode (`true` = math).
  final ValueChanged<bool> onChanged;

  /// Clears both controllers.
  final VoidCallback onClear;

  final bool enabled;

  /// When true the unselected segment becomes a clear (✕) button.
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;

    // Left slot: ⌨ (native) unless clearing while text mode is active.
    final leftIsClear = showClear && !isMath;
    // Right slot: fx (math) unless clearing while math mode is active.
    final rightIsClear = showClear && isMath;

    return Semantics(
      button: true,
      label: isMath ? context.x.l10n.answerModeFormula : context.x.l10n.answerModeText,
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: colors.textFieldBackground, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Segment(
              icon: leftIsClear ? Icons.close_rounded : Icons.keyboard_outlined,
              selected: !isMath && !leftIsClear,
              enabled: enabled,
              onTap: leftIsClear ? onClear : () => onChanged(false),
              selectedColor: leftIsClear ? colors.error : colors.primary,
            ),
            const SizedBox(width: 2),
            _Segment(
              icon: rightIsClear ? Icons.close_rounded : Icons.functions_rounded,
              selected: isMath && !rightIsClear,
              enabled: enabled,
              onTap: rightIsClear ? onClear : () => onChanged(true),
              selectedColor: rightIsClear ? colors.error : colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.selectedColor,
  });

  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isClear = icon == Icons.close_rounded;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 40,
        height: 28,
        decoration: BoxDecoration(
          color: selected ? selectedColor : (isClear ? selectedColor.withValues(alpha: 0.12) : colors.transparent),
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [BoxShadow(color: selectedColor.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected
              ? colors.white
              : isClear
              ? selectedColor
              : colors.bannerSecondaryText,
        ),
      ),
    );
  }
}
