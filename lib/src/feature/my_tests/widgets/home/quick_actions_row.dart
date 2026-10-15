import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';

/// Figma "Actions row" — Tasodifiy test · Xatolar ustida · Flashcard. Disabled
/// (40% opacity) when the user has no tests to practice.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    required this.enabled,
    required this.mistakesCount,
    required this.onRandom,
    required this.onMistakes,
    required this.onFlashcard,
    super.key,
  });

  final bool enabled;
  final int mistakesCount;
  final VoidCallback onRandom;
  final VoidCallback onMistakes;
  final VoidCallback onFlashcard;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            icon: Assets.lib.icon.shuffle,
            iconColor: hc.primary,
            iconBackground: hc.primaryTint,
            label: l10n.homeActionRandom,
            enabled: enabled,
            onTap: onRandom,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QuickActionButton(
            icon: Assets.lib.icon.mistakes,
            iconColor: hc.danger,
            iconBackground: hc.dangerTint,
            label: l10n.homeActionMistakes,
            enabled: enabled,
            badgeCount: mistakesCount,
            onTap: onMistakes,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: QuickActionButton(
            icon: Assets.lib.icon.flashcards,
            iconColor: hc.purple,
            iconBackground: hc.purpleTint,
            label: l10n.homeActionFlashcard,
            enabled: enabled,
            onTap: onFlashcard,
          ),
        ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.badgeCount = 0,
    super.key,
  });

  final SvgGenImage icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: hc.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [hc.softShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                    // The icons are white-stroke glyphs; srcIn recolors them to
                    // each action's accent so one asset set serves light + dark.
                    child: icon.svg(
                      package: 'ui',
                      width: 26,
                      height: 26,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hc.danger,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: hc.surface, width: 2),
                        ),
                        constraints: const BoxConstraints(minWidth: 20),
                        alignment: Alignment.center,
                        child: Text(badgeCount > 99 ? '99+' : '$badgeCount', style: quizText(11, wBold, hc.onAccent)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(13, wSemibold, hc.text2)),
            ],
          ),
        ),
      ),
    );
  }
}
