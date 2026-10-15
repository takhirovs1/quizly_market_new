import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friend_user_model.dart';
import 'friend_avatar.dart';

/// One confirmed friend: avatar, name, XP, and a remove action.
class FriendTile extends StatelessWidget {
  const FriendTile({required this.user, required this.onRemove, super.key});

  final FriendUser user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(16), boxShadow: [hc.softShadow]),
      child: Row(
        children: [
          FriendAvatar(user: user, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(15, wSemibold, hc.text)),
                const SizedBox(height: 2),
                Text(l10n.friendsXpValue(user.xp), style: quizText(13, wRegular, hc.text3)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.more_horiz_rounded, size: 22, color: hc.text3),
            ),
          ),
        ],
      ),
    );
  }
}
