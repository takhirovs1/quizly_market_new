import 'package:local_source/local_source.dart';
import 'package:ui/ui.dart';

import '../model/app_settings.dart';

/// {@template app_settings_repository}
/// [AppSettingsRepository] sets and gets app settings.
/// {@endtemplate}
abstract interface class ISettingsRepository {
  /// Set app settings
  Future<void> setSettings(AppSettings settings);

  /// Load [AppSettings] from the source of truth.
  Future<AppSettings?> getSettings();
}

/// {@macro app_settings_repository}
final class SettingsRepositoryImpl implements ISettingsRepository {
  /// {@macro app_settings_repository}
  const SettingsRepositoryImpl({required this.localSource});

  /// The instance of [LocalSource] used to read and write values.
  final LocalSource localSource;

  @override
  Future<AppSettings?> getSettings() async {
    final localization = localSource.localization;
    final themeMode = localSource.theme;
    final hapticsEnabled = localSource.hapticsEnabled;

    return AppSettings(
      localization: localization,
      appTheme: themeMode == ThemeMode.light ? AppThemeData.light() : AppThemeData.dark(),
      hapticsEnabled: hapticsEnabled,
      themeMode: themeMode,
    );
  }

  @override
  Future<void> setSettings(AppSettings settings) async {
    if (settings.hapticsEnabled != localSource.hapticsEnabled) {
      await localSource.setHapticsEnabled(enabled: settings.hapticsEnabled);
    }

    if (settings.localization != localSource.localization) {
      await localSource.setLocalization(settings.localization);
    }

    await localSource.setTheme(settings.themeMode);
  }
}
