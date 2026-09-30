import '../../../common/extension/number_extension.dart';
import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../../my_tests/models/test_model.dart';

abstract interface class IRecommendationRepository {
  Future<({List<TestModel> items, int limit, int offset, int total})> getRecommendationTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getLikedTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getAllTests(TestModelRequest request);
  Future<void> likeTest(String testId);
  Future<void> unlikeTest(String testId);
}

final class RecommendationRepositoryImpl implements IRecommendationRepository {
  const RecommendationRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

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
  Future<({List<TestModel> items, int limit, int offset, int total})> getRecommendationTests(
    TestModelRequest request,
  ) async {
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
      info('RECOMMENDATION TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getLikedTests(TestModelRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/liked', queryParameters: request.toJson());
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
      info('LIKED TESTS API ERROR: $e $s');
      if (e is ApiResponseException && e.statusCode == 403) {
        return (items: <TestModel>[], limit: request.limit ?? 20, offset: request.offset ?? 0, total: 0);
      }
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getAllTests(TestModelRequest request) async {
    try {
      final response = await apiClient.get('/api/tests', queryParameters: request.toJson());
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
      info('ALL TESTS API ERROR: $e $s');
      rethrow;
    }
  }
}
