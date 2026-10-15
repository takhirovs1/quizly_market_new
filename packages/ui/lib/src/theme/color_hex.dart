import 'package:flutter/painting.dart';

/// Parses a `#RRGGBB` / `#AARRGGBB` (or the same without the leading `#`) hex
/// string into a [Color]. Returns [fallback] when [hex] is null/empty/malformed.
///
/// Used for the server-provided thumbnail / avatar fallback colors described in
/// backend_integration.md §4 ("Thumbnails"): the API ships a deterministic
/// `color` per test/friend so the same entity shows the same tile everywhere.
Color colorFromHex(String? hex, {required Color fallback}) {
  if (hex == null) return fallback;
  var value = hex.trim();
  if (value.startsWith('#')) value = value.substring(1);
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}
