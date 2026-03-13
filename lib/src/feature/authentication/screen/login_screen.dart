import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../common/extension/context_extension.dart';

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
    backgroundColor: context.x.colors.buttonBorder,
    body: const Center(child: Text('Login')),
  );
}
