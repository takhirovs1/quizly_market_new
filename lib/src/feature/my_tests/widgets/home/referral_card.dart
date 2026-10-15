import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/referral_summary_model.dart';
import 'home_time.dart';

/// Home "Referral Card" — per-friend claimable bonuses (docs §4.9).
///
/// Each friend who joined via the user's link is a separately-claimable bonus.
/// Tapping the card body opens the full referral screen ([onOpenAll]); the
/// "Ulashish" button shares the referral link ([onShare]); each friend row has
/// its own "Olish" button ([onClaim]). All money comes from the API as display
/// strings (never hardcoded; amount-free on iOS).
class ReferralCard extends StatelessWidget {
  const ReferralCard({
    required this.data,
    required this.onShare,
    required this.onClaim,
    required this.onOpenAll,
    super.key,
  });

  final ReferralSummaryResponse data;
  final VoidCallback onShare;
  final void Function(String friendId) onClaim;
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
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;

    final friends = data.friends;
    final shown = friends.take(3).toList();
    final unclaimed = data.unclaimedCount;

    return GestureDetector(
      onTap: onOpenAll,
      behavior: HitTestBehavior.opaque,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: isDark ? _darkGradient(colors) : _orangeGradient(colors),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _GiftTile(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unclaimed > 0 ? l10n.homeReferralBonusReady(unclaimed) : l10n.homeReferralTitle,
                        style: quizText(15, wBold, hc.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(child: Text(l10n.homeReferralPerFriend, style: quizText(13, wRegular, hc.text2))),
                          const SizedBox(width: 4),
                          Text(data.perFriendReward ?? '', style: quizText(13, wSemibold, hc.orangeAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                QuizButton(
                  label: l10n.homeReferralShareCta,
                  type: QuizButtonType.dark,
                  leadingLottie: QuizLottie.share,
                  size: QuizButtonSize.s,
                  onTap: onShare,
                ),
              ],
            ),
            if (shown.isEmpty) ...[
              const SizedBox(height: 12),
              Text(l10n.homeReferralInviteHint, style: quizText(12, wRegular, hc.text3)),
            ] else ...[
              const SizedBox(height: 14),
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _FriendRow(friend: shown[i], onClaim: onClaim),
              ],
              if (data.joinedCount > shown.length) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(l10n.homeReferralSeeAll(data.joinedCount), style: quizText(13, wSemibold, hc.primary)),
                    Icon(Icons.chevron_right_rounded, size: 18, color: hc.primary),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
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

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.friend, required this.onClaim});
  final ReferralFriend friend;
  final void Function(String friendId) onClaim;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final accent = colorFromHex(friend.color, fallback: hc.purple);
    final subtitle = friend.joinedAt != null ? homeRelativeTime(context, friend.joinedAt) : friend.rewardText;

    return Row(
      children: [
        QuizInitialAvatar(
          initial: friend.name.isNotEmpty ? friend.name.substring(0, 1).toUpperCase() : '•',
          color: accent,
          background: accent.withValues(alpha: 0.15),
          size: 40,
          borderColor: hc.surface,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(friend.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(14, wSemibold, hc.text)),
              const SizedBox(height: 2),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(12, wRegular, hc.text3)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (friend.claimed)
          QuizPill(text: '✓ ${l10n.homeReferralClaimedShort}', background: hc.successTint, foreground: hc.success)
        else if (friend.claimable)
          QuizButton(
            label: l10n.homeReferralClaimShort,
            type: QuizButtonType.success,
            size: QuizButtonSize.s,
            onTap: () => onClaim(friend.id),
          )
        else
          Text(friend.rewardText, style: quizText(13, wSemibold, hc.text3)),
      ],
    );
  }
}
