import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../model/profile_model.dart';
import '../model/topup_model.dart';
import '../model/transaction_model.dart';

class ArchiveTestRequest {
  ArchiveTestRequest({this.limit = 20, this.offset = 0});
  final int limit;
  final int offset;
  Map<String, Object?> toJson() => {'limit': limit, 'offset': offset, 'archived': true};
}

abstract interface class IProfileRepository {
  Future<ProfileModelResponse> getProfile();
  Future<void> updateLanguage(String language);
  Future<TopUpResponse> topUp(TopUpRequest request);
  Future<TransactionResponse> getTransactions(TransactionRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getArchivedTests(ArchiveTestRequest request);
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
  Future<({List<TestModel> items, int limit, int offset, int total})> getArchivedTests(
    ArchiveTestRequest request,
  ) async {
    final response = await dio.get<Map<String, Object?>>(Urls.getMyTests, queryParameters: request.toJson());
    final root = response.data ?? {};
    final dataList = root['data'] as List<Object?>? ?? [];
    final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
    final limit = root['limit'].toIntOrNull ?? request.limit;
    final offset = root['offset'].toIntOrNull ?? request.offset;
    final total = root['total'].toIntOrNull ?? 0;
    return (items: items, limit: limit, offset: offset, total: total);
  }
}
