import 'package:logbook/logbook.dart';

extension ParseToInt on String {
  /// Parse the string to an integer.
  int? toIntOrNull() => int.tryParse(this);
}

extension ParseToDouble on String {
  /// Parse the string to a double.
  double? toDoubleOrNull() => double.tryParse(this);
}

extension StringX on String {
  /// Extension to check whether given string is digit
  bool get isDigit => BigInt.tryParse(this) != null;
  bool get isDouble => double.tryParse(this) != null;

  String ellipsis([int len = 10, bool showDot = true]) =>
      length > len ? '${substring(0, len)}${showDot ? '...' : ''} ' : this;
}

extension StringNullX on String? {
  /// Returns the string if it is not null or empty, otherwise returns null
  String? get valueOrNull {
    final value = this;

    if (value == null || value.isEmpty) return null;

    return value;
  }

  String get capitalize {
    try {
      final value = this;

      if (value == null) return '';
      if (value.isEmpty || value.length < 2) return value.toUpperCase();

      return value[0].toUpperCase() + value.substring(1).toLowerCase();
    } on Object catch (e, s) {
      l.s('capitalize > error: $e', s);
      return '';
    }
  }

  String get capitalizeAll {
    try {
      final value = this;

      if (value == null) return '';
      if (value.isEmpty || value.length < 2) return value.toUpperCase();

      return value.split(' ').map((word) => word.capitalize).join(' ');
    } on Object catch (e, s) {
      l.s('capitalizeAll > error: $e', s);
      return '';
    }
  }
}
