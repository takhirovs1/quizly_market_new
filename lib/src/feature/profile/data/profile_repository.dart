import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../model/profile_model.dart';
import '../model/topup_model.dart';
import '../model/transaction_model.dart';

abstract interface class IProfileRepository {
  Future<ProfileModelResponse> getProfile();
  Future<void> updateLanguage(String language);
  Future<TopUpResponse> topUp(TopUpRequest request);
  Future<TransactionResponse> getTransactions(TransactionRequest request);
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
}
