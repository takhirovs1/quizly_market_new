import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

/// Top banner on the Friends screen — referral is how friends join by default,
/// so sharing the link is the primary "add a friend" path. [onShare] opens the
/// system/Telegram share with the referral deep link.
class FriendsInviteBanner extends StatelessWidget {
  const FriendsInviteBanner({required this.onShare, super.key});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: hc.heroGradient, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: hc.onAccent.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: const Text('🎁', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.friendsInviteBannerTitle, style: quizText(15, wBold, hc.onAccent)),
                const SizedBox(height: 2),
                Text(
                  l10n.friendsInviteBannerSubtitle,
                  style: quizText(12, wRegular, hc.onAccent.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          QuizButton(
            label: l10n.homeReferralShareCta,
            type: QuizButtonType.light,
            size: QuizButtonSize.s,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}
