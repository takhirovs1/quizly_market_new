import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/service/api_client.dart';
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
  Future<ProfileModelResponse> uploadAvatar(List<int> bytes, String fileName);
  Future<void> updateName(String name);
  Future<void> deleteAccount();
  Future<void> deleteArchiveTest(String testId);
  Future<void> updateProfile({required String firstName, required String lastName, required String? gender});
}

final class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<ProfileModelResponse> getProfile() async {
    final root = await apiClient.get(Urls.getMe);
    final data = root['data'] as Map<String, Object?>? ?? root;
    return ProfileModelResponse.fromJson(data);
  }

  @override
  Future<void> updateLanguage(String language) async {
    await apiClient.put(Urls.updateLanguage, body: {'language': language});
  }

  @override
  Future<TopUpResponse> topUp(TopUpRequest request) async {
    final response = await apiClient.post(Urls.topUp, body: request.toJson());
    return TopUpResponse.fromJson(response);
  }

  @override
  Future<TransactionResponse> getTransactions(TransactionRequest request) async {
    final response = await apiClient.get('/api/payments/wallet/transactions', queryParameters: request.toJson());
    return TransactionResponse.fromJson(response);
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getArchivedTests({
    int limit = 20,
    int offset = 0,
  }) async {
    final root = await apiClient.get(
      Urls.getMyTests,
      queryParameters: {'limit': limit, 'offset': offset, 'archived': true},
    );
    final dataList = root['data'] as List<Object?>? ?? [];
    final items = dataList
        .map((e) => TestModel.fromJson(e as Map<String, Object?>))
        .where((test) => test.id != '87f107c1-d6b1-4da4-8461-5a140b94ae32')
        .toList();
    final resolvedLimit = root['limit'].toIntOrNull ?? limit;
    final resolvedOffset = root['offset'].toIntOrNull ?? offset;
    final total = root['total'].toIntOrNull ?? 0;
    return (items: items, limit: resolvedLimit, offset: resolvedOffset, total: total);
  }

  @override
  Future<void> unarchiveTest(String testId) async {
    await apiClient.delete('/api/payments/tests/$testId/archive');
  }

  @override
  Future<void> linkGoogle(String idToken) async {
    await apiClient.post('/api/auth/link/google', body: {'id_token': idToken});
  }

  @override
  Future<void> linkApple(String identityToken) async {
    await apiClient.post('/api/auth/link/apple', body: {'identity_token': identityToken});
  }

  @override
  Future<ReferralSummary> getReferralSummary() async {
    final response = await apiClient.get('/api/users/me/referrals/summary');
    return ReferralSummary.fromJson(response);
  }

  @override
  Future<ReferralListResponse> getReferrals({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/api/users/me/referrals',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return ReferralListResponse.fromJson(response);
  }

  @override
  Future<ReferralVerifyResponse> verifyReferral() async {
    final response = await apiClient.get('/api/referrals/verify');
    return ReferralVerifyResponse.fromJson(response);
  }

  @override
  Future<void> unlinkProvider(String provider) async {
    await apiClient.delete('/api/auth/link/$provider');
  }

  @override
  Future<String> getDocument(String key) async {
    final root = await apiClient.get('/api/documents/key/$key');
    final data = root['data'];
    if (data is Map<String, Object?>) {
      return (data['content'] as String?) ?? '';
    } else if (data is String) {
      return data;
    }
    return '';
  }

  @override
  Future<ProfileModelResponse> uploadAvatar(List<int> bytes, String fileName) async {
    final root = await apiClient.multipartPut(
      '/api/users/me/avatar',
      field: 'avatar',
      bytes: bytes,
      filename: fileName,
    );
    final data = root['data'] as Map<String, Object?>? ?? root;
    return ProfileModelResponse.fromJson(data);
  }

  @override
  Future<void> updateName(String name) async {
    await apiClient.put('/api/users/me', body: {'name': name});
  }

  @override
  Future<void> deleteAccount() async {
    await apiClient.delete('/api/users/me');
  }

  @override
  Future<void> deleteArchiveTest(String testId) async {
    await apiClient.delete('/api/payments/tests/$testId/archive');
  }

  @override
  Future<void> updateProfile({required String firstName, required String lastName, required String? gender}) async {
    await apiClient.patch('/api/users/me', body: {'first_name': firstName, 'last_name': lastName, 'gender': gender});
  }
}
