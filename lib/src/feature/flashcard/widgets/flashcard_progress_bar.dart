import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

/// Top bar of the study session: an undo button, a gradient progress track and
/// a "current / total" counter. All colors come from the app theme.
class FlashcardProgressBar extends StatelessWidget {
  const FlashcardProgressBar({
    required this.current,
    required this.total,
    required this.canUndo,
    required this.onUndo,
    super.key,
  });

  final int current;
  final int total;
  final bool canUndo;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: canUndo ? onUndo : null,
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: canUndo ? 1 : 0.4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: colors.textFieldBackground, borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.undo_rounded, size: 18, color: colors.gray),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: ColoredBox(
                color: colors.textFieldBackground,
                child: SizedBox(
                  height: 8,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: LayoutBuilder(
                      builder: (context, c) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        width: c.maxWidth * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [colors.primary, colors.tealBlue]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$current / $total', style: context.x.textStyle.sfW600s16.copyWith(fontSize: 15, color: colors.text)),
        ],
      ),
    );
  }
}
