import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/referral_screen.dart';

abstract class ReferralScreenState extends State<ReferralScreen> {
  String get referralLink => 'https://t.me/quizlymarketbot?startapp=r';

  void onShareReferralLink() {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    final message = referralLink;
    final shareLink = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';
    context.telegramWebApp.openTelegramLink(shareLink);
  }

  void onLinkCopy() {
    Clipboard.setData(ClipboardData(text: referralLink));
    context.x.showNotification(message: 'Link copied to clipboard');
  }
}
