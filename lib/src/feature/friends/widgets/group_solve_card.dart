import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../models/friends_group_model.dart';

/// "Birga yechish" (solve together) entry. Group live-solve runs over a
/// websocket and is a separate task; while [FriendsGroupsResponse.comingSoon] is
/// true this shows a disabled "Tez kunda" state instead of faking real-time.
// TODO(groups): wire live sessions when the websocket group endpoint ships —
//   create/join a session, show participants, start a synced solve.
class GroupSolveCard extends StatelessWidget {
  const GroupSolveCard({required this.data, super.key});

  final FriendsGroupsResponse data;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final comingSoon = data.comingSoon || data.active.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow]),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: hc.purpleTint, borderRadius: BorderRadius.circular(16)),
            child: const Text('👥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.friendsGroupsTitle, style: quizText(15, wSemibold, hc.text)),
                const SizedBox(height: 3),
                Text(l10n.friendsGroupsDesc, style: quizText(12, wRegular, hc.text3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (comingSoon)
            QuizPill(text: l10n.comingSoon, background: hc.warningTint, foreground: hc.orangeAccent)
          else
            QuizButton(
              label: l10n.friendsGroupStart,
              type: QuizButtonType.primary,
              size: QuizButtonSize.s,
              onTap: () {},
            ),
        ],
      ),
    );
  }
}
