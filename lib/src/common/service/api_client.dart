import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thunder/thunder.dart';

/// Thrown when the HTTP request fails due to a network or transport error.
///
/// Extends thunder's [ApiClientException] so the in-app network monitor can
/// render the failure instead of a bare `Status: -` entry.
final class ApiNetworkException extends ApiClientException {
  const ApiNetworkException({required this.message, this.inner});

  @override
  final String message;
  final Object? inner;

  @override
  int get statusCode => 0;

  @override
  String get code => 'network_error';

  @override
  Object? get error => inner;

  @override
  Object? get data => null;

  @override
  String toString() => 'ApiNetworkException: $message';
}

/// Thrown when the server responds with an error HTTP status (> 204).
///
/// Extends thunder's [ApiClientException] so the in-app network monitor shows
/// the real HTTP status and the parsed error body.
final class ApiResponseException extends ApiClientException {
  const ApiResponseException({required this.statusCode, required this.message, this.body});

  @override
  final int statusCode;

  @override
  final String message;

  /// Parsed JSON body of the error response (Map, List, or null).
  final Object? body;

  @override
  String get code => 'http_$statusCode';

  @override
  Object? get error => null;

  @override
  Object? get data => body;

  @override
  String toString() => 'ApiResponseException($statusCode): $message${body == null ? '' : ' | body: $body'}';
}

