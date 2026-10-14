import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart' as log_util;
import '../model/flashcard_request_model.dart';
import '../model/flashcard_response_model.dart';

abstract interface class IFlashcardRepository {
  Future<FlashcardResponseModel> getCards(FlashcardRequestModel request);
  Future<FlashcardResultResponseModel> submitResult(String testId, FlashcardResultRequestModel request);
}

final class FlashcardRepositoryImpl implements IFlashcardRepository {
  const FlashcardRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<FlashcardResponseModel> getCards(FlashcardRequestModel request) async {
    try {
      final queryParams = request.toQueryParams();
      final response = await apiClient.get(
        '/api/flashcards/${request.testId}',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return FlashcardResponseModel.fromJson(response);
    } catch (e, s) {
      log_util.info('GET FLASHCARDS API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<FlashcardResultResponseModel> submitResult(String testId, FlashcardResultRequestModel request) async {
    try {
      final response = await apiClient.post('/api/flashcards/$testId/result', body: request.toJson());
      return FlashcardResultResponseModel.fromJson(response);
    } catch (e, s) {
      log_util.info('POST FLASHCARD RESULT API ERROR: $e $s');
      rethrow;
    }
  }
}
