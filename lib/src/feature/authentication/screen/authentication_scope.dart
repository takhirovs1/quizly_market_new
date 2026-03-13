import 'package:ui/ui.dart';

import '../../../common/dependency/widget/dependencies_scope.dart';
import '../../../common/extension/context_extension.dart';
import '../controller/authentication_controller.dart';
import '../model/user.dart';

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({required this.child, required this.authenticationScreens, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// The widget to show when the user is not authenticated.
  final Widget authenticationScreens;

  /// Get the current [User]
  static User userOf(BuildContext context, {bool listen = true}) =>
      context.x.dependencies.authenticationController.state.user;

  /// Get the current [AuthenticationController]
  static AuthenticationController controllerOf(BuildContext context) => context.x.dependencies.authenticationController;

  static void restore(BuildContext context) => context.x.dependencies.authenticationController.restore();

  /// Sign-Out
  static void signOut(BuildContext context) => context.x.dependencies.authenticationController.signOut();

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  late final AuthenticationController controller;

  @override
  void initState() {
    super.initState();
    controller = DependenciesScope.of(context).authenticationController;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, child) => AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: controller.state.user.isAuthenticated ? widget.authenticationScreens : widget.child,
    ),
  );
}
