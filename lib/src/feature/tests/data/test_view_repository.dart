import 'package:dio/dio.dart';

import '../../../common/util/logger.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../model/test_attempt_model.dart';

abstract interface class ITestViewRepository {
  Future<TestAttemptResponse> getAttempts(String testId, TestAttemptRequest request);
  Future<DemoTestResponse> getTestDetail(String testId, {String? shuffle, String? range, bool? demo});
  Future<void> likeTest(String testId);
  Future<void> unlikeTest(String testId);
  Future<void> archiveTest(String testId);
  Future<void> unarchiveTest(String testId);
}

final class TestViewRepositoryImpl implements ITestViewRepository {
  const TestViewRepositoryImpl({required this.dio});
  final Dio dio;

  @override
  Future<TestAttemptResponse> getAttempts(String testId, TestAttemptRequest request) async {
    try {
      final response = await dio.get<Map<String, Object?>>(
        '/api/tests/$testId/attempts',
        queryParameters: request.toJson(),
      );
      return TestAttemptResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET ATTEMPTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getTestDetail(String testId, {String? shuffle, String? range, bool? demo}) async {
    try {
      final queryParams = <String, Object?>{};
      if (shuffle != null && shuffle.isNotEmpty) {
        queryParams['shuffle'] = shuffle;
      }
      if (range != null && range.isNotEmpty) {
        queryParams['range'] = range;
      }
      if (demo != null) {
        queryParams['demo'] = demo;
      }

      final response = await dio.get<Map<String, Object?>>(
        '/api/tests/$testId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return DemoTestResponse.fromJson(response.data ?? {});
    } catch (e, s) {
      info('GET TEST DETAIL API ERROR: $e $s');
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
  Future<void> archiveTest(String testId) async {
    try {
      await dio.post<void>('/api/tests/$testId/archive');
    } catch (e, s) {
      info('ARCHIVE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> unarchiveTest(String testId) async {
    try {
      await dio.delete<void>('/api/tests/$testId/archive');
    } catch (e, s) {
      info('UNARCHIVE TEST API ERROR: $e $s');
      rethrow;
    }
  }
}
