import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../feature/authentication/cubit/auth_cubit.dart';
import '../../feature/authentication/screen/login_screen.dart';
import '../../feature/home/screen/home_screen.dart';
import '../../feature/main/screen/onboarding_screen.dart';
import '../../feature/main/screen/select_language.dart';
import '../../feature/my_tests/screen/purchase_test_screen.dart';
import '../../feature/profile/screen/payment_history_screen.dart';
import '../../feature/profile/screen/payment_screen.dart';
import '../../feature/profile/screen/referral_screen.dart';
import '../../feature/recommendation/screen/more_recommendation_screen.dart';
import '../../feature/tests/screens/test_custom_mode_screen.dart';
import '../../feature/tests/screens/test_flashcard_mode.dart';
import '../../feature/tests/screens/test_group_mode_screen.dart';
import '../../feature/tests/screens/test_mode_screen.dart';
import '../../feature/tests/screens/test_university_mode_screen.dart';
import '../extension/context_extension.dart';

enum Routes with OctopusRoute {
  login('login', title: 'Login'),
  home('home', title: 'Home'),
  onboarding('onboarding', title: 'Onboarding'),
  selectLanguage('selectLanguage', title: 'Select Language'),
  moreRecommendation('moreRecommendation', title: 'More Recommendation'),
  purchaseTest('purchaseTest', title: 'PurchaseTest'),
  payment('payment', title: 'Payment'),
  referral('referral', title: 'Referral'),
  paymentHistory('paymentHistory', title: 'Payment History'),
  testMode('testMode', title: 'Test Mode'),
  testCustomMode('testCustomMode', title: 'Test Custom Mode'),
  testUniversityMode('testUniversityMode', title: 'Test University Mode'),
  testGroupMode('testGroupMode', title: 'Test Group Mode'),
  testFlashcardMode('testFlashcardMode', title: 'Test Flashcard Mode');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    .login => BlocProvider(
      create: (_) => AuthCubit(authenticationRepository: context.x.dependencies.repository.authenticationRepository),
      child: const LoginScreen(),
    ),
    .home => const HomeScreen(),
    .onboarding => const OnboardingScreen(),
    .selectLanguage => const SelectLanguage(),
    .moreRecommendation => const MoreRecommendationScreen(),
    .purchaseTest => const PurchaseTestScreen(),
    .payment => const PaymentScreen(),
    .referral => const ReferralScreen(),
    .paymentHistory => const PaymentHistoryScreen(),
    .testMode => const TestModeScreen(),
    .testCustomMode => const TestCustomModeScreen(),
    .testUniversityMode => const TestUniversityModeScreen(),
    .testGroupMode => const TestGroupModeScreen(),
    .testFlashcardMode => const TestFlashcardMode(),
  };
}
