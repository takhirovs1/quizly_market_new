import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../cubit/auth_cubit.dart';
import '../screen/login_screen.dart';

abstract class LoginScreenState extends State<LoginScreen> {
  late final AuthCubit authCubit;

  SocialLoginType? loadingType;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
  }

  Future<void> signInWithGoogle() async {
    setState(() => loadingType = .google);
    try {
      await authCubit.signInWithGoogle();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> signInWithApple() async {
    setState(() => loadingType = .apple);
    try {
      await authCubit.signInWithApple();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> signInWithTelegram() async {
    setState(() => loadingType = .telegram);
    try {
      await authCubit.signInWithTelegram();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  void onAuthSuccess() => context.octopus.navigate(Routes.home.name);

  void onAuthError(String? errorMessage) => context.x.showNotification(
    message: context.x.l10n.somethingWentWrong,
    isError: true,
    top: switch (context.telegramWebApp.isSupported) {
      true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
      false => MediaQuery.paddingOf(context).top + 56,
    },
  );

  @override
  void dispose() {
    authCubit.close();
    super.dispose();
  }
}
