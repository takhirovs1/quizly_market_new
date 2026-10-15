import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friend_user_model.dart';
import '../models/friends_discovery_model.dart';
import 'friend_avatar.dart';

/// A discoverable person in search / suggestions. The trailing action depends on
/// my [FriendSuggestion.relation]: add · pending · accept · already-friend.
class FriendSearchTile extends StatelessWidget {
  const FriendSearchTile({required this.suggestion, required this.onAdd, super.key});

  final FriendSuggestion suggestion;

  /// Called to send a friend request (only meaningful when relation is `none`).
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final user = suggestion.user;
    final subtitle = switch (suggestion.reason) {
      'shared_test' => l10n.friendsReasonSharedTest,
      _ => user.username != null && user.username!.isNotEmpty ? '@${user.username}' : l10n.friendsXpValue(user.xp),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hc.border),
      ),
      child: Row(
        children: [
          FriendAvatar(user: user, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(15, wSemibold, hc.text)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(12, wRegular, hc.text3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _trailing(context),
        ],
      ),
    );
  }

  Widget _trailing(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return switch (suggestion.relation) {
      FriendRelation.none => QuizButton(
        label: l10n.friendsActionAdd,
        type: QuizButtonType.primary,
        size: QuizButtonSize.s,
        leadingLottie: QuizLottie.addFriends,
        onTap: onAdd,
      ),
      FriendRelation.requested => QuizPill(
        text: l10n.friendsActionPending,
        background: hc.surface2,
        foreground: hc.text3,
      ),
      FriendRelation.incoming => QuizPill(
        text: l10n.friendsActionIncoming,
        background: hc.primaryTint,
        foreground: hc.primary,
      ),
      FriendRelation.friend => QuizPill(
        text: l10n.friendsActionFriends,
        background: hc.successTint,
        foreground: hc.success,
      ),
    };
  }
}
