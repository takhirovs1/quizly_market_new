import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/referral_summary_model.dart';

/// Home "Referral Card" (Figma "G · Referral Card") — a compact summary of the
/// user's referral progress toward the next milestone tier.
///
/// The card body is milestone-based: a gift, the per-friend reward, a "Taklif"
/// share button, and a segmented progress bar toward the next tier. Tapping the
/// card opens the full referral screen ([onOpenAll]) where per-friend bonuses
/// and milestones are actually claimed. All money arrives from the API as
/// display strings (amount-free on iOS).
class ReferralCard extends StatelessWidget {
  const ReferralCard({required this.data, required this.onShare, required this.onOpenAll, super.key});

  final ReferralSummaryResponse data;
  final VoidCallback onShare;
  final VoidCallback onOpenAll;

  static LinearGradient _orangeGradient(ThemeColors c) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [c.referralGradientStart, c.referralGradientEnd],
  );

  static LinearGradient _darkGradient(ThemeColors c) {
    Color tint(Color accent, double alpha) => Color.alphaBlend(accent.withValues(alpha: alpha), c.cardBackground);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [tint(c.orange, 0.16), tint(c.error, 0.10)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isDark = context.x.isDarkMode;
    final milestone = data.currentMilestone;

    return GestureDetector(
      onTap: onOpenAll,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: isDark ? _darkGradient(colors) : _orangeGradient(colors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Figma "Glow" decoration → native radial highlight (top-left).
            Positioned(
              left: -30,
              top: -40,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.pureWhite.withValues(alpha: isDark ? 0.10 : 0.55),
                        colors.pureWhite.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopRow(data: data, onShare: onShare),
                  if (milestone != null && milestone.required > 0) ...[
                    const SizedBox(height: 14),
                    _Milestone(milestone: milestone, joined: data.joinedCount),
                  ] else ...[
                    const SizedBox(height: 10),
                    Text(
                      context.x.l10n.homeReferralInviteHint,
                      style: quizText(12, wRegular, context.x.homeColors.text3),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.data, required this.onShare});
  final ReferralSummaryResponse data;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final reward = data.perFriendReward;
    return Row(
      children: [
        _GiftTile(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeReferralTitle,
                style: quizText(15, wBold, hc.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.homeReferralPerFriend,
                      style: quizText(13, wRegular, hc.text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reward != null && reward.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(reward, style: quizText(13, wSemibold, hc.orangeAccent)),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        QuizButton(
          label: l10n.homeReferralInviteShort,
          type: QuizButtonType.dark,
          size: QuizButtonSize.s,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _GiftTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final tileColor = context.x.isDarkMode ? context.x.colors.cardBackground2 : hc.onAccent;
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: context.x.colors.referralGiftShadow.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const QuizLottieIcon(QuizLottie.prize, size: 36),
    );
  }
}

/// The milestone line ("2 / 5 do‘st · 5-chi do‘stga +X bonus") plus the
/// segmented progress bar. When the tier is reached but unclaimed it swaps to a
/// "goal reached" prompt; the card tap opens the full screen to claim.
class _Milestone extends StatelessWidget {
  const _Milestone({required this.milestone, required this.joined});
  final ReferralMilestone milestone;
  final int joined;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final required = milestone.required;
    final filled = joined.clamp(0, required);
    final reward = milestone.rewardText;
    final rewardHasAmount = reward.contains(RegExp(r'\d'));

    if (milestone.claimable) {
      return Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.homeReferralReachedTitle,
              style: quizText(13, wSemibold, hc.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text('${l10n.homeReferralClaimCta} ›', style: quizText(13, wSemibold, hc.orangeAccent)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.homeReferralMilestone(filled, required), style: quizText(12, wSemibold, hc.text2)),
            const Spacer(),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.homeReferralNextMilestone(required),
                      style: quizText(12, wRegular, hc.text3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reward.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(reward, style: quizText(12, wSemibold, hc.orangeAccent)),
                  ],
                  if (rewardHasAmount) ...[
                    const SizedBox(width: 4),
                    Text(l10n.homeReferralBonusSuffix, style: quizText(12, wRegular, hc.text3)),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Segments(total: required, filled: filled),
      ],
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.total, required this.filled});
  final int total;
  final int filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final fill = context.x.homeColors.orangeAccent;
    final empty = colors.pureWhite.withValues(alpha: context.x.isDarkMode ? 0.14 : 0.7);

    // Discrete segments, one per friend to the goal (Figma) — never a single
    // bar. Tighter gap for larger tiers (10/25) so the segments stay crisp.
    final count = total.clamp(1, 30);
    final gap = count > 12 ? 2.0 : 4.0;
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: i < filled ? fill : empty, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ],
      ],
    );
  }
}
