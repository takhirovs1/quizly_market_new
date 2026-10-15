import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/home_enums.dart';

/// Figma "Test Card" (NotStarted / InProgress / Completed) used in "Mening
/// testlarim" and for the free example test. Status drives the accent color,
/// status pill, progress fill and CTA.
class HomeTestCard extends StatelessWidget {
  const HomeTestCard({
    required this.title,
    required this.organizationName,
    required this.organizationVerified,
    required this.status,
    required this.answered,
    required this.total,
    required this.percent,
    required this.onTap,
    this.resultPercent,
    this.ratingRank,
    this.ratingTotalParticipants,
    this.onRatingTap,
    this.onMore,
    this.isExample = false,
    super.key,
  });

  final String title;
  final String organizationName;
  final bool organizationVerified;
  final MyTestStatus status;
  final int answered;
  final int total;
  final int percent;
  final int? resultPercent;
  final int? ratingRank;
  final int? ratingTotalParticipants;
  final VoidCallback? onRatingTap;
  final VoidCallback? onMore;
  final VoidCallback onTap;
  final bool isExample;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final initial = title.isNotEmpty ? title.substring(0, 1).toUpperCase() : '?';

    final (Color avatarColor, Color avatarTint) = switch (status) {
      MyTestStatus.inProgress => (hc.warning, hc.warningTint),
      MyTestStatus.completed => (hc.success, hc.successTint),
      MyTestStatus.notStarted => (hc.purple, hc.purpleTint),
    };
    final (String statusText, Color statusBg, Color statusFg) = switch (status) {
      MyTestStatus.inProgress => (l10n.homeStatusInProgress, hc.warningTint, hc.warning),
      MyTestStatus.completed => (l10n.homeStatusCompleted, hc.successTint, hc.success),
      MyTestStatus.notStarted => (l10n.homeStatusNotStarted, hc.bg, hc.text3),
    };
    final barFill = switch (status) {
      MyTestStatus.inProgress => hc.warning,
      MyTestStatus.completed => hc.success,
      MyTestStatus.notStarted => hc.track,
    };
    final percentColor = status == MyTestStatus.notStarted ? hc.text3 : barFill;

    final (QuizButtonType ctaType, String ctaLabel) = switch (status) {
      MyTestStatus.inProgress => (QuizButtonType.primary, l10n.homeContinueCta),
      MyTestStatus.completed => (QuizButtonType.tonal, l10n.homeCtaReview),
      MyTestStatus.notStarted => (QuizButtonType.primary, l10n.homeCtaStart),
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [hc.softShadow],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (A) header
            Row(
              children: [
                QuizInitialAvatar(initial: initial, color: avatarColor, background: avatarTint),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: quizText(17, wSemibold, hc.text),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              organizationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: quizText(13, wRegular, hc.text3),
                            ),
                          ),
                          if (organizationVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified_rounded, size: 14, color: hc.primary),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (onMore != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onMore,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: hc.bg, shape: BoxShape.circle),
                      child: Icon(Icons.more_horiz_rounded, size: 18, color: hc.text3),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            // (B) chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                QuizPill(text: statusText, background: statusBg, foreground: statusFg, showDot: true),
                QuizPill(text: l10n.questionAmountText(total), background: hc.bg, foreground: hc.text2),
                if (isExample) QuizPill(text: l10n.homeFree, background: hc.primaryTint, foreground: hc.primary),
                if (status == MyTestStatus.completed && resultPercent != null)
                  QuizPill(
                    leading: const QuizLottieIcon(QuizLottie.cup, size: 14),
                    text: l10n.homeResultPercent(resultPercent!),
                    background: hc.warningTint,
                    foreground: hc.text2,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // (C) progress + CTA
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l10n.homeProgressLabel(answered, total), style: quizText(12, wMedium, hc.text3)),
                          const Spacer(),
                          Text('$percent%', style: quizText(12, wSemibold, percentColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ProgressBar(percent: percent, fill: barFill, track: hc.track),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                QuizButton(label: ctaLabel, type: ctaType, onTap: onTap),
              ],
            ),
            // (D)+(E) rating
            if (ratingTotalParticipants != null) ...[
              const SizedBox(height: 14),
              Container(height: 1, color: hc.track),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onRatingTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 16, color: hc.text3),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        status == MyTestStatus.completed && ratingRank != null
                            ? l10n.homeRatingRankParticipants(ratingRank!, ratingTotalParticipants!)
                            : l10n.homeRatingParticipants(ratingTotalParticipants!),
                        style: quizText(13, wMedium, status == MyTestStatus.completed ? hc.text2 : hc.text3),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: hc.text3),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.percent, required this.fill, required this.track});
  final int percent;
  final Color fill;
  final Color track;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(3),
    child: Stack(
      children: [
        Container(height: 6, color: track),
        FractionallySizedBox(
          widthFactor: (percent / 100).clamp(0.0, 1.0),
          child: Container(height: 6, color: fill),
        ),
      ],
    ),
  );
}
