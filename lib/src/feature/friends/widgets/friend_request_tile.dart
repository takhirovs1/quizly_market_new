import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friend_requests_model.dart';
import 'friend_avatar.dart';

/// An incoming friend request with Accept / Reject actions. Used in the
/// "So'rovlar" section.
class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile({required this.item, required this.onAccept, required this.onReject, super.key});

  final FriendRequestItem item;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(16), boxShadow: [hc.softShadow]),
      child: Row(
        children: [
          FriendAvatar(user: item.user, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: quizText(15, wSemibold, hc.text),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.friendsWantsToConnect,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: quizText(12, wRegular, hc.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuizButton(label: l10n.friendsAccept, type: QuizButtonType.primary, size: QuizButtonSize.s, onTap: onAccept),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onReject,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hc.surface,
                shape: BoxShape.circle,
                border: Border.all(color: hc.border),
              ),
              child: Icon(Icons.close_rounded, size: 18, color: hc.text3),
            ),
          ),
        ],
      ),
    );
  }
}
