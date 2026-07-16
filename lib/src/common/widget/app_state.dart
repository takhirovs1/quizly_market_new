part of 'app.dart';

/// State for widget App.
abstract class AppState extends State<App> with AppRouteInitialization, AppDebugConfigInitialization {
  final GlobalKey<State<StatefulWidget>> _appKey = GlobalKey<State<StatefulWidget>>();

  late final OverlayEntry _scopes = OverlayEntry(
    builder: (context) {
      final locale = SettingsScope.settingsOf(context).localization;
      final themeMode = SettingsScope.settingsOf(context, listen: true).themeMode;
      return AuthenticationScope(
        authenticationScreens: MaterialApp.router(
          routerConfig: authenticationNavigator.config,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalization.supportedLocales,
          localeResolutionCallback: appLocaleResolution,
          locale: locale,
          themeMode: themeMode,
          darkTheme: AppThemeData.dark(),
          theme: AppThemeData.light(),
        ),
        child: MaterialApp.router(
          routerConfig: navigator.config,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalization.supportedLocales,
          localeResolutionCallback: appLocaleResolution,
          locale: locale,
          themeMode: themeMode,
          darkTheme: AppThemeData.dark(),
          theme: AppThemeData.light(),
        ),
      );
    },
  );

  AuthenticationController? _authController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authController = context.x.dependencies.authenticationController;
    if (_authController != authController) {
      _authController?.removeListener(_onAuthStateChanged);
      _authController = authController..addListener(_onAuthStateChanged);
    }
  }

  void _onAuthStateChanged() {
    final user = _authController?.state.user;
    if (user != null && !user.isAuthenticated) {
      navigator.setState(
        (s) => s
          ..clear()
          ..add(OctopusNode(name: Routes.login.name, arguments: const {}, children: const [])),
      );
    }
  }

  // #region lifecycle
  // initState works -> AppRouteInitialization -> AppDebugConfigInitialization -> AppState
  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 1), _appSettingsListener).ignore();
  }

  @override
  void dispose() {
    _authController?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  // #endregion lifecycle
}
