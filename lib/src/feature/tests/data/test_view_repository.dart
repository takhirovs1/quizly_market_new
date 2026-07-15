import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../model/test_attempt_model.dart';
import '../model/test_request_response_models.dart';

abstract interface class ITestViewRepository {
  Future<TestAttemptResponse> getAttempts(String testId, TestAttemptRequest request);
  Future<DemoTestResponse> getTestDetail(String testId, TestDetailRequest request);
  Future<List<DemoQuestion>> getTestQuestions(String testId, TestDetailRequest request);
  Future<StartAttemptResponse> startAttempt(String testId, StartAttemptRequest request);
  Future<FinishAttemptResponse> finishAttempt(String testId, String attemptId, FinishAttemptRequest request);
  Future<void> likeTest(String testId);
  Future<void> unlikeTest(String testId);
  Future<void> archiveTest(String testId);
  Future<void> unarchiveTest(String testId);
}

final class TestViewRepositoryImpl implements ITestViewRepository {
  const TestViewRepositoryImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<TestAttemptResponse> getAttempts(String testId, TestAttemptRequest request) async {
    try {
      final response = await apiClient.get('/api/tests/$testId/attempts', queryParameters: request.toJson());
      return TestAttemptResponse.fromJson(response);
    } catch (e, s) {
      info('GET ATTEMPTS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<DemoTestResponse> getTestDetail(String testId, TestDetailRequest request) async {
    try {
      final queryParams = request.toJson();
      final response = await apiClient.get(
        '/api/tests/$testId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return DemoTestResponse.fromJson(response);
    } catch (e, s) {
      info('GET TEST DETAIL API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<List<DemoQuestion>> getTestQuestions(String testId, TestDetailRequest request) async {
    try {
      final queryParams = request.toJson();
      final response = await apiClient.get(
        '/api/tests/$testId/questions',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final dataMap = response['data'] as Map<String, Object?>?;
      final list = dataMap?['questions'] as List<Object?>? ?? [];
      return list.map((e) => DemoQuestion.fromJson(e as Map<String, Object?>)).toList();
    } catch (e, s) {
      info('GET TEST QUESTIONS API ERROR: $e $s');
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
  Future<void> archiveTest(String testId) async {
    try {
      await apiClient.post('/api/payments/tests/$testId/archive');
    } catch (e, s) {
      info('ARCHIVE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<void> unarchiveTest(String testId) async {
    try {
      await apiClient.delete('/api/payments/tests/$testId/archive');
    } catch (e, s) {
      info('UNARCHIVE TEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<StartAttemptResponse> startAttempt(String testId, StartAttemptRequest request) async {
    try {
      final response = await apiClient.post('/api/tests/$testId/attempts', body: request.toJson());
      info('START ATTEMPT RESP: $response');
      return StartAttemptResponse.fromJson(response);
    } catch (e, s) {
      info('START ATTEMPT API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<FinishAttemptResponse> finishAttempt(String testId, String attemptId, FinishAttemptRequest request) async {
    try {
      info('FINISH ATTEMPT REQ: testId=$testId, attemptId=$attemptId, body=${request.toJson()}');
      final response = await apiClient.post('/api/tests/$testId/attempts/$attemptId/finish', body: request.toJson());
      info('FINISH ATTEMPT RESP: $response');
      return FinishAttemptResponse.fromJson(response);
    } catch (e, s) {
      info('FINISH ATTEMPT API ERROR: $e $s');
      rethrow;
    }
  }
}
