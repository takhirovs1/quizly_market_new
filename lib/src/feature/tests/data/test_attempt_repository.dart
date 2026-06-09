import 'package:dio/dio.dart';

import '../../../common/util/logger.dart';
import '../model/test_attempt_model.dart';

abstract interface class ITestAttemptRepository {
  Future<TestAttemptResponse> getAttempts(String testId, TestAttemptRequest request);
}

final class TestAttemptRepositoryImpl implements ITestAttemptRepository {
  const TestAttemptRepositoryImpl({required this.dio});
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
}
