import 'dart:async' show FutureOr;

enum StateStatus implements Comparable<StateStatus> {
  idle('idle'),
  loading('loading'),
  loadingMore('loadingMore'),
  success('success'),
  noInternetConnection('noInternetConnection'),
  error('error');

  /// {@macro state_status}
  const StateStatus(this.value);

  /// Creates a new instance of [StateStatus] from a given string.
  static StateStatus fromValue(String? value, {StateStatus? fallback}) => switch (value) {
    'idle' => idle,
    'loading' => loading,
    'loadingMore' => loadingMore,
    'success' => success,
    'noInternetConnection' => noInternetConnection,
    'error' => error,
    _ => fallback ?? (throw ArgumentError.value(value)),
  };

  /// Value of the enum
  final String value;

  bool get isIdle => this == StateStatus.idle;
  bool get isLoading => this == StateStatus.loading;
  bool get isLoadingMore => this == StateStatus.loadingMore;
  bool get isSuccess => this == StateStatus.success;
  bool get isNoInternetConnection => this == StateStatus.noInternetConnection;
  bool get isError => this == StateStatus.error;

  FutureOr<T> map<T>({
    required FutureOr<T> Function() idle,
    required FutureOr<T> Function() loading,
    required FutureOr<T> Function() loadingMore,
    required FutureOr<T> Function() success,
    required FutureOr<T> Function() noInternetConnection,
    required FutureOr<T> Function() error,
  }) => switch (this) {
    StateStatus.idle => idle(),
    StateStatus.loading => loading(),
    StateStatus.loadingMore => loadingMore(),
    StateStatus.success => success(),
    StateStatus.noInternetConnection => noInternetConnection(),
    StateStatus.error => error(),
  };

  FutureOr<T> maybeMap<T>({
    required FutureOr<T> Function() orElse,
    FutureOr<T> Function()? idle,
    FutureOr<T> Function()? loading,
    FutureOr<T> Function()? loadingMore,
    FutureOr<T> Function()? success,
    FutureOr<T> Function()? noInternetConnection,
    FutureOr<T> Function()? error,
  }) => map(
    idle: idle ?? orElse,
    loading: loading ?? orElse,
    loadingMore: loadingMore ?? orElse,
    success: success ?? orElse,
    noInternetConnection: noInternetConnection ?? orElse,
    error: error ?? orElse,
  );

  FutureOr<T?> maybeMapOrNull<T>({
    FutureOr<T?> Function()? idle,
    FutureOr<T?> Function()? loading,
    FutureOr<T?> Function()? loadingMore,
    FutureOr<T?> Function()? success,
    FutureOr<T?> Function()? noInternetConnection,
    FutureOr<T?> Function()? error,
  }) => maybeMap(
    orElse: () => null,
    idle: idle,
    loading: loading,
    loadingMore: loadingMore,
    success: success,
    noInternetConnection: noInternetConnection,
    error: error,
  );

  @override
  int compareTo(StateStatus other) => index.compareTo(other.index);

  @override
  String toString() => value;
}
