part of 'app.dart';

/// Route initialization mixin
mixin AppRouteInitialization on State<App> {
  late OctopusGuard authGuard;
  late OctopusGuard guards;

  late final Octopus navigator;
  late final Octopus authenticationNavigator;

  // #region lifecycle
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      final isTelegram = context.telegramWebApp.isSupported;
      if (!isTelegram) {
        final uri = Uri.base;
        final hasFragmentRoute =
            uri.fragment.isNotEmpty && Routes.values.any((route) => uri.fragment.contains(route.name));
        final hasPathRoute =
            uri.path.isNotEmpty && uri.path != '/' && Routes.values.any((route) => uri.path.contains(route.name));

        if (!hasFragmentRoute && !hasPathRoute) {
          url_launcher
              .launchUrl(
                Uri.parse('/landing/'),
                mode: url_launcher.LaunchMode.platformDefault,
                webOnlyWindowName: '_self',
              )
              .ignore();
        }
      }
    }

    authGuard = AuthenticationGuard(
      getUser: () => context.x.dependencies.authenticationController.state.user,
      routes: <String>{Routes.login.name},
      signinNavigation: .fromLocation(Routes.login.name),
      homeNavigation: .fromLocation(Routes.home.name),
    );

    guards = MainGuard();

    // ignore: invalid_use_of_internal_member
    navigator = Octopus(
      routes: Routes.values,
      defaultRoute: context.telegramWebApp.isSupported ? Routes.splash : Routes.login,
      // guards: <OctopusGuard>[guards],
    );

    // ignore: invalid_use_of_internal_member
    authenticationNavigator = Octopus(routes: Routes.values, defaultRoute: Routes.home, guards: <OctopusGuard>[guards]);
    authNavigatorInstance = authenticationNavigator;
  }

  // #endregion lifecycle
}
