part of 'app.dart';

/// State for widget App.
abstract class AppState extends State<App> with AppRouteInitialization, AppDebugConfigInitialization {
  final GlobalKey<State<StatefulWidget>> _appKey = GlobalKey<State<StatefulWidget>>();

  late final OverlayEntry _scopes = OverlayEntry(
    builder: (context) {
      final locale = SettingsScope.settingsOf(context).localization;
      return AuthenticationScope(
        authenticationScreens: MaterialApp.router(
          routerConfig: authenticationNavigator.config,
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalization.delegate,
          ],
          supportedLocales: AppLocalization.supportedLocales,
          locale: locale,
        ),
        child: MaterialApp.router(
          routerConfig: navigator.config,
          localizationsDelegates: const <LocalizationsDelegate<Object?>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalization.delegate,
          ],
          supportedLocales: AppLocalization.supportedLocales,
          locale: locale,
        ),
      );
    },
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
