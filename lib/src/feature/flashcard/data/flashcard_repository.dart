import '../../../common/util/logger.dart' as log_util;
import '../../my_tests/models/demo_test_model.dart';
import '../../tests/data/test_view_repository.dart';
import '../../tests/model/test_request_response_models.dart';
import '../model/flashcard_request_model.dart';
import '../model/flashcard_response_model.dart';

abstract interface class IFlashcardRepository {
  Future<FlashcardResponseModel> getCards(FlashcardRequestModel request);
  Future<FlashcardResultResponseModel> submitResult(String testId, FlashcardResultRequestModel request);
}

/// Flashcards are built from the existing **test questions** endpoint
/// (`GET /api/tests/{id}/questions`) — the same API the solving flow uses —
/// until a dedicated flashcard endpoint exists. See `docs/flashcard.md` for the
/// ideal backend contract (titles, explanations, LaTeX/image fields).
final class FlashcardRepositoryImpl implements IFlashcardRepository {
  const FlashcardRepositoryImpl({required this.testViewRepository});

  final ITestViewRepository testViewRepository;

  @override
  Future<FlashcardResponseModel> getCards(FlashcardRequestModel request) async {
    try {
      // The questions endpoint uses a 1-based inclusive range "start-end";
      // our request carries a 0-based, end-exclusive [start, end) slice.
      final range = (request.start != null && request.end != null && request.end! > request.start!)
          ? '${request.start! + 1}-${request.end!}'
          : null;

      final questions = await testViewRepository.getTestQuestions(request.testId, TestDetailRequest(range: range));
      final cards = questions.map(_toCard).toList();

      return FlashcardResponseModel(
        testId: request.testId,
        title: '', // not provided by the questions endpoint; set from the route.
        source: 'test',
        total: cards.length,
        cards: cards,
      );
    } catch (e, s) {
      log_util.info('GET FLASHCARDS (questions) ERROR: $e $s');
      rethrow;
    }
  }

  /// Maps a test question onto a flashcard. Question text is the front, the
  /// correct option(s) form the back. Text may contain LaTeX; images (question
  /// side + answer side) are carried through for `QuestionImageWidget`.
  FlashcardCardModel _toCard(DemoQuestion q) {
    final options = q.options ?? const <DemoOption>[];
    final correct = options.where((o) => o.isCorrect == true).toList();
    final primaryCorrect = correct.isNotEmpty ? correct.first : null;
    final back = correct.map((o) => o.text ?? '').where((t) => t.isNotEmpty).join('\n');

    return FlashcardCardModel(
      id: q.id ?? '',
      front: q.text ?? '',
      back: back,
      imageUrl: q.image,
      backImageUrl: primaryCorrect?.image,
      correctOptionId: primaryCorrect?.id,
      options: options.map((o) => FlashcardOptionModel(id: o.id ?? '', text: o.text ?? '', imageUrl: o.image)).toList(),
    );
  }

  @override
  Future<FlashcardResultResponseModel> submitResult(String testId, FlashcardResultRequestModel request) async {
    // No dedicated flashcard-result endpoint yet — the result is rendered on the
    // shared test-result screen client-side. See docs/flashcard.md.
    return const FlashcardResultResponseModel(sessionId: '', accuracy: 0);
  }
}
