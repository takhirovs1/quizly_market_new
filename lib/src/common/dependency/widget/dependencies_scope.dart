import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../feature/settings/screen/settings_scope.dart';
import '../../extension/context_extension.dart';
import '../model/dependencies.dart';

class DependenciesScope extends StatelessWidget {
  const DependenciesScope({
    required this.initialization,
    required this.child,
    required this.updateAvailableScreen,
    this.splashScreen,
    this.errorBuilder,
    super.key,
  });

  static Dependencies of(BuildContext context) => context.x.inhOf<_InheritedDependencies>(listen: false).dependencies;

  final Future<Dependencies> initialization;

  final Widget child;
  final Widget? splashScreen;
  final Widget updateAvailableScreen;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  @override
  Widget build(BuildContext context) => AnnotatedRegion(
    value: SystemUiOverlayStyle(
      systemNavigationBarColor: context.x.colors.transparent,
      systemNavigationBarDividerColor: context.x.colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
    child: Material(
      color: Colors.white,
      child: FutureBuilder<Dependencies>(
        future: initialization,
        builder: (context, snapshot) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 900),
          key: const ValueKey('dependencies_scope'),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: switch ((snapshot.data, snapshot.error, snapshot.stackTrace)) {
            (final Dependencies dependencies, null, null)
                when dependencies.firebaseRemoteConfigValues.updateData.$1.isForceUpdate =>
              /// This is the update available screen, it will be shown when the app needs force update
              updateAvailableScreen,
            (final Dependencies dependencies, null, null) => _InheritedDependencies(
              dependencies: dependencies,
              child:
                  /// This scope [SettingsScope] is used to set global app settings
                  SettingsScope(child: child),
            ),
            (_, final Object error, final StackTrace? stackTrace) =>
              errorBuilder?.call(error, stackTrace) ?? ErrorWidget(error),
            _ => splashScreen ?? const SizedBox.shrink(),
          },
        ),
      ),
    ),
  );
}

class _InheritedDependencies extends InheritedWidget {
  const _InheritedDependencies({required this.dependencies, required super.child});

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant _InheritedDependencies oldWidget) => false;
}
