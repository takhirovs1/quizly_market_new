import 'dart:developer';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  const UpdateInfo({required this.hasUpdate, required this.isForced, required this.storeUrl});

  final bool hasUpdate;
  final bool isForced;
  final String storeUrl;
}

class UpdateService {
  static const _androidStoreUrl = 'https://play.google.com/store/apps/details?id=uz.corelabs.quizlymarket';
  static const _iosStoreUrl =
      'https://apps.apple.com/uz/app/quizlymarket/id6780981469'; // App Store ID kelganda almashtir
  static const _macosStoreUrl =
      'https://apps.apple.com/uz/app/quizlymarket/id6780981469?mt=12'; // macOS ham shu ID bo'ladi

  Future<UpdateInfo?> checkUpdate() async {
    // Web uchun force update yo'q — deploy o'zi yangilaydi
    if (kIsWeb) return null;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(fetchTimeout: const Duration(seconds: 10), minimumFetchInterval: const Duration(hours: 1)),
      );

      await remoteConfig.setDefaults({
        'latest_version_android': '1.0.0',
        'latest_version_ios': '1.0.0',
        'latest_version_macos': '1.0.0',
        'min_version_android': '1.0.0',
        'min_version_ios': '1.0.0',
        'min_version_macos': '1.0.0',
        'force_update': false,
      });

      await remoteConfig.fetchAndActivate();

      final latestVersion = remoteConfig.getString(_latestKey);
      final minVersion = remoteConfig.getString(_minKey);
      final forceUpdate = remoteConfig.getBool('force_update');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final hasUpdate = _isVersionLower(currentVersion, latestVersion);
      final isForced = forceUpdate && _isVersionLower(currentVersion, minVersion);

      log(
        '[UpdateService] platform=${_platformName} current=$currentVersion '
        'latest=$latestVersion min=$minVersion '
        'forceUpdate=$forceUpdate hasUpdate=$hasUpdate isForced=$isForced',
      );

      return UpdateInfo(hasUpdate: hasUpdate, isForced: isForced, storeUrl: _storeUrl);
    } on Object catch (e, stackTrace) {
      log('[UpdateService] checkUpdate failed: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  String get _latestKey {
    if (Platform.isAndroid) return 'latest_version_android';
    if (Platform.isIOS) return 'latest_version_ios';
    if (Platform.isMacOS) return 'latest_version_macos';
    return 'latest_version_android';
  }

  String get _minKey {
    if (Platform.isAndroid) return 'min_version_android';
    if (Platform.isIOS) return 'min_version_ios';
    if (Platform.isMacOS) return 'min_version_macos';
    return 'min_version_android';
  }

  String get _storeUrl {
    if (Platform.isAndroid) return _androidStoreUrl;
    if (Platform.isIOS) return _iosStoreUrl;
    if (Platform.isMacOS) return _macosStoreUrl;
    return _androidStoreUrl;
  }

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  bool _isVersionLower(String current, String target) {
    final currentParts = current.split('.').map(int.tryParse).toList();
    final targetParts = target.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      final t = i < targetParts.length ? (targetParts[i] ?? 0) : 0;
      if (c < t) return true;
      if (c > t) return false;
    }
    return false;
  }
}
