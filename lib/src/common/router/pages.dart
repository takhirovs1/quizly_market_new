import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../feature/authentication/cubit/auth_cubit.dart';
import '../../feature/authentication/screen/login_screen.dart';
import '../../feature/authentication/screen/session_screen.dart';
import '../../feature/authentication/screen/verify_otp_screen.dart';
import '../../feature/home/screen/home_screen.dart';
import '../../feature/main/bloc/main_cubit.dart';
import '../../feature/my_tests/bloc/my_test_cubit.dart';
import '../../feature/my_tests/screen/purchase_test_screen.dart';
import '../../feature/profile/bloc/profile_cubit.dart';
import '../../feature/profile/bloc/support_chat_cubit.dart';
import '../../feature/profile/data/support_chat_repository.dart';
import '../../feature/profile/screen/app_documents_screen.dart';
import '../../feature/profile/screen/edit_profile_screen.dart';
import '../../feature/profile/screen/app_info_screen.dart';
import '../../feature/profile/screen/archive_screen.dart';
import '../../feature/profile/screen/payment_history_screen.dart';
import '../../feature/profile/screen/payment_screen.dart';
import '../../feature/profile/screen/referral_screen.dart';
import '../../feature/profile/screen/support_chat_screen.dart';
import '../../feature/recommendation/bloc/recommendation_cubit.dart';
import '../../feature/recommendation/data/recommendation_repository.dart';
import '../../feature/recommendation/screen/more_recommendation_screen.dart';
import '../../feature/tests/bloc/test_view.dart';
import '../../feature/tests/data/test_view_repository.dart';
import '../../feature/tests/model/test_request_response_models.dart';
import '../../feature/tests/model/test_route_arguments.dart';
import '../../feature/tests/screens/test_custom_mode_screen.dart';
import '../../feature/tests/screens/test_flashcard_mode.dart';
import '../../feature/tests/screens/test_group_mode_screen.dart';
import '../../feature/tests/screens/test_mode_screen.dart';
import '../../feature/tests/screens/test_result_screen.dart';
import '../../feature/tests/screens/test_solving_screen.dart';
import '../../feature/tests/screens/test_university_mode_screen.dart';
import '../dependency/widget/splash_screen.dart';
import '../extension/context_extension.dart';
import '../util/logger.dart' as log_util;

