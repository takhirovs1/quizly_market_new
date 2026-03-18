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
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.x.colors.white,
                      side: BorderSide(color: context.x.colors.gray),
                      elevation: 0,
                      fixedSize: const Size(.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                    ),
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: 8,
                      children: [
                        Assets.lib.vectors.google.svg(package: 'ui'),
                        Text(
                          'Google bilan davom etish',
                          style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.black),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.x.colors.black,
                      elevation: 0,
                      fixedSize: const Size(.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                    ),
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: 8,
                      children: [
                        Assets.lib.vectors.apple.svg(package: 'ui', colorFilter: .mode(context.x.colors.white, .srcIn)),
                        Text(
                          'Apple ID bilan davom etish',
                          style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: context.x.colors.primary,
                      elevation: 0,
                      fixedSize: const Size(.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                    ),
                    onPressed: () {
                      context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                      context.octopus.navigate(Routes.home.name);
                    },
                    child: Row(
                      mainAxisAlignment: .center,
                      spacing: 8,
                      children: [
                        Assets.lib.images.telegramLogo.image(
                          package: 'ui',
                          width: 24,
                          height: 24,
                          color: context.x.colors.white,
                        ),
                        Text(
                          'Telegram bilan davom etish',
                          style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const .symmetric(horizontal: 32, vertical: 16),
        child: Text(
          'Davom etish orqali siz Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirasiz.',
          maxLines: 2,
          overflow: .ellipsis,
          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
          textAlign: .center,
        ),
      ),
    ),
  );
}
