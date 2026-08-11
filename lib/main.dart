import 'dart:async' show Timer, runZonedGuarded;

import 'package:flutter/foundation.dart';
import 'package:logbook/logbook.dart';
import 'package:ui/ui.dart';

import 'src/common/dependency/initialization/initialization.dart';
import 'src/common/dependency/widget/dependencies_scope.dart';
import 'src/common/dependency/widget/initialization_failed_app.dart';
import 'src/common/dependency/widget/splash_screen.dart';
import 'src/common/dependency/widget/update_available_screen.dart';
import 'src/common/extension/context_extension.dart';
import 'src/common/util/helpers.dart';
import 'src/common/widget/app.dart';
import 'src/core/di/service_locator.dart';
import 'src/core/services/web_update_notifier.dart';
import 'src/core/services/web_update_service.dart';

@pragma('vm:entry-point')
void main([List<String>? args]) => runZonedGuarded<Future<void>>(() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  QuizAppBar.isTelegramSupported = (context) => context.telegramWebApp.isSupported;

  final initializationProgress = ValueNotifier<({int progress, String message})>((progress: 0, message: ''));
  final logo = await Helpers.getPlatformSpecificLogo();

  if (kIsWeb) {
    await getIt<WebUpdateService>().init();
    Timer.periodic(const Duration(minutes: 5), (_) async {
      final hasUpdate = await getIt<WebUpdateService>().checkForUpdate();
      if (hasUpdate) getIt<WebUpdateNotifier>().notify();
    });
  }

  runApp(
    DependenciesScope(
      initialization: $initializeApp(
        binding: binding,
        onProgress: (progress, message) => initializationProgress.value = (progress: progress, message: message),
        orientations: [.portraitUp, .portraitDown, .landscapeLeft, .landscapeRight],
      ),
      splashScreen: SplashScreen(progress: initializationProgress, logo: logo),
      updateAvailableScreen: const UpdateAvailableScreen(),
      child: const App(),
      errorBuilder: (error, stackTrace) => InitializationFailedApp(
        error: error,
        stackTrace: stackTrace ?? StackTrace.current,
        onRetryInitialization: main,
      ),
    ),
  );
}, l.s);
