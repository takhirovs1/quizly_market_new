import 'package:dio/dio.dart';

import '../../../common/constant/urls.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/util/logger.dart';
import '../models/test_mode.dart';

abstract interface class IMyTestRepository {
  Future<({List<TestModel> items, int limit, int offset, int total})> getMyTests(TestModelRequest request);
  Future<({List<TestModel> items, int limit, int offset, int total})> getTopTests(TestModelRequest request);
}

final class MyTestRepositoryImpl implements IMyTestRepository {
  const MyTestRepositoryImpl({required this.dio});
  final Dio dio;

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
}
