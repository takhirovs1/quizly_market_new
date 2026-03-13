sealed class ExceptionUtilBase with _ExceptionPatternMatcher implements Exception {
  const ExceptionUtilBase._();

  const factory ExceptionUtilBase.serverException() = ServerException;

  const factory ExceptionUtilBase.noConnection() = NoNetworkConnectionException;
}

final class NoNetworkConnectionException extends ExceptionUtilBase {
  const NoNetworkConnectionException() : super._();

  @override
  T map<T>({
    required T Function(NoNetworkConnectionException state) noConnection,
    required T Function(ServerException state) serverException,
  }) => noConnection(this);

  @override
  String toString() => 'No Network Connection';
}

final class ServerException extends ExceptionUtilBase {
  const ServerException() : super._();

  @override
  T map<T>({
    required T Function(NoNetworkConnectionException state) noConnection,
    required T Function(ServerException state) serverException,
  }) => serverException(this);

  @override
  String toString() => 'Server Exception';
}

mixin _ExceptionPatternMatcher {
  T map<T>({
    required T Function(NoNetworkConnectionException state) noConnection,
    required T Function(ServerException state) serverException,
  });

  T maybeMap<T>({
    required T Function() orElse,
    T Function(NoNetworkConnectionException state)? noConnection,
    T Function(ServerException state)? serverException,
  }) => map<T>(
    noConnection: (state) => noConnection?.call(state) ?? orElse(),
    serverException: (state) => serverException?.call(state) ?? orElse(),
  );

  T? mapOrNull<T>({
    T Function(NoNetworkConnectionException state)? noConnection,
    T Function(ServerException state)? serverException,
  }) => map<T?>(
    noConnection: (state) => noConnection?.call(state),
    serverException: (state) => serverException?.call(state),
  );
}
