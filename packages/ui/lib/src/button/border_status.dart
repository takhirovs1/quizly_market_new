/// {@template border_status}
/// BorderStatus enumeration
/// {@endtemplate}
enum BorderStatus implements Comparable<BorderStatus> {
  /// error
  error('error'),

  /// success
  success('success'),

  /// none
  none('none');

  /// {@macro border_status}
  const BorderStatus(this.value);

  /// Creates a new instance of [BorderStatus] from a given string.
  static BorderStatus fromValue(String? value, {BorderStatus? fallback}) => switch (value) {
    'error' => error,
    'success' => success,
    'none' => none,
    _ => fallback ?? (throw ArgumentError.value(value)),
  };

  /// Value of the enum
  final String value;

  /// Pattern matching
  T map<T>({required T Function() error, required T Function() success, required T Function() none}) => switch (this) {
    BorderStatus.error => error(),
    BorderStatus.success => success(),
    BorderStatus.none => none(),
  };

  /// Pattern matching
  T maybeMap<T>({required T Function() orElse, T Function()? error, T Function()? success, T Function()? none}) =>
      map<T>(error: error ?? orElse, success: success ?? orElse, none: none ?? orElse);

  /// Pattern matching
  T? maybeMapOrNull<T>({T Function()? error, T Function()? success, T Function()? none}) =>
      maybeMap<T?>(orElse: () => null, error: error, success: success, none: none);

  @override
  int compareTo(BorderStatus other) => index.compareTo(other.index);

  @override
  String toString() => value;
}
