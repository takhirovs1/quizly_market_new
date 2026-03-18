import 'package:meta/meta.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../main/widget/header_widget.dart';

/// {@template login_screen}
/// LoginScreen widget.
/// {@endtemplate}
class LoginScreen extends StatefulWidget {
  /// {@macro login_screen}
  const LoginScreen({
    super.key, // ignore: unused_element
  });

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  @internal
  static LoginScreenState? maybeOf(BuildContext context) => context.findAncestorStateOfType<_LoginScreenState>();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State for widget LoginScreen.
abstract class LoginScreenState extends State<LoginScreen> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }

  /* #endregion */
}

class _LoginScreenState extends LoginScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.white,
    body: SafeArea(
      child: Padding(
        padding: const .all(16),
        child: Column(
          children: [
            HeaderWidget(
              title: context.x.l10n.quizlyMarket,
              subtitle: 'QuizlyMarket platformasidan foydalanish uchun ilovaga kirishingiz kerak',
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                spacing: 8,
                children: [
                  SocialLoginButton(
                    type: .google,
                    title: 'Google bilan davom etish',
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                  ),
                  SocialLoginButton(
                    type: .apple,
                    title: 'Apple ID bilan davom etish',
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                  ),
                  SocialLoginButton(
                    type: .telegram,
                    title: 'Telegram bilan davom etish',
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: const TermsAndPrivacyText(
      title: 'Davom etish orqali siz Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirasiz.',
    ),
  );
}
