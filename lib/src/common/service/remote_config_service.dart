import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import '../dependency/model/dependencies.dart';

@immutable
final class RemoteConfigService {
  const RemoteConfigService._({required this.remoteConfig});

  static RemoteConfigService? _internalSingleton;

  static Future<RemoteConfigService> instance() async {
    if (_internalSingleton != null) return _internalSingleton!;

    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero),
    );

    await remoteConfig.fetchAndActivate();

    return _internalSingleton ??= RemoteConfigService._(remoteConfig: remoteConfig);
  }

  final FirebaseRemoteConfig remoteConfig;

  (AppUpdate, String, String) isCallCheckAppVersion(Dependencies dependencies) {
    try {
      RemoteConfigValue? version;

      if (dependencies.metadata.operatingSystem.toLowerCase() == 'ios') {
        version = remoteConfig.getAll().entries.firstWhereOrNull((e) => e.key == 'ios')?.value;
      } else {
        version = remoteConfig.getAll().entries.firstWhereOrNull((e) => e.key == 'android')?.value;
      }

      final isNotLast = isNotLastVersion(
        '${dependencies.metadata.appVersionMajor}${dependencies.metadata.appVersionMinor}${dependencies.metadata.appVersionPatch}',
        version,
      );

      return isNotLast;
    } on Object catch (e, s) {
      log('Firebase Remote Config Service | isCallCheckAppVersion error: $e $s');
      return (AppUpdate.none, '', '');
    }
  }

  (AppUpdate, String, String) isNotLastVersion(String appVersion, RemoteConfigValue? employeeVersion) {
    if (employeeVersion == null) return (AppUpdate.none, '', '');

    final appVersionData = AppVersionData.fromJson(
      const JsonDecoder().cast<String, Map<String, Object?>>().convert(employeeVersion.asString()),
    );

    final employee = appVersionData.version.replaceAll('.', '').toVersion;
    final package = appVersion.toVersion;

    if (package < employee && appVersionData.isForce) {
      return (AppUpdate.forceUpdate, appVersion, appVersionData.version);
    }

    if (package < employee && !appVersionData.isForce) {
      return (AppUpdate.softUpdate, appVersion, appVersionData.version);
    }

    return (AppUpdate.none, '', '');
  }

  String getSupportLink() {
    try {
      return remoteConfig.getAll().entries.firstWhereOrNull((e) => e.key == 'support_link')?.value.asString() ?? '';
    } on Object catch (e, s) {
      log('Firebase Remote Config Service | getSupportLink error: $e $s');
      return '';
    }
  }

  Map<String, Object?> getBotConfig() {
    try {
      final json =
          remoteConfig.getAll().entries.firstWhereOrNull((e) => e.key == 'bot_config')?.value.asString() ?? '{}';
      return const JsonDecoder().cast<String, Map<String, Object?>>().convert(json);
    } on Object catch (e, s) {
      log('Firebase Remote Config Service | getBotConfig error: $e $s');
      return <String, Object?>{};
    }
  }
}

/// Enums
enum AppUpdate {
  forceUpdate,
  softUpdate,
  none;

  bool get isForceUpdate => this == forceUpdate;
  bool get isSoftUpdate => this == softUpdate;
  bool get isNone => this == none;
}

/// Data classes
final class AppVersionData {
  const AppVersionData({required this.version, required this.isForce});

  factory AppVersionData.fromJson(Map<String, Object?> json) =>
      AppVersionData(version: json.getVal('version', ''), isForce: json.getVal('is_force', false));

  final String version;
  final bool isForce;
}

/// Extensions
extension VersionParsing on String {
  int get toVersion => int.tryParse(replaceAll('.', '')) ?? 0;
}

/// Extension methods for safely parsing values from JSON Maps
extension JsonParsingExtension on Map<String, Object?> {
  /// Safely retrieves a value of type [T] from the map using [key].
  /// Returns [defaultValue] if the key doesn't exist or value cannot be cast to [T].
  ///
  /// Example:
  /// ```dart
  /// final map = {'count': 42};
  /// final count = map.getVal('count', 0); // Returns 42
  /// final missing = map.getVal('missing', 0); // Returns 0
  /// ```
  T getVal<T>(String key, T defaultValue) {
    try {
      final value = this[key];

      if (value is T) return value;

      return defaultValue;
    } on Object catch (_) {
      return defaultValue;
    }
  }
}
