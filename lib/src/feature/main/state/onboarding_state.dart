import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/main_cubit.dart';
import '../model/login_with_telegram.dart';
import '../screen/onboarding_screen.dart';

abstract class OnboardingState extends State<OnboardingScreen> {
  late final MainCubit mainCubit;

  Future<void> onStartApp() async {
    final tg = context.telegramWebApp;
    // Prefer initDataUnsafe: works with local web simulator (see web/telegram_web_app_simulator.js).
    // initData (signed string) is for server validation; parsing throws if `user` is missing in the query string.
    final user = tg.initDataUnsafe?.user;
    log('Telegram user (id): ${user?.id}');
    log('Telegram user (username): ${user?.username}');
    log('Telegram user (language code): ${user?.languageCode}');
    log('Telegram user (is premium): ${user?.isPremium}');
    log('Telegram user (photo url): ${user?.photoUrl}');
    log('Telegram user (allows write to pm): ${user?.allowedToWritePm}');
    log('Telegram user (added to attachment menu): ${user?.addedToAttachmentMenu}');
    log('Telegram user (is bot): ${user?.isBot}');
    log('Telegram user (is premium): ${user?.isPremium}');
    log('Telegram user (photo url): ${user?.photoUrl}');
    log('Telegram user (added to attachment menu): ${user?.addedToAttachmentMenu}');

    context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
    context.octopus.navigate(Routes.home.name);
  }

  @override
  void initState() {
    final tg = context.telegramWebApp;
    mainCubit = context.read<MainCubit>()..signInWithTelegram(LoginWithTelegramRequest(initData: tg.initData.raw));
    super.initState();
  }
}
