import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/home_enums.dart';
import '../../models/home/my_tests_preview_model.dart';

/// Figma "Chip/Filter" row for "Mening testlarim" — status counts. Tapping a
/// chip filters the preview locally (no navigation); [selected] `null` = the
/// "Barchasi" chip. The full list is reached via the section's "Barchasi ›"
/// header link, not these chips.
class HomeStatusChips extends StatelessWidget {
  const HomeStatusChips({required this.counts, required this.selected, this.onSelect, super.key});

  final MyTestsStatusCounts counts;

  /// Currently selected status, or `null` for "Barchasi" (all).
  final MyTestStatus? selected;

  /// Called with the tapped status (or `null` for "Barchasi").
  final void Function(MyTestStatus? status)? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.x.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: l10n.homeChipAll,
            count: counts.all,
            active: selected == null,
            onTap: () => onSelect?.call(null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.homeStatusInProgress,
            icon: QuizLottie.progress,
            count: counts.inProgress,
            active: selected == MyTestStatus.inProgress,
            onTap: () => onSelect?.call(MyTestStatus.inProgress),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.homeStatusCompleted,
            icon: QuizLottie.check,
            count: counts.completed,
            active: selected == MyTestStatus.completed,
            onTap: () => onSelect?.call(MyTestStatus.completed),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.count, required this.active, this.icon, this.onTap});
  final String label;
  final QuizLottie? icon;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    // Active pill inverts the surface (dark pill on light, light pill on dark).
    // `onAccent` is always white, so on the light-coloured dark-mode pill we must
    // use a dark foreground instead or the text/count would be white-on-white.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFg = isDark ? hc.surface : hc.onAccent;
    final fg = active ? activeFg : hc.text2;
    final countFg = active ? activeFg.withValues(alpha: 0.6) : hc.text3;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? hc.text : hc.surface,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: hc.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[QuizLottieIcon(icon!, size: 16, repeat: false, color: fg), const SizedBox(width: 6)],
            Text(label, style: quizText(14, wSemibold, fg)),
            const SizedBox(width: 6),
            Text('$count', style: quizText(13, wMedium, countFg)),
          ],
        ),
      ),
    );
  }
}
