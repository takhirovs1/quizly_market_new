import 'dart:math' as math;

import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/friends_rating_model.dart';

/// Figma "Friends Rating Card" (NoFriends / Leader / Middle / Tie) — weekly XP
/// standing among friends (docs §4.7).
class FriendsRatingCard extends StatelessWidget {
  const FriendsRatingCard({required this.data, required this.onInvite, required this.onOpenRating, super.key});

  final FriendsRatingResponse data;
  final VoidCallback onInvite;
  final VoidCallback onOpenRating;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final hasFriends = data.friendsCount > 0 && data.meRank != null;

    return Container(
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.homeFriendsTitle, style: quizText(17, wSemibold, hc.text)),
              const Spacer(),
              Text(l10n.homeFriendsThisWeekXp, style: quizText(13, wRegular, hc.text3)),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasFriends) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: hc.surface2, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: hc.purpleTint, shape: BoxShape.circle),
                    child: const Text('👥', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.homeFriendsInviteTitle, style: quizText(15, wSemibold, hc.text)),
                        const SizedBox(height: 2),
                        Text(l10n.homeFriendsInviteSubtitle, style: quizText(13, wRegular, hc.text3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            QuizButton(label: l10n.homeFriendsInviteCta, type: QuizButtonType.dark, expand: true, onTap: onInvite),
          ] else
            GestureDetector(
              onTap: onOpenRating,
              behavior: HitTestBehavior.opaque,
              // Figma: the standings body sits in the same tinted box as the
              // no-friends invite box, so both states read as one card.
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: hc.surface2, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    _AvatarCluster(avatars: data.topAvatars),
                    const SizedBox(width: 12),
                    Expanded(child: _RankLines(data: data)),
                    const SizedBox(width: 8),
                    Text('${l10n.homeFriendsRatingLink} ›', style: quizText(14, wSemibold, hc.primary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankLines extends StatelessWidget {
  const _RankLines({required this.data});
  final FriendsRatingResponse data;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final rank = data.meRank ?? 0;
    final gap = data.nextRankGap ?? 0;

    final (String line1, String line2, Color line2Color) = data.isTie
        ? (l10n.homeFriendsYouRankTie(rank), l10n.homeFriendsTieWith(data.tieWith ?? ''), hc.text3)
        : rank <= 1
        ? (l10n.homeFriendsLeaderLine1, l10n.homeFriendsLeadAhead(2, gap), hc.success)
        : (l10n.homeFriendsYouRank(rank), l10n.homeFriendsGapToRank(rank - 1, gap), hc.text3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(line1, maxLines: 2, overflow: TextOverflow.ellipsis, style: quizText(15, wSemibold, hc.text)),
        const SizedBox(height: 2),
        Text(line2, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(13, wRegular, line2Color)),
      ],
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  const _AvatarCluster({required this.avatars});
  final List<FriendAvatar> avatars;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final palette = <(Color, Color)>[(hc.warning, hc.warningTint), (hc.purple, hc.purpleTint), (hc.teal, hc.tealTint)];
    final count = avatars.isEmpty ? 3 : math.min(avatars.length, 3);
    return SizedBox(
      width: 32 + (count - 1) * 22,
      height: 32,
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              left: i * 22,
              child: QuizInitialAvatar(
                initial: avatars.length > i && avatars[i].name.isNotEmpty
                    ? avatars[i].name.substring(0, 1).toUpperCase()
                    : '•',
                color: palette[i % palette.length].$1,
                background: palette[i % palette.length].$2,
                size: 32,
                borderColor: hc.surface,
              ),
            ),
        ],
      ),
    );
  }
}
