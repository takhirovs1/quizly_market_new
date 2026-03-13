import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// {@template app_settings}
/// Application settings
/// {@endtemplate}
@immutable
class AppSettings with Diagnosticable {
  /// {@macro app_settings}
  const AppSettings({
    required this.appTheme,
    required this.localization,
    required this.hapticsEnabled,
    required this.themeMode,
  });

  /// The theme of the app,
  final ThemeData appTheme;

  /// The localization of the app.
  final Locale? localization;

  /// Whether haptics are enabled.
  final bool hapticsEnabled;

  /// The theme mode of the app.
  final ThemeMode themeMode;

  /// Copy the [AppSettings] with new values.
  AppSettings copyWith({ThemeMode? themeMode, ThemeData? appTheme, Locale? localization, bool? hapticsEnabled}) =>
      AppSettings(
        appTheme: appTheme ?? this.appTheme,
        localization: localization ?? this.localization,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        themeMode: themeMode ?? this.themeMode,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.appTheme == appTheme &&
        other.localization?.languageCode == localization?.languageCode &&
        other.localization?.scriptCode == localization?.scriptCode &&
        other.hapticsEnabled == hapticsEnabled &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode =>
      Object.hash(appTheme, localization?.languageCode, localization?.scriptCode, hapticsEnabled, themeMode);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<ThemeData>('appTheme', appTheme))
      ..add(DiagnosticsProperty<Locale>('localization', localization))
      ..add(DiagnosticsProperty<bool>('hapticsEnabled', hapticsEnabled))
      ..add(DiagnosticsProperty<ThemeMode>('themeMode', themeMode));

    super.debugFillProperties(properties);
  }
}
