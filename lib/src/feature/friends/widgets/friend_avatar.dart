import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friend_user_model.dart';

/// Avatar for a [FriendUser] — the image when present, else a solid tile in the
/// server-provided fallback [FriendUser.color] with the name initial
/// (backend_integration.md §4).
class FriendAvatar extends StatelessWidget {
  const FriendAvatar({required this.user, this.size = 44, super.key});

  final FriendUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final accent = colorFromHex(user.color, fallback: hc.purple);
    return QuizInitialAvatar(
      initial: user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?',
      color: accent,
      background: accent.withValues(alpha: 0.15),
      size: size,
      borderColor: hc.surface,
    );
  }
}
