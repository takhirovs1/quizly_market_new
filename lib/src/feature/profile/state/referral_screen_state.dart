import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/profile_cubit.dart';
import '../screen/referral_screen.dart';

abstract class ReferralScreenState extends State<ReferralScreen> {
  late final ProfileCubit cubit;

  String get referralLink => 'https://t.me/prjkttest_bot?startapp=r${cubit.state.user?.referralCode}';

  Future<void> onShareReferralLink() async {
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.hapticImpact(.light);
    } else {
      HapticFeedback.lightImpact();
    }
    final message = '${context.x.l10n.shareTextMessage}$referralLink';
    final shareLink = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';

    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.openTelegramLink(shareLink);
    } else {
      final uri = Uri.parse(shareLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: .externalApplication);
      }
    }
  }

  void onLinkCopy() {
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.hapticImpact(.light);
    } else {
      HapticFeedback.lightImpact();
    }
    final message = '${context.x.l10n.shareTextMessage}$referralLink';
    Clipboard.setData(ClipboardData(text: message));
    context.x.showNotification(
      message: context.x.l10n.linkCopied,
      top: switch (context.telegramWebApp.isSupported) {
        true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
        false => MediaQuery.paddingOf(context).top + 56,
      },
    );
  }

  @override
  void initState() {
    cubit = context.read<ProfileCubit>()..loadProfile();
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    super.dispose();
    context.teardownTelegramBackButton();
  }
}
