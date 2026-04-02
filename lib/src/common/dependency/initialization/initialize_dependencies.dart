import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:local_source/local_source.dart';
import 'package:logbook/logbook.dart';
import 'package:platform_info/platform_info.dart';
import 'package:thunder/thunder.dart';
import 'package:ui/ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../firebase_options.dart';
import '../../../feature/authentication/data/authentication_repository.dart';
import '../../../feature/authentication/state/authentication_controller.dart';
import '../../../feature/main/data/main_repository.dart';
import '../../../feature/my_tests/data/my_test_repository.dart';
import '../../../feature/profile/data/profile_repository.dart';
import '../../../feature/settings/bloc/settings_bloc.dart';
import '../../../feature/settings/data/settings_repository.dart';
import '../../../feature/settings/model/app_settings.dart';
import '../../constant/config.dart';
import '../../constant/pubspec.yaml.g.dart';
import '../../service/api_service.dart';
import '../../service/remote_config_service.dart';
import '../../service/telegram_bot/telegram_bot_interceptor.dart';
import '../../util/http_log_interceptor.dart';
import '../../util/screen_util.dart';
import '../model/app_metadata.dart';
import '../model/debug_config.dart';
import '../model/dependencies.dart';
import '../model/firebase_remote_config_values.dart';

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({void Function(int progress, String message)? onProgress}) async {
  await Config.load();

  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.$1);
      l.i('Initialization | $currentStep/$totalSteps ($percent%) | "${step.$1}"');
      await step.$2(dependencies);
    } on Object catch (error, stackTrace) {
      l.s('Initialization failed at step "${step.$1}": $error', stackTrace);
      Error.throwWithStackTrace('Initialization failed at step "${step.$1}": $error', stackTrace);
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(Dependencies dependencies);

List<(String, _InitializationStep)> get _initializationSteps => <(String, _InitializationStep)>[
  (
    'Platform pre-initialization',
    (_) async {
      /// initializing Firebase
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } on Object catch (err, stackTrace) {
        l.s(err, stackTrace);
      }
    },
  ),

  (
    'Creating app metadata',
    (dependencies) => dependencies.metadata = AppMetadata(
      environment: Config.environment.value,
      isWeb: platform.type.js,
      isRelease: platform.buildMode.release,
      appName: Pubspec.name,
      appVersion: Pubspec.version.canonical,
      appVersionMajor: Pubspec.version.major,
      appVersionMinor: Pubspec.version.minor,
      appVersionPatch: Pubspec.version.patch,
      appBuildTimestamp: Pubspec.version.build.isNotEmpty
          ? (int.tryParse(Pubspec.version.build.firstOrNull ?? '-1') ?? -1)
          : -1,
      operatingSystem: platform.operatingSystem.name,
      processorsCount: platform.numberOfProcessors,
      appLaunchedTimestamp: DateTime.now(),
      locale: platform.locale,
      deviceVersion: platform.version,
      deviceScreenSize: ScreenUtil.screenSize().representation,
    ),
  ),

  ('Database', (dependencies) async => dependencies.localSource = await LocalSource.instance),

  (
    'App Initial Settings',
    (dependencies) {
      final localization = dependencies.localSource.localization;
      final theme = dependencies.localSource.theme == .light ? AppThemeData.light() : AppThemeData.dark();
      final hapticsEnabled = dependencies.localSource.hapticsEnabled;

      HapticsService.isEnabled = hapticsEnabled;

      dependencies.settingsBloc = SettingsBloc(
        settingsRepository: SettingsRepositoryImpl(localSource: dependencies.localSource),
        initialState: .idle(
          settings: AppSettings(
            localization: localization ?? Locale(Intl.systemLocale),
            appTheme: theme,
            hapticsEnabled: hapticsEnabled,
            themeMode: dependencies.localSource.theme,
          ),
        ),
      );
    },
  ),

  // (
  //   'Wakelock',
  //   (dependencies) async {
  //     final wakelockEnabled = dependencies.localSource.wakelockEnabled;
  //     if (wakelockEnabled) {
  //       await WakelockPlus.enable();
  //     } else {
  //       await WakelockPlus.disable();
  //     }
  //   },
  // ),
  (
    'Wakelock',
    (dependencies) async {
      if (kIsWeb) return;

      final wakelockEnabled = dependencies.localSource.wakelockEnabled;

      if (wakelockEnabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    },
  ),

  (
    'Navigators',
    (dependencies) {
      dependencies
        ..authNavigator = ValueNotifier([])
        ..navigator = ValueNotifier([]);
    },
  ),

  (
    'Firebase Remote Config Values',
    (dependencies) async {
      final remoteConfigService = await RemoteConfigService.instance();
      final appVersion = remoteConfigService.isCallCheckAppVersion(dependencies);

      final supportLink = remoteConfigService.getSupportLink();

      l.i('Firebase Remote Config Values | appVersion: $appVersion | supportLink: $supportLink');

      dependencies.firebaseRemoteConfigValues = FirebaseRemoteConfigValues(
        updateData: appVersion,
        supportLink: supportLink,
      );
    },
  ),

  (
    'App Debug Settings',
    (dependencies) async {
      try {
        final remoteConfigService = await RemoteConfigService.instance();
        final botConfig = remoteConfigService.getBotConfig();

        dependencies.appDebugSettings = ValueNotifier(DebugConfig.fromJson(botConfig));

        l.i('App Debug Settings: ${dependencies.appDebugSettings.value}');
      } on Object catch (error, stackTrace) {
        dependencies.appDebugSettings = ValueNotifier(const DebugConfig(debuggerEnabled: false));

        l.s('Error initializing App Debug Settings: $error', stackTrace);
      }
    },
  ),

  (
    'Services Dio',
    (dependencies) {
      final dio = Dio(
        BaseOptions(
          baseUrl: Config.apiBaseUrl,
          headers: <String, String>{
            'Api-Version': '1.0',
            'Accept': 'application/json',
            'Charset': 'utf-8',
            'X-Platform-Type': 'mobile',
          },
          connectTimeout: const Duration(minutes: 1),
          receiveTimeout: const Duration(minutes: 1),
        ),
      );

      final copyDio = Thunder.addDio(dio);

      copyDio.interceptors.addAll(<Interceptor>[
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers.addAll({
              if (dependencies.localSource.accessToken.isNotEmpty) ...{
                io.HttpHeaders.authorizationHeader: 'Bearer ${dependencies.localSource.accessToken}',
              },

              'Content-Language': dependencies.localSource.localization?.languageCode ?? 'en',
            });

            handler.next(options);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              await Future<void>.delayed(const Duration(seconds: 1), dependencies.authenticationController.signOut);
            }

            handler.next(error);
          },
        ),

        if (kReleaseMode) TelegramBotInterceptor(config: dependencies.appDebugSettings.value),

        const HttpLogInterceptor(),
      ]);

      dependencies
        ..dios = DioContainer(dio: copyDio)
        ..apiService = ApiService(copyDio);
    },
  ),

  ('Connectivity', (dependencies) => dependencies.connectivity = Connectivity()),

  (
    'Repositories',
    (dependencies) {
      dependencies.repository = RepositoryContainer(
        authenticationRepository: AuthenticationRepositoryImpl(apiService: dependencies.apiService),
        mainRepository: MainRepositoryImpl(dio: dependencies.dios.dio),
        myTestRepository: MyTestRepositoryImpl(dio: dependencies.dios.dio),
        profileRepository: ProfileRepositoryImpl(dio: dependencies.dios.dio),
      );
    },
  ),

  (
    'Prepare authentication controller',
    (dependencies) => dependencies.authenticationController = AuthenticationController(
      localSource: dependencies.localSource,
      repository: dependencies.repository.authenticationRepository,
    )..restore(),
  ),

  ('Load Data If User Is Authenticated', (dependencies) {}),
];
