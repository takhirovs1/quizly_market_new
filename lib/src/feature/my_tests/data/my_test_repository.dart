import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../models/demo_test_model.dart';
import '../models/test_by_code_model.dart';
import '../models/test_checkout_model.dart';
import '../models/test_model.dart';
import '../models/test_purchase_model.dart';
import '../models/wallet_model.dart';

abstract interface class IMyTestRepository {
  Future<({List<TestModel> items, int limit, int offset, int total})> getMyTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getTopTests(TestModelRequest request);
  Future<DemoTestResponse> getDemoTest(DemoTestRequest request);
  Future<DemoTestResponse> getTestDetail(DemoTestRequest request);
  Future<void> likeTest(String testId);
  Future<void> unlikeTest(String testId);
  Future<WalletResponse> getWallet(WalletRequest request);
  Future<TestPurchaseResponse> purchaseTest(TestPurchaseRequest request);
  Future<TestCheckoutResponse> checkoutTest(String testId, TestCheckoutRequest request);
  Future<TestByCodeResponse> getTestByCode(TestByCodeRequest request);
}

final class MyTestRepositoryImpl implements IMyTestRepository {
  const MyTestRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<WalletResponse> getWallet(WalletRequest request) async {
    try {
      final response = await apiClient.get('/api/payments/wallet');
      return WalletResponse.fromJson(response);
    } catch (e, s) {
      info('GET WALLET API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getMyTests(TestModelRequest request) async {
    try {
      final response = await apiClient.get(
        Urls.getMyTests,
        queryParameters: <String, Object?>{
          ...request.toJson(),
          if (request.search == null || request.search!.isEmpty) 'purchased': true,
        },
      );
      final dataList = response['data'] as List<Object?>? ?? [];
      final items = dataList
          .map((e) => TestModel.fromJson(e as Map<String, Object?>))
          .where((test) => test.id != 'a1d49775-0a29-435a-b145-93824979ab9f')
          .toList();
      final limit = response['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = response['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = response['total'].toIntOrNull ?? 0;
      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('MY TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getTopTests(TestModelRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/top', queryParameters: request.toJson());
      final dataList = response['data'] as List<Object?>? ?? [];
      final items = dataList
          .map((e) => TestModel.fromJson(e as Map<String, Object?>))
          .where((test) => test.id != 'a1d49775-0a29-435a-b145-93824979ab9f')
          .toList();
      final limit = response['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = response['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = response['total'].toIntOrNull ?? 0;
      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('TOP TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getDemoTest(DemoTestRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/${request.testId}/demo');
      return DemoTestResponse.fromJson(response);
    } catch (e, s) {
      info('GET DEMO TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getTestDetail(DemoTestRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/${request.testId}');
      return DemoTestResponse.fromJson(response);
    } catch (e, s) {
      info('GET TEST DETAIL API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestByCodeResponse> getTestByCode(TestByCodeRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/code/${request.code}');
      return TestByCodeResponse.fromJson(response);
    } catch (e, s) {
      info('GET TEST BY CODE API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> likeTest(String testId) async {
    try {
      await apiClient.post('/api/tests/$testId/like');
    } catch (e, s) {
      info('LIKE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> unlikeTest(String testId) async {
    try {
      await apiClient.delete('/api/tests/$testId/like');
    } catch (e, s) {
      info('UNLIKE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestPurchaseResponse> purchaseTest(TestPurchaseRequest request) async {
    try {
      final response = await apiClient.post('/api/payments/tests/${request.testId}/purchase', body: request.toJson());
      return TestPurchaseResponse.fromJson(response);
    } catch (e, s) {
      info('PURCHASE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestCheckoutResponse> checkoutTest(String testId, TestCheckoutRequest request) async {
    try {
      final response = await apiClient.post('/api/payments/tests/$testId/checkout', body: request.toJson());
      return TestCheckoutResponse.fromJson(response);
    } catch (e, s) {
      info('CHECKOUT TEST API ERROR: $e $s');
      rethrow;
    }
  }
}
