part of 'app.dart';

/// State for widget App.
abstract class AppState extends State<App> with AppRouteInitialization, AppDebugConfigInitialization {
  final GlobalKey<State<StatefulWidget>> _appKey = GlobalKey<State<StatefulWidget>>();

  late final OverlayEntry _scopes = OverlayEntry(
    builder: (context) => AuthenticationScope(
      authenticationScreens: MaterialApp.router(routerConfig: authenticationNavigator.config),
      child: MaterialApp.router(routerConfig: navigator.config),
    ),
  );

  // #region lifecycle
  // initState works -> AppRouteInitialization -> AppDebugConfigInitialization -> AppState
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 1), _appSettingsListener).ignore();
  }

  // #endregion lifecycle
}
