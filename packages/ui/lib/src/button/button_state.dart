/// {@template button_state}
/// ButtonState enumeration
/// {@endtemplate}
enum ButtonState implements Comparable<ButtonState> {
  /// inactive
  inactive('inactive'),

  /// active
  active('active'),

  /// processing
  processing('processing');

  /// {@macro button_state}
  const ButtonState(this.value);

  /// Creates a new instance of [ButtonState] from a given string.
  static ButtonState fromValue(String? value, {ButtonState? fallback}) => switch (value) {
    'inactive' => inactive,
    'active' => active,
    'processing' => processing,
    _ => fallback ?? (throw ArgumentError.value(value)),
  };

  /// Value of the enum
  final String value;

  /// Is in progress state?
  bool get isProcessing => this == processing;

  /// Is in idle state?
  bool get isInactive => this == inactive;

  /// Is in active state?
  bool get isActive => this == active;

  /// Pattern matching
  T map<T>({required T Function() inactive, required T Function() active, required T Function() processing}) =>
      switch (this) {
        ButtonState.inactive => inactive(),
        ButtonState.active => active(),
        ButtonState.processing => processing(),
      };

  /// Pattern matching
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? inactive,
    T Function()? active,
    T Function()? processing,
  }) => map<T>(inactive: inactive ?? orElse, active: active ?? orElse, processing: processing ?? orElse);

  /// Pattern matching
  T? maybeMapOrNull<T>({T Function()? inactive, T Function()? active, T Function()? processing}) =>
      maybeMap<T?>(orElse: () => null, inactive: inactive, active: active, processing: processing);

  @override
  int compareTo(ButtonState other) => index.compareTo(other.index);

  @override
  String toString() => value;
}
