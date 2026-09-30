import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

import '../util/exception_util.dart';
import 'api_client.dart';

enum Method { get, post, put, patch, delete }

@immutable
class ApiService {
  const ApiService(this.apiClient);

  final ApiClient apiClient;

  Future<bool> checkConnection() async {
    final connection = await Connectivity().checkConnectivity();
    if (connection.any((e) => e == .mobile || e == .wifi)) return true;
    return false;
  }

  Future<Map<String, Object?>> request(
    String path, {
    Method method = .get,
    Object? data,
    Map<String, Object?>? queryParams,
  }) async {
    if (!await checkConnection()) {
      throw Error.throwWithStackTrace(const ExceptionUtilBase.noConnection(), .current);
    }
    return switch (method) {
      .get => apiClient.get(path, queryParameters: queryParams),
      .post => apiClient.post(path, body: data),
      .put => apiClient.put(path, body: data),
      .patch => apiClient.patch(path, body: data),
      .delete => apiClient.delete(path, body: data),
    };
  }
}