enum Routes with OctopusRoute {
  login('login', title: 'Login'),
  verifyOtp('verifyOtp', title: 'Verify OTP'),
  home('home', title: 'Home'),
  splash('splash', title: 'Splash'),
  moreRecommendation('moreRecommendation', title: 'More Recommendation'),
  purchaseTest('purchaseTest', title: 'PurchaseTest'),
  payment('payment', title: 'Payment'),
  referral('referral', title: 'Referral'),
  appInfo('appInfo', title: 'App Info'),
  paymentHistory('paymentHistory', title: 'Payment History'),
  appDocuments('appDocuments', title: 'App Documents'),
  testMode('testMode', title: 'Test Mode'),
  testCustomMode('testCustomMode', title: 'Test Custom Mode'),
  testUniversityMode('testUniversityMode', title: 'Test University Mode'),
  testGroupMode('testGroupMode', title: 'Test Group Mode'),
  testFlashcardMode('testFlashcardMode', title: 'Test Flashcard Mode'),
  testResult('testResult', title: 'Test Result'),
  supportChat('supportChat', title: 'Support Chat'),
  testSolving('testSolving', title: 'Test Solving'),
  archive('archive', title: 'Archive'),
  session('session', title: 'Sessions'),
  editProfile('editProfile', title: 'Edit Profile');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    Routes.login => BlocProvider(
      create: (_) => AuthCubit(authenticationRepository: context.x.dependencies.repository.authenticationRepository),
      child: const LoginScreen(),
    ),
    Routes.verifyOtp => BlocProvider(
      create: (_) => AuthCubit(
        authenticationRepository: context.x.dependencies.repository.authenticationRepository,
        telegramDeviceId: node.arguments['deviceId'],
      ),
      child: const VerifyOtpScreen(),
    ),
    Routes.home => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MyTestCubit(myTestRepository: context.x.dependencies.repository.myTestRepository)),
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository),
        ),
        BlocProvider(
          create: (context) => RecommendationCubit(
            recommendationRepository: RecommendationRepositoryImpl(apiClient: context.x.dependencies.apiClient),
          ),
        ),
      ],
      child: HomeScreen(initialTab: int.tryParse(node.arguments['tab'] ?? '') ?? 0),
    ),
    .splash => BlocProvider(
      create: (_) => MainCubit(
        mainRepository: context.x.dependencies.repository.mainRepository,
        localSource: context.x.dependencies.localSource,
      ),
      child: const SplashRouteWrapper(),
    ),
    .moreRecommendation => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MyTestCubit(myTestRepository: context.x.dependencies.repository.myTestRepository),
        ),
        BlocProvider(
          create: (context) => RecommendationCubit(
            recommendationRepository: RecommendationRepositoryImpl(apiClient: context.x.dependencies.apiClient),
          ),
        ),
      ],
      child: MoreRecommendationScreen(
        type: TestCategoryType.values.byName(node.arguments['type'] ?? TestCategoryType.topTests.name),
      ),
    ),
    .purchaseTest => BlocProvider(
      create: (context) => MyTestCubit(myTestRepository: context.x.dependencies.repository.myTestRepository),
      child: PurchaseTestScreen(testId: node.arguments['id'] ?? ''),
    ),
    .payment => BlocProvider(
      create: (context) => ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository),
      child: const PaymentScreen(),
    ),
    .referral => BlocProvider(
      create: (context) => ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository),
      child: const ReferralScreen(),
    ),
    .paymentHistory => BlocProvider(
      create: (context) =>
          ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository)..getTransactions(),
      child: const PaymentHistoryScreen(),
    ),
    .appInfo => const AppInfoScreen(),
    Routes.appDocuments => AppDocumentsScreen(initialIndex: int.tryParse(node.arguments['index'] ?? '') ?? 0),
    .testMode => BlocProvider(
      create: (context) =>
          TestView(testViewRepository: TestViewRepositoryImpl(apiClient: context.x.dependencies.apiClient))
            ..getTestDetail(node.arguments['id'] ?? '', const TestDetailRequest()),
      child: TestModeScreen(testId: node.arguments['id'] ?? ''),
    ),
    .testCustomMode => BlocProvider(
      create: (context) =>
          TestView(testViewRepository: TestViewRepositoryImpl(apiClient: context.x.dependencies.apiClient))
            ..getTestDetail(node.arguments['id'] ?? '', const TestDetailRequest())
            ..getAttempts(node.arguments['id'] ?? '', .custom),
      child: const TestCustomModeScreen(),
    ),
    .testUniversityMode => BlocProvider(
      create: (context) =>
          TestView(testViewRepository: TestViewRepositoryImpl(apiClient: context.x.dependencies.apiClient))
            ..getTestDetail(node.arguments['id'] ?? '', const TestDetailRequest())
            ..getAttempts(node.arguments['id'] ?? '', .university),
      child: const TestUniversityModeScreen(),
    ),
    .testGroupMode => const TestGroupModeScreen(),
    .testFlashcardMode => const TestFlashcardMode(),
    .testResult => BlocProvider(
      create: (context) =>
          TestView(testViewRepository: TestViewRepositoryImpl(apiClient: context.x.dependencies.apiClient)),
      child: TestResultScreen(arguments: TestResultArguments.fromArguments(node.arguments)),
    ),
    .testSolving => BlocProvider(
      create: (context) {
        log_util.info('router build testSolving: node.arguments=${node.arguments}');
        final args = TestSolvingArguments.fromArguments(node.arguments);
        final apiStart = args.startRange == 0 ? 1 : args.startRange;
        final apiEnd = args.endRange == 0 ? 1 : args.endRange;

        final firstChunkEnd = (apiStart + 19).clamp(apiStart, apiEnd);
        final rangeStr = '$apiStart-$firstChunkEnd';

        return TestView(testViewRepository: TestViewRepositoryImpl(apiClient: context.x.dependencies.apiClient))
          ..getTestDetail(args.testId, TestDetailRequest(shuffle: args.shuffleOptionName, range: rangeStr));
      },
      child: TestSolvingScreen(arguments: TestSolvingArguments.fromArguments(node.arguments)),
    ),
    .supportChat => BlocProvider(
      create: (context) => SupportChatCubit(
        repository: SupportChatRepositoryImpl(apiClient: context.x.dependencies.apiClient),
        localSource: context.x.dependencies.localSource,
        wsBaseUrl: context.x.dependencies.apiClient.baseUrl,
      ),
      child: const SupportChatScreen(),
    ),
    Routes.archive => BlocProvider(
      create: (context) =>
          ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository)..loadArchiveTests(),
      child: const ArchiveScreen(),
    ),
    Routes.session => BlocProvider(
      create: (context) =>
          AuthCubit(authenticationRepository: context.x.dependencies.repository.authenticationRepository),
      child: const SessionScreen(),
    ),
    Routes.editProfile => BlocProvider(
      create: (context) => ProfileCubit(profileRepository: context.x.dependencies.repository.profileRepository),
      child: const EditProfileScreen(),
    ),
  };
}

Octopus? authNavigatorInstance;
