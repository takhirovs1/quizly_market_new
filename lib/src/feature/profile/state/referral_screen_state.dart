import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../bloc/profile_cubit.dart';
import '../screen/referral_screen.dart';

abstract class ReferralScreenState extends State<ReferralScreen> {
  late final ProfileCubit cubit;

  String get referralLink => '${Constant.miniAppUrl}?startapp=r${cubit.state.user?.referralCode}';

  Future<void> onShareReferralLink() async {
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.hapticImpact(.light);
    } else {
      HapticFeedback.lightImpact();
    }
    final message = '${context.x.l10n.shareTextMessage}$referralLink';

    if (context.telegramWebApp.isSupported) {
      final shareLink = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';
      context.telegramWebApp.openTelegramLink(shareLink);
    } else {
      // ignore: deprecated_member_use
      await Share.share(message);
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
    cubit = context.read<ProfileCubit>()
      ..loadProfile()
      ..getReferralSummary()
      ..getReferrals();
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    super.dispose();
    context.teardownTelegramBackButton();
  }
}
