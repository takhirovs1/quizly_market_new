import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../feature/authentication/screen/login_screen.dart';
import '../../feature/home/screen/home_screen.dart';
import '../../feature/main/screen/onboarding_screen.dart';
import '../../feature/my_tests/screen/purchase_test_screen.dart';
import '../../feature/recommendation/screen/more_recommendation_screen.dart';

enum Routes with OctopusRoute {
  login('login', title: 'Login'),
  home('home', title: 'Home'),
  onboarding('onboarding', title: 'Onboarding'),
  moreRecommendation('moreRecommendation', title: 'More Recommendation'),
  purchaseTest('purchaseTest', title: 'PurchaseTest');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    .login => const LoginScreen(),
    .home => const HomeScreen(),
    .onboarding => const OnboardingScreen(),
    .moreRecommendation => const MoreRecommendationScreen(),
    .purchaseTest => const PurchaseTestScreen(),
  };
}
