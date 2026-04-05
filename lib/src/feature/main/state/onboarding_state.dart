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
    if (!context.x.dependencies.localSource.isUserAuthenticated) return;
    await context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
    if (!mounted) return;
    context.octopus.navigate(Routes.home.name);
  }

  @override
  void initState() {
    final tg = context.telegramWebApp;
    mainCubit = context.read<MainCubit>()..signInWithTelegram(LoginWithTelegramRequest(initData: tg.initData.raw));
    super.initState();
  }
}
