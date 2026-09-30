import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import '../../../common/extension/context_extension.dart';
import '../cubit/auth_cubit.dart';
import '../screen/session_screen.dart';

abstract class SessionState extends State<SessionScreen> {
  late final AuthCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<AuthCubit>()..loadSessions();
  }

  void onRevoke(String sessionId) {
    cubit.revokeSession(sessionId).then((success) {
      if (success) {
        if (mounted) {
          context.x.showNotification(message: context.x.l10n.sessionRevoked);
          context.octopus.navigate('home');
        }
      }
    });
  }

  void onBack() {
    context.x.dependencies.authenticationController.signOut();
    context.octopus.navigate('login');
  }
}
