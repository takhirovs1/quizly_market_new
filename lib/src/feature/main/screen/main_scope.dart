import 'package:ui/ui.dart';

import '../../home/screen/home_screen.dart';

/// {@template main_scope}
/// MainScope widget.
/// {@endtemplate}
class MainScope extends StatefulWidget {
  /// {@macro main_scope}
  const MainScope({
    super.key, // ignore: unused_element
  });

  /// The widget below this widget in the tree.

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// For example: `MainScope.maybeOf(context)`.
  static MainScopeState? maybeOf(BuildContext context, {bool listen = true}) =>
      (listen
              ? context.dependOnInheritedWidgetOfExactType<_InheritedMainScope>()
              : context.getInheritedWidgetOfExactType<_InheritedMainScope>())
          ?.state;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedMainScope of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `MainScope.of(context)`.
  static MainScopeState of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  @override
  State<MainScope> createState() => _MainScopeState();
}

/// State for widget MainScope.
abstract class MainScopeState extends State<MainScope> {
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

class _MainScopeState extends MainScopeState {
  @override
  Widget build(BuildContext context) => _InheritedMainScope(state: this, child: const HomeScreen());
}

/// Inherited widget for quick access in the element tree.
class _InheritedMainScope extends InheritedWidget {
  const _InheritedMainScope({required this.state, required super.child});

  final _MainScopeState state;

  @override
  bool updateShouldNotify(covariant _InheritedMainScope oldWidget) => false;
}
