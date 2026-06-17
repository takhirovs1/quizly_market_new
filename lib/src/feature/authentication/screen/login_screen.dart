import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/platform_info.dart';
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
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status.isSuccess) onAuthSuccess();
      if (state.status.isError) onAuthError(state.errorMessage);
    },
    child: Scaffold(
      backgroundColor: context.x.colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SafeArea(
            child: Padding(
              padding: const .all(24),
              child: Column(
                children: [
                  HeaderWidget(title: context.x.l10n.quizlyMarket, subtitle: context.x.l10n.loginTitle),
                  const SizedBox(height: 24),
                  Expanded(
                    flex: 2,
                    child: IgnorePointer(
                      ignoring: loadingType != null,
                      child: Column(
                        crossAxisAlignment: .center,
                        mainAxisAlignment: .center,
                        children: [
                          SocialLoginButton(
                            type: .google,
                            title: context.x.l10n.loginGoogle,
                            onPressed: signInWithGoogle,
                            isLoading: loadingType == .google,
                          ),
                          const SizedBox(height: 8),
                          if (PlatformInfo.showAppleSignIn) ...[
                            SocialLoginButton(
                              type: .apple,
                              title: context.x.l10n.loginApple,
                              onPressed: signInWithApple,
                              isLoading: loadingType == .apple,
                            ),
                            const SizedBox(height: 8),
                          ],
                          SocialLoginButton(
                            type: .telegram,
                            title: context.x.l10n.loginTelegram,
                            onPressed: signInWithTelegram,
                            isLoading: loadingType == .telegram,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: TermsAndPrivacyText(
          prefix: '${context.x.l10n.byContinuingYou} ',
          termsText: context.x.l10n.termsOfUse,
          middle: ' ${context.x.l10n.and} ',
          privacyText: context.x.l10n.privacyPolicy,
          suffix: ' ${context.x.l10n.agreeTo}',
          onTermsTap: () {},
          onPrivacyTap: () {},
        ),
      ),
    ),
  );
}
