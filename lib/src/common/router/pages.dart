import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../feature/authentication/cubit/auth_cubit.dart';
import '../../feature/authentication/screen/login_screen.dart';
import '../../feature/home/screen/home_screen.dart';
import '../../feature/main/bloc/main_cubit.dart';
import '../../feature/main/screen/onboarding_screen.dart';
import '../../feature/main/screen/select_language.dart';
import '../../feature/my_tests/bloc/my_test_cubit.dart';
import '../../feature/my_tests/screen/purchase_test_screen.dart';
import '../../feature/profile/bloc/profile_cubit.dart';
import '../../feature/profile/screen/app_info_screen.dart';
import '../../feature/profile/screen/payment_history_screen.dart';
import '../../feature/profile/screen/payment_screen.dart';
import '../../feature/profile/screen/referral_screen.dart';
import '../../feature/recommendation/screen/more_recommendation_screen.dart';
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
  appInfo('appInfo', title: 'App Info');

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
    .home => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyTestCubit(myTestRepository: context.x.dependencies.repository.myTestRepository)),
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository),
        ),
      ],
      child: const HomeScreen(),
    ),
    .onboarding => BlocProvider(
      create: (_) => MainCubit(
        mainRepository: context.x.dependencies.repository.mainRepository,
        localSource: context.x.dependencies.localSource,
      ),
      child: const OnboardingScreen(),
    ),
    .selectLanguage => const SelectLanguage(),
    .moreRecommendation => const MoreRecommendationScreen(),
    .purchaseTest => const PurchaseTestScreen(),
    .payment => const PaymentScreen(),
    .referral => const ReferralScreen(),
    .paymentHistory => const PaymentHistoryScreen(),
    .appInfo => const AppInfoScreen(),
  };
}
