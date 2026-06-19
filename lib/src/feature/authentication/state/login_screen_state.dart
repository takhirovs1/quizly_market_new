import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../cubit/auth_cubit.dart';
import '../screen/login_screen.dart';

abstract class LoginScreenState extends State<LoginScreen> {
  late final AuthCubit authCubit;
  late final TextEditingController pinController;
  late final FocusNode pinFocusNode;

  SocialLoginType? loadingType;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    pinController = TextEditingController();
    pinFocusNode = FocusNode();
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
      if (mounted) pinFocusNode.requestFocus();
    } finally {
      if (mounted) setState(() => loadingType = null);
    }
  }

  Future<void> verifyTelegramOtp(String code) => authCubit.verifyTelegramOtp(code);

  Future<void> cancelTelegramLogin() async {
    pinController.clear();
    await authCubit.cancelTelegramLogin();
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
    pinController.dispose();
    pinFocusNode.dispose();
    authCubit.close();
    super.dispose();
  }
}
