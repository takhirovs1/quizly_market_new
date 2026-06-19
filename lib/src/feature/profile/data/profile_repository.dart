import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../model/profile_model.dart';
import '../model/topup_model.dart';
import '../model/transaction_model.dart';

abstract interface class IProfileRepository {
  Future<ProfileModelResponse> getProfile();
  Future<void> updateLanguage(String language);
  Future<TopUpResponse> topUp(TopUpRequest request);
  Future<TransactionResponse> getTransactions(TransactionRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getArchivedTests({
    int limit = 20,
    int offset = 0,
  });
  Future<void> unarchiveTest(String testId);
  Future<void> linkGoogle(String idToken);
  Future<void> linkApple(String identityToken);
}

final class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<ProfileModelResponse> getProfile() async {
    final response = await dio.get<Map<String, Object?>>(Urls.getMe);
    final root = response.data ?? {};
    final data = root['data'] as Map<String, Object?>? ?? root;
    return ProfileModelResponse.fromJson(data);
  }

  @override
  Future<void> updateLanguage(String language) async {
    await dio.put<void>(Urls.updateLanguage, data: {'language': language});
  }

  @override
  Future<TopUpResponse> topUp(TopUpRequest request) async {
    final response = await dio.post<Map<String, Object?>>(Urls.topUp, data: request.toJson());
    return TopUpResponse.fromJson(response.data ?? {});
  }

  @override
  Future<TransactionResponse> getTransactions(TransactionRequest request) async {
    final response = await dio.get<Map<String, Object?>>(
      '/api/payments/wallet/transactions',
      queryParameters: request.toJson(),
    );
    return TransactionResponse.fromJson(response.data ?? {});
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getArchivedTests({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await dio.get<Map<String, Object?>>(
      Urls.getMyTests,
      queryParameters: {'limit': limit, 'offset': offset, 'archived': true},
    );
    final root = response.data ?? {};
    final dataList = root['data'] as List<Object?>? ?? [];
    final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
    final resolvedLimit = root['limit'].toIntOrNull ?? limit;
    final resolvedOffset = root['offset'].toIntOrNull ?? offset;
    final total = root['total'].toIntOrNull ?? 0;
    return (items: items, limit: resolvedLimit, offset: resolvedOffset, total: total);
  }

  @override
  Future<void> unarchiveTest(String testId) async {
    await dio.delete<void>('/api/payments/tests/$testId/archive');
  }

  @override
  Future<void> linkGoogle(String idToken) async {
    await dio.post<void>('/api/auth/link/google', data: {'id_token': idToken});
  }

  @override
  Future<void> linkApple(String identityToken) async {
    await dio.post<void>('/api/auth/link/apple', data: {'identity_token': identityToken});
  }
}
