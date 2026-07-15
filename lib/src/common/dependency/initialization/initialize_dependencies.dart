import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import '../../../../core/telegram/telegram_service.dart';
import '../../../feature/authentication/data/authentication_repository.dart';
import '../../../feature/authentication/model/auth_token_response.dart';
import '../../../feature/authentication/state/authentication_controller.dart';
import '../../../feature/main/data/main_repository.dart';
import '../../../feature/my_tests/data/my_test_repository.dart';
import '../../../feature/profile/data/profile_repository.dart';
import '../../../feature/settings/bloc/settings_bloc.dart';
import '../../../feature/settings/data/settings_repository.dart';
import '../../../feature/settings/model/app_settings.dart';
import '../../router/pages.dart';
import '../../constant/config.dart';
import '../../constant/pubspec.yaml.g.dart';
import '../../service/api_service.dart';
import '../../service/remote_config_service.dart';
import '../../service/telegram_bot/telegram_bot_interceptor.dart';
import '../../util/http_log_interceptor.dart';
import '../../util/screen_util.dart';
import '../../util/telegram_detector.dart';
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

  (
    'Database',
    (dependencies) async {
      dependencies.localSource = await LocalSource.instance;
      // if (defaultTargetPlatform == .macOS || defaultTargetPlatform == .windows) {
      //   await dependencies.localSource.setAccessToken(
      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3ODE0NTkwNDgsImlhdCI6MTc4MTQ1NTQ0OCwiaXNzIjoicXVpemx5Iiwic3ViIjoiODQzNWZjNjMtNjliMy00MDRlLWExMzgtMDk5M2FkY2Q5N2IzIiwidWlkIjoiODQzNWZjNjMtNjliMy00MDRlLWExMzgtMDk5M2FkY2Q5N2IzIiwidWlpIjoiODQzNWZjNjMtNjliMy00MDRlLWExMzgtMDk5M2FkY2Q5N2IzIiwicm9sZSI6ImN1c3RvbWVyIn0.Z0qudqzizABZckyKhm3_T-wgWQMYqQ9CNoNJmZms0zY',
      //   );
      //   await dependencies.localSource.setRefreshToken(
      //     'a9183d9b2be9020b5cec0ef8783e5cc937e8f38ac459ffc4d363212b5515658e',
      //   );
      //   await dependencies.localSource.setId('8435fc63-69b3-404e-a138-0993adcd97b3');
      // }

      final tg = TelegramService.instance;
      if (tg.isSupported) {
        final startParam = tg.startParam;
        if (startParam != null && startParam.startsWith('r')) {
          final referralCode = startParam.substring(1);
          await dependencies.localSource.setReferralCode(referralCode);
        }
      }

      var deviceId = dependencies.localSource.deviceId;
      if (deviceId.isEmpty) {
        deviceId = await _getHardwareDeviceId();
        if (deviceId.isEmpty) {
          deviceId = _generateRandomUuid();
        }
        await dependencies.localSource.setDeviceId(deviceId);
      }
      l.i('TokenInterceptor | Device ID initialized: $deviceId');
    },
  ),

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
    'Clear stale token for Telegram',
    (dependencies) async {
      if (!kIsWeb) return;
      if (!isTelegramMiniApp()) return;
      await dependencies.localSource.setAccessToken('');
      await dependencies.localSource.setRefreshToken('');
      l.i('Telegram Mini App detected — stale tokens cleared');
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

      Future<String>? refreshFuture;

      copyDio.interceptors.addAll(<Interceptor>[
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers.addAll({
              if (dependencies.localSource.accessToken.isNotEmpty) ...{
                io.HttpHeaders.authorizationHeader: 'Bearer ${dependencies.localSource.accessToken}',
              },
              'Content-Language': dependencies.localSource.localization?.languageCode ?? 'en',
              'X-Device-ID': dependencies.localSource.deviceId,
            });

            handler.next(options);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              l.w('TokenInterceptor | 401 Unauthorized received for path: ${error.requestOptions.path}');

              if (error.requestOptions.path.endsWith('/api/auth/refresh')) {
                l.w('TokenInterceptor | 401 Unauthorized received for refresh request: signing out...');
                try {
                  await dependencies.authenticationController.signOut();
                } on Object catch (signOutError, signOutStack) {
                  l.s('TokenInterceptor | Error during signOut: $signOutError', signOutStack);
                }
                return handler.next(error);
              }

              final responseData = error.response?.data;
              var isSessionExpiredError = false;
              if (responseData is Map) {
                final errVal = responseData['error'];
                if (errVal is String && errVal.contains('session expired or signed in on another device')) {
                  isSessionExpiredError = true;
                }
              } else if (responseData is String) {
                if (responseData.contains('session expired or signed in on another device')) {
                  isSessionExpiredError = true;
                }
              }

              if (isSessionExpiredError) {
                l.w('TokenInterceptor | Session limit exceeded / expired. Opening session screen...');
                authNavigatorInstance?.push(Routes.session);
                return handler.next(error);
              }

              final refreshToken = dependencies.localSource.refreshToken;
              if (refreshToken.isEmpty) {
                l.w('TokenInterceptor | Refresh token is empty. Signing out...');
                try {
                  await dependencies.authenticationController.signOut();
                } on Object catch (e, s) {
                  l.s('TokenInterceptor | Error during signOut: $e', s);
                }
                return handler.next(error);
              }

              try {
                l.i('TokenInterceptor | Attempting token refresh...');
                final newAccessToken = await (refreshFuture ??= () async {
                  try {
                    l.i('TokenInterceptor | Sending request to /api/auth/refresh');
                    final response =
                        await Thunder.addDio(
                          Dio(
                            BaseOptions(
                              baseUrl: Config.apiBaseUrl,
                              headers: <String, String>{
                                'Api-Version': '1.0',
                                'Accept': 'application/json',
                                'Charset': 'utf-8',
                                'X-Platform-Type': 'mobile',
                                'X-Device-ID': dependencies.localSource.deviceId,
                              },
                              connectTimeout: const Duration(seconds: 15),
                              receiveTimeout: const Duration(seconds: 15),
                            ),
                          ),
                        ).post<Map<String, Object?>>(
                          '/api/auth/refresh',
                          data: <String, Object?>{'refresh_token': refreshToken},
                        );

                    final responseData = response.data;
                    if (responseData == null) {
                      throw Exception('Response body is null');
                    }

                    final tokenResponse = AuthTokenResponse.fromJson(responseData);

                    await dependencies.repository.authenticationRepository.updateTokens(
                      accessToken: tokenResponse.accessToken,
                      refreshToken: tokenResponse.refreshToken,
                    );

                    l.i('TokenInterceptor | Token refreshed successfully');
                    return tokenResponse.accessToken;
                  } on Object catch (e, s) {
                    if (e is DioException && e.response?.statusCode == 401) {
                      l.w('TokenInterceptor | Token refresh request failed with 401 Unauthorized: $e', s);
                    } else {
                      l.s('TokenInterceptor | Token refresh request failed: $e', s);
                    }
                    rethrow;
                  } finally {
                    refreshFuture = null;
                  }
                }());

                final options = error.requestOptions;
                options.headers[io.HttpHeaders.authorizationHeader] = 'Bearer $newAccessToken';
                final retryResponse = await copyDio.fetch<Object?>(options);
                return handler.resolve(retryResponse);
              } on Object catch (e, s) {
                final is401 = e is DioException && e.response?.statusCode == 401;
                if (is401) {
                  l.w('TokenInterceptor | Error handling token refresh (401 Unauthorized): signing out...');
                  try {
                    await dependencies.authenticationController.signOut();
                  } on Object catch (signOutError, signOutStack) {
                    l.s('TokenInterceptor | Error during signOut: $signOutError', signOutStack);
                  }
                  return handler.next(error);
                } else {
                  l.s('TokenInterceptor | Error handling token refresh: $e. Not signing out (non-401 error).', s);
                  if (e is DioException) {
                    return handler.next(
                      DioException(
                        requestOptions: error.requestOptions,
                        response: e.response,
                        type: e.type,
                        error: e.error,
                        stackTrace: e.stackTrace,
                        message: e.message,
                      ),
                    );
                  }
                  return handler.next(
                    DioException(
                      requestOptions: error.requestOptions,
                      error: e,
                      stackTrace: s,
                    ),
                  );
                }
              }
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
        authenticationRepository: AuthenticationRepositoryImpl(
          apiService: dependencies.apiService,
          localSource: dependencies.localSource,
        ),
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

Future<String> _getHardwareDeviceId() async {
  try {
    if (kIsWeb) return '';
    final deviceInfo = DeviceInfoPlugin();
    if (io.Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (io.Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    } else if (io.Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      return macInfo.systemGUID ?? '';
    } else if (io.Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.deviceId;
    } else if (io.Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.machineId ?? '';
    }
  } on Object catch (e) {
    l.w('TokenInterceptor | Failed to get hardware device ID: $e');
  }
  return '';
}

String _generateRandomUuid() {
  final random = math.Random.secure();
  return List.generate(36, (index) {
    if (index == 8 || index == 13 || index == 18 || index == 23) {
      return '-';
    }
    if (index == 14) {
      return '4';
    }
    final hex = random.nextInt(16).toRadixString(16);
    if (index == 19) {
      return ((random.nextInt(16) & 0x3) | 0x8).toRadixString(16);
    }
    return hex;
  }).join();
}
