import 'package:dio/dio.dart';

import '../../../common/extension/number_extension.dart';
import '../../../common/util/logger.dart';
import '../../my_tests/models/test_mode.dart';

abstract interface class IRecommendationRepository {
  Future<({List<TestModel> items, int limit, int offset, int total})> getRecommendationTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getLikedTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getAllTests(TestModelRequest request);
}

final class RecommendationRepositoryImpl implements IRecommendationRepository {
  const RecommendationRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getRecommendationTests(
    TestModelRequest request,
  ) async {
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
      info('RECOMMENDATION TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getLikedTests(TestModelRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>('/api/tests/liked', queryParameters: request.toJson());
      final root = response.data ?? {};
      final dataList = root['data'] as List<Object?>? ?? [];
      final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
      final limit = root['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = root['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = root['total'].toIntOrNull ?? 0;

      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('LIKED TESTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<({List<TestModel> items, int limit, int offset, int total})> getAllTests(TestModelRequest request) async {
    try {
      final Map<String, Object?> query = {};
      if (request.offset != null && request.offset! > 0) {
        query['limit'] = request.limit;
        query['offset'] = request.offset;
      }
      if (request.search != null && request.search!.isNotEmpty) {
        query['search'] = request.search;
      }
      final response = await dio.get<Map<String, Object?>>(
        '/api/tests/my',
        queryParameters: query.isEmpty ? null : query,
      );
      final root = response.data ?? {};
      final dataList = root['data'] as List<Object?>? ?? [];
      final items = dataList.map((e) => TestModel.fromJson(e as Map<String, Object?>)).toList();
      final limit = root['limit'].toIntOrNull ?? request.limit ?? 20;
      final offset = root['offset'].toIntOrNull ?? request.offset ?? 0;
      final total = root['total'].toIntOrNull ?? 0;

      return (items: items, limit: limit, offset: offset, total: total);
    } catch (e, s) {
      info('ALL TESTS API ERROR: $e $s');
      rethrow;
    }
  }
}