/// Central HTTP client based on package:http with Thunder middleware support.
///
/// All methods return [Map<String, Object?>] (never null).
/// On HTTP errors > 204 an [ApiResponseException] is thrown.
/// On network/transport errors an [ApiNetworkException] is thrown.
///
/// Token refresh + retry on 401 is built-in via the [onRefreshToken] callback.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.getAccessToken,
    this.getRefreshToken,
    this.getLocale,
    this.getDeviceId,
    this.getPlatform,
    this.getAppVersion,
    this.getScreenName,
    this.getFunctionName,
    this.onRefreshToken,
    this.onSignOut,
    this.onSessionExpired,
    this.onAccountBlocked,
    List<ApiClientMiddleware> middlewares = const [],
    http.Client? httpClient,
  }) {
    final inner = httpClient ?? http.Client();

    Future<ApiClientResponse> coreHandler(ApiClientRequest request, Map<String, Object?> context) async {
      final http.StreamedResponse raw;
      try {
        raw = await inner.send(request);
      } on Object catch (e) {
        throw ApiNetworkException(message: e.toString(), inner: e);
      }

      final status = raw.statusCode;
      final bodyBytes = await raw.stream.toBytes();

      Object? parsedBody;
      if (bodyBytes.isNotEmpty) {
        try {
          parsedBody = const Utf8Decoder().fuse(const JsonDecoder()).convert(bodyBytes);
        } on Object {
          parsedBody = utf8.decode(bodyBytes, allowMalformed: true);
        }
      }

      if (status > 204) {
        throw ApiResponseException(statusCode: status, message: 'HTTP $status', body: parsedBody);
      }

      final Map<String, Object?> responseBody;
      if (parsedBody is Map) {
        responseBody = parsedBody.cast<String, Object?>();
      } else {
        responseBody = {};
      }

      return .json(
        responseBody,
        statusCode: status,
        headers: raw.headers,
        contentLength: bodyBytes.length,
        persistentConnection: raw.persistentConnection,
        request: request,
      );
    }

    _handler = middlewares.isEmpty ? coreHandler : ApiClientMiddlewareWrapper.merge(middlewares)(coreHandler);
  }

  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final String Function()? getAccessToken;
  final String Function()? getRefreshToken;
  final String Function()? getLocale;
  final String Function()? getDeviceId;
  final String Function()? getPlatform;
  final String Function()? getAppVersion;
  final String Function()? getScreenName;
  final String Function()? getFunctionName;

  /// Called on 401 to exchange the refresh token for a new access token.
  /// Must store the new tokens (e.g., via LocalSource) so that the next
  /// call to [getAccessToken] returns the fresh value.
  final Future<void> Function(String refreshToken)? onRefreshToken;

  /// Called when authentication fails unrecoverably (sign out the user).
  final Future<void> Function()? onSignOut;

  /// Called when a session is gone (`session_revoked`): logged out, revoked from
  /// another device, expired, or the user was deleted. The user must re-login.
  final void Function()? onSessionExpired;

  /// Called when the account is blocked by an admin (`account_blocked`, 403).
  /// The client must not refresh or retry; show a "blocked" screen.
  /// Falls back to [onSignOut] when not provided.
  final void Function()? onAccountBlocked;

  late final ApiClientHandler _handler;
  Future<void>? _refreshFuture;
  bool _isSigningOut = false;

  Future<void> _safeSignOut() async {
    if (_isSigningOut) return;
    _isSigningOut = true;
    try {
      await onSignOut?.call();
    } finally {
      _isSigningOut = false;
    }
  }

  // ─── Public HTTP methods ───────────────────────────────────────────────────

  Future<Map<String, Object?>> get(String path, {Map<String, Object?>? queryParameters}) =>
      _withRetry((isRetry) => _send('GET', path, queryParameters: queryParameters, isRetry: isRetry));

  Future<Map<String, Object?>> post(String path, {Object? body}) =>
      _withRetry((isRetry) => _send('POST', path, body: body, isRetry: isRetry));

  Future<Map<String, Object?>> put(String path, {Object? body}) =>
      _withRetry((isRetry) => _send('PUT', path, body: body, isRetry: isRetry));

  Future<Map<String, Object?>> patch(String path, {Object? body}) =>
      _withRetry((isRetry) => _send('PATCH', path, body: body, isRetry: isRetry));

  Future<Map<String, Object?>> delete(String path, {Object? body}) =>
      _withRetry((isRetry) => _send('DELETE', path, body: body, isRetry: isRetry));

  /// Get raw bytes (e.g. file download).
  Future<List<int>> getBytes(String path, {Map<String, Object?>? queryParameters}) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.Request('GET', uri);
    _applyHeaders(request.headers, false);
    final response = await http.Client().send(request);
    if (response.statusCode > 204) {
      throw ApiResponseException(statusCode: response.statusCode, message: 'HTTP ${response.statusCode}');
    }
    return response.stream.toBytes();
  }

  /// Multipart POST (e.g., file upload or import).
  Future<Map<String, Object?>> multipartPost(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, Object?>? queryParameters,
  }) => _withRetry(
    (isRetry) => _sendMultipart(
      'POST',
      path,
      field: field,
      bytes: bytes,
      filename: filename,
      fields: fields,
      queryParameters: queryParameters,
      isRetry: isRetry,
    ),
  );

  /// Multipart PUT (e.g., avatar upload).
  Future<Map<String, Object?>> multipartPut(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, Object?>? queryParameters,
  }) => _withRetry(
    (isRetry) => _sendMultipart(
      'PUT',
      path,
      field: field,
      bytes: bytes,
      filename: filename,
      fields: fields,
      queryParameters: queryParameters,
      isRetry: isRetry,
    ),
  );

  // ─── Internal helpers ──────────────────────────────────────────────────────

  Future<Map<String, Object?>> _withRetry(Future<Map<String, Object?>> Function(bool isRetry) fn) async {
    try {
      return await fn(false);
    } on ApiResponseException catch (e) {
      // Branch on the auth `code` (docs/session-auth.md §5), never on the HTTP
      // status alone or the message text.
      switch (_authAction(e)) {
        case .refresh:
          // token_expired: rotate the pair once, then retry the request once.
          await _refreshTokens(e);
          try {
            return await fn(true);
          } on ApiResponseException catch (retryErr) {
            // A repeat auth failure after a successful refresh means the session
            // is truly gone → sign out. A 5xx is transient → leave the user in.
            if (_isAuthFailure(retryErr)) await _safeSignOut();
            rethrow;
          }
        case .sessionExpired:
          // session_revoked: refresh would fail too — re-login.
          await _safeSignOut();
          onSessionExpired?.call();
          rethrow;
        case .blocked:
          // account_blocked: do not refresh or retry; show the blocked screen.
          (onAccountBlocked ?? () => unawaited(_safeSignOut())).call();
          rethrow;
        case .signOut:
          // missing_token / refresh_invalid, or a bare 401 with no token to use.
          await _safeSignOut();
          rethrow;
        case .none:
          // server_error (5xx) and non-auth 403s are transient / caller-handled.
          rethrow;
      }
    }
  }

  /// Reads the auth error `code` from an error body (`{"error", "code"}`).
  String? _authCode(ApiResponseException e) {
    final body = e.body;
    if (body is Map) {
      final code = body['code'];
      if (code is String && code.isNotEmpty) return code;
    }
    return null;
  }

  /// Decides how to react to a 4xx/5xx, per docs/session-auth.md §5.
  _AuthAction _authAction(ApiResponseException e) {
    final code = _authCode(e);
    switch (code) {
      case 'token_expired':
        return _AuthAction.refresh;
      case 'session_revoked':
        return _AuthAction.sessionExpired;
      case 'account_blocked':
        return _AuthAction.blocked;
      case 'missing_token':
      case 'refresh_invalid':
        return _AuthAction.signOut;
      case 'server_error':
        return _AuthAction.none;
    }

    // No `code`: older backend, or a non-middleware error. Fall back to status.
    if (e.statusCode == 401) {
      // Legacy "signed in on another device" wording → treat as session expiry.
      final err = (e.body is Map) ? (e.body! as Map)['error'] : null;
      if (err is String && err.contains('session expired or signed in on another device')) {
        return _AuthAction.sessionExpired;
      }
      // Otherwise assume the access token lapsed and try a single refresh+retry.
      return _AuthAction.refresh;
    }
    // Bare 403 (authorization, not auth) and 5xx: don't touch the session.
    return _AuthAction.none;
  }

  /// Whether an error means the caller's credentials are no longer valid
  /// (so a post-refresh retry that still hits this should sign out).
  bool _isAuthFailure(ApiResponseException e) {
    final code = _authCode(e);
    if (code != null) {
      return code == 'token_expired' ||
          code == 'session_revoked' ||
          code == 'missing_token' ||
          code == 'refresh_invalid';
    }
    return e.statusCode == 401;
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    bool isRetry = false,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.Request(method, uri);
    _applyHeaders(request.headers, isRetry);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(body);
    }
    final response = await _handler(ApiClientRequest(request), <String, Object?>{});
    final responseBody = response.body;
    if (responseBody is Map<String, Object?>) return responseBody;
    return {};
  }

  Future<Map<String, Object?>> _sendMultipart(
    String method,
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, Object?>? queryParameters,
    bool isRetry = false,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.MultipartRequest(method, uri);
    _applyHeaders(request.headers, isRetry);
    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }
    request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
    final response = await _handler(ApiClientRequest(request), <String, Object?>{});
    final responseBody = response.body;
    if (responseBody is Map<String, Object?>) return responseBody;
    return {};
  }

  void _applyHeaders(Map<String, String> headers, bool isRetry) {
    headers.addAll(defaultHeaders);
    final token = getAccessToken?.call() ?? '';
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    final locale = getLocale?.call();
    if (locale != null && locale.isNotEmpty) headers['Content-Language'] = locale;
    final deviceId = getDeviceId?.call();
    if (deviceId != null && deviceId.isNotEmpty) headers['X-Device-ID'] = deviceId;

    final platform = getPlatform?.call() ?? (kIsWeb ? 'web' : defaultTargetPlatform.name);
    if (platform.isNotEmpty) headers['X-Platform'] = platform;

    final appVersion = getAppVersion?.call() ?? '';
    if (appVersion.isNotEmpty) headers['X-App-Version'] = appVersion;

    final screenName = getScreenName?.call() ?? '';
    if (screenName.isNotEmpty) headers['X-Screen-Name'] = screenName;

    final functionName = getFunctionName?.call() ?? _extractCallerFunctionName();
    if (functionName.isNotEmpty) headers['X-Function-Name'] = functionName;
  }

  String _extractCallerFunctionName() {
    try {
      final lines = StackTrace.current.toString().split('\n');
      for (final line in lines) {
        if (line.contains('api_client.dart') ||
            line.contains('ApiClient.') ||
            line.contains('_extractCallerFunctionName') ||
            line.contains('_applyHeaders') ||
            line.contains('_send') ||
            line.contains('_withRetry')) {
          continue;
        }
        final match = RegExp(r'#\d+\s+([^\s\(]+)').firstMatch(line);
        if (match != null) {
          final name = match.group(1);
          if (name != null && name.isNotEmpty && !name.contains('<anonymous')) {
            return name;
          }
        }
      }
    } on Object catch (_) {}
    return '';
  }

  Uri _buildUri(String path, Map<String, Object?>? queryParameters) {
    final full = path.startsWith('http') ? path : '$baseUrl$path';
    final uri = Uri.parse(full);
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    final qp = <String, String>{
      for (final e in queryParameters.entries)
        if (e.value != null) e.key: e.value.toString(),
    };
    return uri.replace(queryParameters: qp);
  }

  /// Rotates the token pair via [onRefreshToken], sharing a single in-flight
  /// refresh across concurrent callers (docs/session-auth.md §4). Signs out and
  /// rethrows if there is no refresh token or the refresh itself fails.
  Future<void> _refreshTokens(ApiResponseException e) async {
    final refreshToken = getRefreshToken?.call() ?? '';
    if (refreshToken.isEmpty || onRefreshToken == null) {
      await _safeSignOut();
      throw e;
    }

    try {
      await (_refreshFuture ??= onRefreshToken!(refreshToken).whenComplete(() => _refreshFuture = null));
    } on Object {
      _refreshFuture = null;
      await _safeSignOut();
      rethrow;
    }
  }
}

/// How [ApiClient] reacts to an auth error, decided from its `code` (§5).
enum _AuthAction {
  /// `token_expired` — refresh the pair and retry the request once.
  refresh,

  /// `session_revoked` — sign out and prompt re-login (refresh would fail too).
  sessionExpired,

  /// `account_blocked` — surface the blocked screen; never refresh or retry.
  blocked,

  /// `missing_token` / `refresh_invalid` — sign out and go to login.
  signOut,

  /// `server_error` (5xx) or a non-auth 403 — transient / caller-handled; the
  /// session is left untouched.
  none,
}
