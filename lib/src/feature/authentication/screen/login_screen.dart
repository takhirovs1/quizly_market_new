import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../main/widget/header_widget.dart';
import '../cubit/auth_cubit.dart';
import '../state/login_screen_state.dart';

/// {@template login_screen}
/// LoginScreen widget.
/// {@endtemplate}
class LoginScreen extends StatefulWidget {
  /// {@macro login_screen}
  const LoginScreen({
    super.key, // ignore: unused_element
  });

  @internal
  static LoginScreenState? maybeOf(BuildContext context) => context.findAncestorStateOfType<_LoginScreenState>();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends LoginScreenState {
  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) => Scaffold(
      backgroundColor: context.x.colors.white,
      body: SafeArea(
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              HeaderWidget(title: context.x.l10n.quizlyMarket, subtitle: context.x.l10n.loginTitle),
              const SizedBox(height: 24),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  spacing: 8,
                  children: [
                    SocialLoginButton(type: .google, title: context.x.l10n.loginGoogle, onPressed: signInWithGoogle),
                    SocialLoginButton(type: .apple, title: context.x.l10n.loginApple, onPressed: signInWithApple),
                    SocialLoginButton(
                      type: .telegram,
                      title: context.x.l10n.loginTelegram,
                      onPressed: signInWithTelegram,
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TermsAndPrivacyText(
        prefix: '${context.x.l10n.byContinuingYou} ',
        termsText: context.x.l10n.termsOfUse,
        middle: ' ${context.x.l10n.and} ',
        privacyText: context.x.l10n.privacyPolicy,
        suffix: ' ${context.x.l10n.agreeTo}',
        onTermsTap: () {},
        onPrivacyTap: () {},
      ),
    ),
  );
}
