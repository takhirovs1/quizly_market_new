import '../../../common/constant/urls.dart';
import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../model/session_models.dart';

/// Random / mistakes / resume sessions (client-integration-v5.md §6).
abstract interface class ISessionRepository {
  Future<SessionResponse> start(StartSessionRequest request);
  Future<SessionResponse> get(String sessionId);
  Future<SessionAnswerResult> answer(String sessionId, SessionAnswerRequest request);
  Future<SessionResult> finish(String sessionId, SessionFinishRequest request);
  Future<MistakesSummary> mistakesSummary();
}

final class SessionRepositoryImpl implements ISessionRepository {
  const SessionRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<SessionResponse> start(StartSessionRequest request) async {
    try {
      final response = await apiClient.post(Urls.sessions, body: request.toJson());
      return SessionResponse.fromJson(response);
    } catch (e, s) {
      info('START SESSION API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<SessionResponse> get(String sessionId) async {
    try {
      final response = await apiClient.get(Urls.session(sessionId));
      return SessionResponse.fromJson(response);
    } catch (e, s) {
      info('GET SESSION API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<SessionAnswerResult> answer(String sessionId, SessionAnswerRequest request) async {
    try {
      final response = await apiClient.post(Urls.sessionAnswers(sessionId), body: request.toJson());
      return SessionAnswerResult.fromJson(response);
    } catch (e, s) {
      info('SESSION ANSWER API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<SessionResult> finish(String sessionId, SessionFinishRequest request) async {
    try {
      final response = await apiClient.post(Urls.sessionFinish(sessionId), body: request.toJson());
      return SessionResult.fromJson(response);
    } catch (e, s) {
      info('SESSION FINISH API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<MistakesSummary> mistakesSummary() async {
    try {
      final response = await apiClient.get(Urls.mistakesSummary);
      return MistakesSummary.fromJson(response);
    } catch (e, s) {
      info('MISTAKES SUMMARY API ERROR: $e $s');
      rethrow;
    }
  }
}
