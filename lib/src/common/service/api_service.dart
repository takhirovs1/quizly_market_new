import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../util/exception_util.dart';

enum Method { get, post, put, patch, delete }

@immutable
class ApiService {
  const ApiService(this.dio);

  final Dio dio;

  Future<bool> checkConnection() async {
    final connection = await Connectivity().checkConnectivity();
    if (connection.any((e) => e == .mobile || e == .wifi)) return true;
    return false;
  }

  Future<T> request<T>(
    String path, {
    Method method = .get,
    Object? data,
    Map<String, Object?>? headers,
    Map<String, Object?>? queryParams,
    FormData? formData,
  }) async {
    if (!await checkConnection()) {
      throw Error.throwWithStackTrace(const ExceptionUtilBase.noConnection(), .current);
    }

    final newHeaders = <String, Object?>{'content-Type': formData != null ? 'multipart/form-data' : 'application/json'};

    if (headers != null) newHeaders.addAll(headers);

    final response = await dio.request<Object?>(
      path,
      data: data ?? formData,
      queryParameters: queryParams,
      options: Options(method: method.name, headers: newHeaders),
    );

    if (response.statusCode == null || response.statusCode! > 204) {
      throw Exception(response);
    }

    // if (kDebugMode) log('***** - : ${jsonEncode(response.data)}', name: '\x1B[38;5;200mR\x1B[0m');

    return const JsonDecoder().cast<String, T>().convert(jsonEncode(response.data));
  }
}
