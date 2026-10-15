import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friends_leaderboard_model.dart';
import 'friend_avatar.dart';

/// One weekly-leaderboard row. The current user's row is tinted and bold.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({required this.entry, super.key});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final isMe = entry.isMe;
    final medal = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? hc.primaryTint : hc.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isMe ? null : [hc.softShadow],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center)
                : Text('${entry.rank}', textAlign: TextAlign.center, style: quizText(14, wBold, hc.text3)),
          ),
          const SizedBox(width: 6),
          FriendAvatar(user: entry.user, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isMe ? l10n.friendsYou : entry.user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: quizText(15, isMe ? wBold : wSemibold, hc.text),
            ),
          ),
          const SizedBox(width: 8),
          Text(l10n.friendsXpValue(entry.xp), style: quizText(14, wBold, isMe ? hc.primary : hc.text2)),
        ],
      ),
    );
  }
}
