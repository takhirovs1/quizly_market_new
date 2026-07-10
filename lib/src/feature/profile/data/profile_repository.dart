import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../model/profile_model.dart';
import '../model/referral_model.dart';
import '../model/referral_summary_model.dart';
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
  Future<ReferralSummary> getReferralSummary();
  Future<ReferralListResponse> getReferrals({int limit = 20, int offset = 0});
  Future<ReferralVerifyResponse> verifyReferral();
  Future<void> unlinkProvider(String provider);
  Future<String> getDocument(String key);
  Future<ProfileModelResponse> uploadAvatar(String filePath);
  Future<void> updateName(String name);
  Future<void> deleteAccount();
  Future<void> deleteArchiveTest(String testId);
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

  @override
  Future<ReferralSummary> getReferralSummary() async {
    final response = await dio.get<Map<String, Object?>>('/api/users/me/referrals/summary');
    return ReferralSummary.fromJson(response.data ?? {});
  }

  @override
  Future<ReferralListResponse> getReferrals({int limit = 20, int offset = 0}) async {
    final response = await dio.get<Map<String, Object?>>(
      '/api/users/me/referrals',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return ReferralListResponse.fromJson(response.data ?? {});
  }

  @override
  Future<ReferralVerifyResponse> verifyReferral() async {
    final response = await dio.get<Map<String, Object?>>('/api/referrals/verify');
    return ReferralVerifyResponse.fromJson(response.data ?? {});
  }

  @override
  Future<void> unlinkProvider(String provider) async {
    await dio.delete<void>('/api/auth/link/$provider');
  }

  @override
  Future<String> getDocument(String key) async {
    final response = await dio.get<Map<String, Object?>>('/api/documents/key/$key');
    final root = response.data ?? {};
    final data = root['data'];
    if (data is Map<String, Object?>) {
      return (data['content'] as String?) ?? '';
    } else if (data is String) {
      return data;
    }
    return '';
  }

  @override
  Future<ProfileModelResponse> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });
    final response = await dio.put<Map<String, Object?>>('/api/users/me/avatar', data: formData);
    final root = response.data ?? {};
    final data = root['data'] as Map<String, Object?>? ?? root;
    return ProfileModelResponse.fromJson(data);
  }

  @override
  Future<void> updateName(String name) async {
    await dio.put<void>('/api/users/me', data: {'name': name});
  }

  @override
  Future<void> deleteAccount() async {
    await dio.delete<void>('/api/users/me');
  }

  @override
  Future<void> deleteArchiveTest(String testId) async {
    await dio.delete<void>('/api/payments/tests/$testId/archive');
  }
}
