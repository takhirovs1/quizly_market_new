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
      defaultRoute: context.telegramWebApp.isSupported ? Routes.splash : Routes.selectLanguage,
      // guards: <OctopusGuard>[guards],
    );

    // ignore: invalid_use_of_internal_member
    authenticationNavigator = Octopus(routes: Routes.values, defaultRoute: Routes.home, guards: <OctopusGuard>[guards]);
  }

  // #endregion lifecycle
}
