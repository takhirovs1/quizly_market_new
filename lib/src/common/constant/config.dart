import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/services.dart' show rootBundle;

/// Config for app.
///
/// **Environment** (which `config/<flavor>.json` to load) comes from compile-time defines, in order:
/// 1. `ENVIRONMENT` — `development` | `staging` | `production`
/// 2. `ENV`
/// 3. `FLAVOR`
///
/// After [load], values from `config/{environment}.json` override defaults (see JSON keys below).
///
/// Run: `flutter run --dart-define=ENVIRONMENT=staging`
sealed class Config {
  const Config._();

  static EnvironmentFlavor _environment = _resolveEnvironmentFromDefines();

  /// Resolved environment (may be aligned with JSON `ENVIRONMENT` after [load]).
  static EnvironmentFlavor get environment => _environment;

  static String _apiBaseUrl = _fallbackBaseUrl;
  static String _telegramApiBaseUrl = _fallbackTelegramApiBaseUrl;

  /// API base URL — from `config/*.json` `BASE_URL`, else `--dart-define=BASE_URL`.
  static String get apiBaseUrl => _apiBaseUrl;

  /// Telegram Bot API base — from `config/*.json` `TELEGRAM_API_BASE_URL`, else dart-define / default.
  static String get telegramApiBaseUrl => _telegramApiBaseUrl;

  static const String _fallbackBaseUrl = .fromEnvironment('BASE_URL', defaultValue: '');
  static const String _fallbackTelegramApiBaseUrl = .fromEnvironment(
    'TELEGRAM_API_BASE_URL',
    defaultValue: 'https://api.telegram.org',
  );

  /// Loads `config/{environment}.json` and applies `BASE_URL`, `TELEGRAM_API_BASE_URL`, optional `ENVIRONMENT`.
  /// Call once during app initialization (before using URLs).
  static Future<void> load() async {
    final assetPath = 'config/${_environment.value}.json';
    try {
      final raw = await rootBundle.loadString(assetPath);
      final map = jsonDecode(raw) as Map<String, dynamic>;

      final envInFile = map['ENVIRONMENT'] as String?;
      if (envInFile != null && envInFile.trim().isNotEmpty) {
        _environment = EnvironmentFlavor.from(envInFile.trim());
      }

      final base = map['BASE_URL'] as String?;
      _apiBaseUrl = (base != null && base.isNotEmpty) ? base : _fallbackBaseUrl;

      final telegram = map['TELEGRAM_API_BASE_URL'] as String?;
      _telegramApiBaseUrl = (telegram != null && telegram.isNotEmpty) ? telegram : _fallbackTelegramApiBaseUrl;
    } on Object catch (e, s) {
      debugPrint('Config.load($assetPath) failed: $e\n$s');
      _apiBaseUrl = _fallbackBaseUrl;
      _telegramApiBaseUrl = _fallbackTelegramApiBaseUrl;
    }
  }

  static EnvironmentFlavor _resolveEnvironmentFromDefines() {
    const primary = String.fromEnvironment('ENVIRONMENT', defaultValue: '');
    const envAlias = String.fromEnvironment('ENV', defaultValue: '');
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: '');
    final raw = primary.isNotEmpty
        ? primary
        : envAlias.isNotEmpty
        ? envAlias
        : flavor;
    return EnvironmentFlavor.from(raw.isEmpty ? null : raw);
  }

  // --- PLATFORM (runtime) --- //
  static bool get kIsIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get kIsAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

/// Environment flavor.
enum EnvironmentFlavor {
  development('development'),
  staging('staging'),
  production('production');

  const EnvironmentFlavor(this.value);

  factory EnvironmentFlavor.from(String? value) {
    final v = value?.trim().toLowerCase();
    if (v == null || v.isEmpty) {
      return const bool.fromEnvironment('dart.vm.product') ? production : development;
    }
    return switch (v) {
      'development' || 'debug' || 'develop' || 'dev' => development,
      'staging' || 'profile' || 'stage' || 'stg' => staging,
      'production' || 'release' || 'prod' || 'prd' => production,
      _ => const bool.fromEnvironment('dart.vm.product') ? production : development,
    };
  }

  final String value;

  bool get isDevelopment => this == development;

  bool get isStaging => this == staging;

  bool get isProduction => this == production;
}
