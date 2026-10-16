import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/home_continue_model.dart';
import '../../models/home/home_enums.dart';
import 'home_time.dart';

/// Figma "Hero Continue" — the gradient resume card at the top of Home. Shown
/// only when there is an in-progress session (docs §4.1).
class HeroContinueCard extends StatelessWidget {
  const HeroContinueCard({required this.card, required this.onContinue, super.key});

  final ContinueCardData card;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final white = hc.onAccent;
    final white90 = white.withValues(alpha: 0.9);
    final white85 = white.withValues(alpha: 0.85);

    final modeLabel = switch (card.mode) {
      SessionMode.flashcard => '🃏 ${l10n.homeModeFlashcard}',
      SessionMode.exam => '🎓 ${l10n.homeModeExam}',
      _ => '📝 ${l10n.homeModeTest}',
    };
    final relative = homeRelativeTime(context, card.lastActivityAt);

    return GestureDetector(
      onTap: onContinue,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: hc.heroGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: context.x.colors.homeHeroShadow, blurRadius: 28, offset: const Offset(0, 12))],
        ),
        child: Stack(
          children: [
            // Glass glow — top-right decorative overlay
            Positioned(
              right: -50,
              top: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: .circle,
                  gradient: RadialGradient(
                    colors: [white.withValues(alpha: 0.12), Colors.transparent],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Glass ring — right-center decorative outline
            Positioned(
              right: -35,
              top: 100,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: .circle,
                  border: Border.all(color: white.withValues(alpha: 0.18), width: 1.5),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const .all(18),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      _GlassPill(text: '⏱  ${l10n.homeContinueBadge}', color: white),
                      const Spacer(),
                      _GlassPill(text: modeLabel, color: white),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(card.testName, maxLines: 2, overflow: .ellipsis, style: quizText(22, wBold, white)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          card.organizationName,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: quizText(13, wMedium, white85),
                        ),
                      ),
                      if (card.organizationVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, size: 14, color: white),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(l10n.homeProgressLabel(card.answered, card.total), style: quizText(12, wMedium, white90)),
                      const Spacer(),
                      Text('${card.percent}%', style: quizText(13, wSemibold, white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _Segments(percent: card.percent, color: white),
                  if (relative.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: white85),
                        const SizedBox(width: 4),
                        Text(l10n.homeLastActivity(relative), style: quizText(12, wMedium, white85)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  QuizButton(label: l10n.homeContinueCta, type: .light, size: .l, expand: true, onTap: onContinue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const .symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      borderRadius: .circular(100),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Text(text, style: quizText(12, wSemibold, color)),
  );
}

/// The 10-segment hero progress indicator.
class _Segments extends StatelessWidget {
  const _Segments({required this.percent, required this.color});
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final filled = (percent / 10).floor();
    final hasPartial = percent % 10 != 0;
    return Row(
      children: [
        for (var i = 0; i < 10; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: i < filled ? 1 : (i == filled && hasPartial ? 0.55 : 0.22)),
                borderRadius: .circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
