import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thunder/thunder.dart';

/// Thrown when the HTTP request fails due to a network or transport error.
final class ApiNetworkException implements Exception {
  const ApiNetworkException({required this.message, this.inner});

  final String message;
  final Object? inner;

  @override
  String toString() => 'ApiNetworkException: $message';
}

/// Thrown when the server responds with an error HTTP status (> 204).
final class ApiResponseException implements Exception {
  const ApiResponseException({required this.statusCode, required this.message, this.body});

  final int statusCode;
  final String message;

  /// Parsed JSON body of the error response (Map, List, or null).
  final Object? body;

  @override
  String toString() => 'ApiResponseException($statusCode): $message';
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

  /// Called when a "session expired or signed in on another device" error arrives.
  final void Function()? onSessionExpired;

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
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _handle401(e);
        try {
          return await fn(true); // retry; any second failure propagates to caller
        } on ApiResponseException catch (retryErr) {
          if (retryErr.statusCode == 401 || retryErr.statusCode == 403 || retryErr.statusCode >= 500) {
            await _safeSignOut();
          }
          rethrow;
        }
      } else if (e.statusCode >= 500) {
        await _safeSignOut();
      }
      rethrow;
    }
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

  Future<void> _handle401(ApiResponseException e) async {
    // Check for "session expired or signed in on another device" in the body
    final body = e.body;
    if (body is Map) {
      String? errMsg;
      final err = body['error'];
      if (err is String) errMsg = err;
      if (errMsg != null && errMsg.contains('session expired or signed in on another device')) {
        await _safeSignOut();
        onSessionExpired?.call();
        throw e;
      }
    }

    final refreshToken = getRefreshToken?.call() ?? '';
    if (refreshToken.isEmpty) {
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
