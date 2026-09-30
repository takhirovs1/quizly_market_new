import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Locale every [MaterialApp] falls back to when the device/selected locale is
/// not supported. Must be a locale supported by both [GlobalMaterialLocalizations]
/// and [GlobalCupertinoLocalizations] (Uzbek is).
const Locale kFallbackLocale = Locale('uz');

/// Localization delegates shared by every [MaterialApp] in the app.
///
/// [GlobalMaterialLocalizations] / [GlobalCupertinoLocalizations] only ship
/// translations for a subset of languages — locales such as `tg` (Tajik) and
/// `kaa` (Karakalpak) are **not** among them. Without a fallback, selecting one
/// of those throws `No MaterialLocalizations found` the moment a Material or
/// Cupertino widget (dialog, date picker, text selection menu…) is built.
///
/// The trailing [_FallbackMaterialLocalizationsDelegate] /
/// [_FallbackCupertinoLocalizationsDelegate] report `isSupported == true` for
/// every locale, so they catch whatever the global delegates skip and serve
/// [kFallbackLocale]'s strings instead. Because they come *after* the global
/// delegates, supported locales still get their proper translations
/// (`Localizations` only uses the first supported delegate per type).
const List<LocalizationsDelegate<Object?>> appLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppLocalization.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  _FallbackMaterialLocalizationsDelegate(),
  _FallbackCupertinoLocalizationsDelegate(),
];

/// Resolves [locale] against [supported], falling back to [kFallbackLocale]
/// (`uz`) when the locale is not supported.
///
/// Script codes are honoured so `uz_Cyrl` resolves to the Cyrillic entry rather
/// than collapsing into Latin `uz`.
Locale appLocaleResolution(Locale? locale, Iterable<Locale> supported) {
  if (locale == null) return kFallbackLocale;

  // 1. Exact match: language + script + country.
  for (final candidate in supported) {
    if (candidate.languageCode == locale.languageCode &&
        candidate.scriptCode == locale.scriptCode &&
        candidate.countryCode == locale.countryCode) {
      return candidate;
    }
  }
  // 2. Language + script (e.g. uz + Cyrl).
  for (final candidate in supported) {
    if (candidate.languageCode == locale.languageCode && candidate.scriptCode == locale.scriptCode) {
      return candidate;
    }
  }
  // 3. Language only.
  for (final candidate in supported) {
    if (candidate.languageCode == locale.languageCode) return candidate;
  }
  // 4. Nothing matched — use the app default.
  return kFallbackLocale;
}

/// Serves [GlobalMaterialLocalizations] for [kFallbackLocale] to any locale the
/// global delegate does not support, so Material widgets never crash.
class _FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) => GlobalMaterialLocalizations.delegate.load(kFallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

/// Serves [GlobalCupertinoLocalizations] for [kFallbackLocale] to any locale the
/// global delegate does not support, so Cupertino widgets never crash.
class _FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) => GlobalCupertinoLocalizations.delegate.load(kFallbackLocale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}
