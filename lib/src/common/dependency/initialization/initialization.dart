import 'dart:async';

import 'package:flutter/foundation.dart' show FlutterError, PlatformDispatcher;
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiMode, SystemUiOverlay, SystemUiOverlayStyle;
import 'package:logbook/logbook.dart';
import 'package:ui/ui.dart';

import '../../util/error_util.dart';
import '../model/dependencies.dart';
import 'initialize_dependencies.dart';

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  required WidgetsBinding binding,
  bool deferFirstFrame = false,
  List<DeviceOrientation>? orientations,
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<Dependencies>(() async {
  final stopwatch = Stopwatch()..start();

  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
    await Future.wait<void>([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]),
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    ]);

    if (deferFirstFrame) binding.deferFirstFrame();

    await _catchExceptions();

    if (orientations != null) await SystemChrome.setPreferredOrientations(orientations);

    final dependencies = await $initializeDependencies(onProgress: onProgress).timeout(const Duration(minutes: 7));

    await onSuccess?.call(dependencies);
    return dependencies;
  } on Object catch (error, stackTrace) {
    onError?.call(error, stackTrace);
    ErrorUtil.logError(error, stackTrace, hint: 'Failed to initialize app').ignore();
    rethrow;
  } finally {
    stopwatch.stop();

    l.i('Initialization took ${stopwatch.elapsed.inMilliseconds}ms');

    binding.addPostFrameCallback((_) {
      // Closes splash screen, and show the app layout.
      if (deferFirstFrame) binding.allowFirstFrame();
      //final context = binding.renderViewElement;
    });
    _$initializeApp = null;
  }
});

Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      ErrorUtil.logError(error, stackTrace, hint: 'ROOT | ${Error.safeToString(error)}').ignore();
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      ErrorUtil.logError(
        details.exception,
        details.stack ?? StackTrace.current,
        hint: 'FLUTTER ERROR\r\n$details',
      ).ignore();
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    ErrorUtil.logError(error, stackTrace).ignore();
  }
}
