import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
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
  const MyTestRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<WalletResponse> getWallet(WalletRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/payments/wallet');
      return WalletResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET WALLET API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getMyTests(TestModelRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>(
        Urls.getMyTests,
        queryParameters: <String, Object?>{...request.toJson(), 'purchased': true},
      );
      final root = response.data ?? {};
      final dataList = root['data'] as List<Object?>? ?? [];
      final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
      final limit = root['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = root['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = root['total'].toIntOrNull ?? 0;

      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('MY TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getTopTests(TestModelRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/tests/top', queryParameters: request.toJson());
      final root = response.data ?? {};
      final dataList = root['data'] as List<Object?>? ?? [];
      final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
      final limit = root['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = root['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = root['total'].toIntOrNull ?? 0;

      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('TOP TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getDemoTest(DemoTestRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/tests/${request.testId}/demo');
      return DemoTestResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET DEMO TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getTestDetail(DemoTestRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/tests/${request.testId}');
      return DemoTestResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET TEST DETAIL API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestByCodeResponse> getTestByCode(TestByCodeRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/tests/code/${request.code}');
      return TestByCodeResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET TEST BY CODE API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> likeTest(String testId) async {
    try {
      await dio.post<void>('/api/tests/$testId/like');
    } catch (e, s) {
      info('LIKE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> unlikeTest(String testId) async {
    try {
      await dio.delete<void>('/api/tests/$testId/like');
    } catch (e, s) {
      info('UNLIKE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestPurchaseResponse> purchaseTest(TestPurchaseRequest request) async {
    try {
      final response = await dio.post<Map<String, Object?>>(
        '/api/payments/tests/${request.testId}/purchase',
        data: request.toJson(),
      );
      return TestPurchaseResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('PURCHASE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<TestCheckoutResponse> checkoutTest(String testId, TestCheckoutRequest request) async {
    try {
      final response = await dio.post<Map<String, Object?>>(
        '/api/payments/tests/$testId/checkout',
        data: request.toJson(),
      );
      return TestCheckoutResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('CHECKOUT TEST API ERROR: $e $s');
      rethrow;
    }
  }
}
