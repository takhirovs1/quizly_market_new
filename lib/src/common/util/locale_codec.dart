import 'dart:ui' show Locale;

/// Converts a [Locale] to/from the compact string used for server sync
/// (the `language` field) and any other single-string storage.
///
/// Uses BCP-47 language tags so a script variant survives the round-trip,
/// e.g. `uz`, `ru`, `kaa`, `uz-Cyrl`.
abstract final class AppLocaleCodec {
  const AppLocaleCodec._();

  /// Serialize a [Locale] to a BCP-47 language tag string.
  static String encode(Locale locale) => locale.toLanguageTag();

  /// Parse a language tag (e.g. `uz`, `uz-Cyrl`, `uz_Cyrl`) into a [Locale].
  ///
  /// A 4-letter subtag is treated as the script code; everything else is
  /// ignored so legacy values like a plain `uz` still resolve cleanly.
  static Locale decode(String tag) {
    final parts = tag.split(RegExp('[-_]')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return const Locale('en');
    final languageCode = parts.first;
    final scriptCode = parts.length > 1 && parts[1].length == 4 ? _titleCase(parts[1]) : null;
    return Locale.fromSubtags(languageCode: languageCode, scriptCode: scriptCode);
  }

  static String _titleCase(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();
}
