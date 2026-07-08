import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
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
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state.status.isSuccess) onAuthSuccess();
      if (state.status.isError) onAuthError(state.errorMessage);
      if (state.isTelegramOtpStep) {
        context.octopus.push(Routes.verifyOtp, arguments: {'deviceId': state.telegramDeviceId ?? ''});
        cancelTelegramLogin();
      }
    },
    builder: (context, state) => Scaffold(
      backgroundColor: context.x.colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 48),
                      HeaderWidget(title: context.x.l10n.quizlyMarket, subtitle: context.x.l10n.loginTitle),
                      const SizedBox(height: 24),
                      Expanded(
                        flex: 2,
                        child: IgnorePointer(
                          ignoring: loadingType != null || state.status.isLoading,
                          child: _buildSocialLoginContent(context),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Align(alignment: Alignment.topRight, child: _buildLanguageButton(context)),
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
          onTermsTap: () => context.octopus.push(Routes.appDocuments, arguments: <String, String>{'index': '0'}),
          onPrivacyTap: () => context.octopus.push(Routes.appDocuments, arguments: <String, String>{'index': '1'}),
        ),
      ),
    ),
  );

  Widget _buildLanguageButton(BuildContext context) => GestureDetector(
    onTap: onLanguagePressed,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.x.colors.gray.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentLanguageLabel, style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.text)),
          const SizedBox(width: 4),
          ValueListenableBuilder<bool>(
            valueListenable: isLanguageSheetOpen,
            builder: (context, isOpen, _) => AnimatedRotation(
              turns: isOpen ? -0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: context.x.colors.gray),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSocialLoginContent(BuildContext context) => Column(
    key: const ValueKey('social'),
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SocialLoginButton(
        type: SocialLoginType.google,
        title: context.x.l10n.loginGoogle,
        onPressed: signInWithGoogle,
        isLoading: loadingType == SocialLoginType.google,
      ),
      const SizedBox(height: 8),
      if (PlatformInfo.showAppleSignIn) ...[
        SocialLoginButton(
          type: SocialLoginType.apple,
          title: context.x.l10n.loginApple,
          onPressed: signInWithApple,
          isLoading: loadingType == SocialLoginType.apple,
        ),
        const SizedBox(height: 8),
      ],
      SocialLoginButton(
        type: SocialLoginType.telegram,
        title: context.x.l10n.loginTelegram,
        onPressed: signInWithTelegram,
        isLoading: loadingType == SocialLoginType.telegram,
      ),
    ],
  );
}
