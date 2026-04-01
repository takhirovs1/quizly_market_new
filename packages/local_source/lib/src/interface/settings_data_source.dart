part of '../local_source.dart';

abstract interface class SettingsDataSource {
  const SettingsDataSource._();

  // Localization
  Locale? get localization;
  Future<void> setLocalization(Locale? locale);

  // Theme
  ThemeMode get theme;
  Future<void> setTheme(ThemeMode mode);

  // Haptics
  bool get hapticsEnabled;
  Future<void> setHapticsEnabled({required bool enabled});

  // Wakelock
  bool get wakelockEnabled;
  Future<void> setWakelockEnabled({required bool enabled});
}

base mixin SettingsDataSourceImpl on PreferenceDao implements SettingsDataSource {
  // Storage Keys
  PreferenceEntry<String> get _localizationKey => stringEntry(key: 'settings.localization');
  PreferenceEntry<String> get _themeKey => stringEntry(key: 'settings.theme');
  PreferenceEntry<bool> get _hapticsEnabledKey => boolEntry(key: 'settings.haptics_enabled');
  PreferenceEntry<bool> get _wakelockEnabledKey => boolEntry(key: 'settings.wakelock_enabled');
  // --- * end Storage Keys * ---

  /// Localization
  @override
  Locale? get localization {
    final locale = readFromCache<String>(_localizationKey);
    if (locale == null || locale.isEmpty) return null;
    final parts = locale.split('-');
    final languageCode = parts.isNotEmpty ? parts[0] : '';
    final scriptCode = parts.length > 1 ? parts[1] : '';
    if (languageCode.isEmpty) return null;
    return Locale.fromSubtags(languageCode: languageCode, scriptCode: scriptCode.isEmpty ? null : scriptCode);
  }

  @override
  Future<void> setLocalization(Locale? locale) async {
    if (locale == null) return;

    cache[_localizationKey.key] = '${locale.languageCode}-${locale.scriptCode ?? ''}';
    await _localizationKey.set('${locale.languageCode}-${locale.scriptCode ?? ''}');
  }

  /// Theme
  @override
  ThemeMode get theme => switch (readFromCache<String>(_themeKey)) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.light,
  };
  @override
  Future<void> setTheme(ThemeMode mode) async {
    cache[_themeKey.key] = mode.name;
    await _themeKey.set(mode.name);
  }

  /// Haptics
  @override
  bool get hapticsEnabled => readFromCache<bool>(_hapticsEnabledKey) ?? true;
  @override
  Future<void> setHapticsEnabled({required bool enabled}) async {
    cache[_hapticsEnabledKey.key] = enabled;
    await _hapticsEnabledKey.set(enabled);
  }

  /// Wakelock
  @override
  bool get wakelockEnabled => readFromCache<bool>(_wakelockEnabledKey) ?? true;
  @override
  Future<void> setWakelockEnabled({required bool enabled}) async {
    cache[_wakelockEnabledKey.key] = enabled;
    await _wakelockEnabledKey.set(enabled);
  }
}
