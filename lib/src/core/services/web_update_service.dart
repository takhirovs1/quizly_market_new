import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WebUpdateService {
  WebUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  String? _cachedVersion;

  Future<void> init() async {
    if (!kIsWeb) return;
    try {
      final response = await _dio.get<Object>(
        '/version.json',
        options: Options(responseType: .plain, headers: const <String, String>{'Cache-Control': 'no-cache'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final version = _parseVersion(response.data);
        if (version != null && version.isNotEmpty) {
          _cachedVersion = version;
        }
      }
    } on Object catch (_) {
      // Handle all exceptions silently
    }
  }

  Future<bool> checkForUpdate() async {
    if (!kIsWeb) return false;
    try {
      final response = await _dio.get<Object>(
        '/version.json',
        options: Options(responseType: .plain, headers: const <String, String>{'Cache-Control': 'no-cache'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final serverVersion = _parseVersion(response.data);
        if (serverVersion != null && serverVersion.isNotEmpty && _cachedVersion != null && _cachedVersion!.isNotEmpty) {
          return serverVersion != _cachedVersion;
        }
      }
      return false;
    } on Object catch (_) {
      return false;
    }
  }

  String? _parseVersion(Object? data) {
    try {
      if (data is Map) {
        return data['version']?.toString();
      }
      if (data is String) {
        final json = jsonDecode(data) as Map<String, Object?>;
        return json['version']?.toString();
      }
    } on Object catch (_) {}
    return null;
  }
}
