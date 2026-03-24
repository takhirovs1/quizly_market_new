import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';

import '../../../common/router/pages.dart';
import '../cubit/auth_cubit.dart';
import '../screen/login_screen.dart';

abstract class LoginScreenState extends State<LoginScreen> {
  late final AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
  }

  Future<void> signInWithGoogle() async {
    await authCubit.signInWithGoogle();
  }

  Future<void> signInWithApple() async {
    context.octopus.navigate(Routes.home.name);
    // await authCubit.signInWithApple();
  }

  Future<void> signInWithTelegram() async {
    await authCubit.signInWithTelegram();
  }

  @override
  void dispose() {
    authCubit.close();
    super.dispose();
  }
}
