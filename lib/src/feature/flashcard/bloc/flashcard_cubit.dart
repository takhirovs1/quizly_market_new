import 'dart:math' show Random;

import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/flashcard_repository.dart';
import '../model/flashcard_config.dart';
import '../model/flashcard_request_model.dart';
import '../model/flashcard_response_model.dart';

part 'flashcard_state.dart';

class FlashcardCubit extends SequentialCubit<FlashcardState> {
  FlashcardCubit({required this.repository}) : super(const FlashcardState());

  final IFlashcardRepository repository;

  static const _cardsKey = 'cards';
  static const _resultKey = 'result';

  Future<void> loadCards(String testId, FlashcardConfig config) => handle<void>(
    (emit) async {
      emit(state.copyWithStatus(_cardsKey, StateStatus.loading));
      final request = FlashcardRequestModel(
        testId: testId,
        count: config.cardCount,
        shuffle: config.shuffle,
      );
      final response = await repository.getCards(request);

      var cards = response.cards;

      if (config.direction == FlashcardDirection.answerFirst) {
        cards = cards.map((c) => FlashcardCardModel(
          id: c.id,
          front: c.back,
          back: c.front,
          explanation: c.explanation,
          options: c.options,
          correctOptionId: c.correctOptionId,
          imageUrl: c.imageUrl,
        )).toList();
      }

      if (config.shuffle) {
        cards = List.of(cards)..shuffle(Random());
      }

      final count = config.cardCount;
      if (count != null && cards.length > count) {
        cards = cards.sublist(0, count);
      }

      emit(state.copyWith(
        statuses: <String, StateStatus>{...state.statuses, _cardsKey: StateStatus.success},
        cards: cards,
        currentIndex: 0,
        isFlipped: false,
        knownIds: <String>{},
        unknownIds: <String>{},
        config: config,
        testId: testId,
        testTitle: response.title,
        startedAt: DateTime.now(),
        selectedOptionId: null,
        isOptionChecked: false,
      ));
    },
    errorHandler: (emit, error, _) {
      emit(state.copyWithStatus(_cardsKey, StateStatus.error,
          errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  void flipCurrent() {
    if (state.cards.isEmpty) return;
    emit(state.copyWith(isFlipped: !state.isFlipped));
  }

  void markKnown() {
    final card = state.currentCard;
    if (card == null) return;
    final knownIds = <String>{...state.knownIds, card.id};
    final unknownIds = <String>{...state.unknownIds}..remove(card.id);
    emit(state.copyWith(knownIds: knownIds, unknownIds: unknownIds));
    _advanceOrFinish();
  }

  void markUnknown() {
    final card = state.currentCard;
    if (card == null) return;
    final unknownIds = <String>{...state.unknownIds, card.id};
    final knownIds = <String>{...state.knownIds}..remove(card.id);
    emit(state.copyWith(knownIds: knownIds, unknownIds: unknownIds));
    _advanceOrFinish();
  }

  void selectOption(String optionId) {
    if (state.isOptionChecked) return;
    final card = state.currentCard;
    if (card == null) return;
    final isCorrect = card.correctOptionId == optionId;
    if (isCorrect) {
      markKnown();
    } else {
      final unknownIds = <String>{...state.unknownIds, card.id};
      final knownIds = <String>{...state.knownIds}..remove(card.id);
      emit(state.copyWith(
        selectedOptionId: optionId,
        isOptionChecked: true,
        knownIds: knownIds,
        unknownIds: unknownIds,
      ));
    }
  }

  void advanceAfterOptionCheck() {
    emit(state.copyWith(selectedOptionId: null, isOptionChecked: false));
    _advanceOrFinish();
  }

  void _advanceOrFinish() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.cards.length) {
      emit(state.copyWith(isSessionFinished: true, isFlipped: false));
    } else {
      emit(state.copyWith(currentIndex: nextIndex, isFlipped: false));
    }
  }

  void next() {
    if (state.currentIndex < state.cards.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1, isFlipped: false));
    }
  }

  void prev() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1, isFlipped: false));
    }
  }

  void retryUnknown() {
    if (state.unknownIds.isEmpty) return;
    final unknownCards = state.cards.where((c) => state.unknownIds.contains(c.id)).toList();
    emit(state.copyWith(
      cards: unknownCards,
      currentIndex: 0,
      isFlipped: false,
      knownIds: <String>{},
      unknownIds: <String>{},
      isSessionFinished: false,
      startedAt: DateTime.now(),
      selectedOptionId: null,
      isOptionChecked: false,
    ));
  }

  Future<void> submitResult() => handle<void>(
    (emit) async {
      emit(state.copyWithStatus(_resultKey, StateStatus.loading));
      final startedAt = state.startedAt;
      final durationSec = startedAt != null
          ? DateTime.now().difference(startedAt).inSeconds
          : 0;
      final request = FlashcardResultRequestModel(
        mode: state.config.mode.name,
        direction: state.config.direction.name,
        total: state.cards.length,
        knownIds: state.knownIds.toList(),
        unknownIds: state.unknownIds.toList(),
        durationSec: durationSec,
      );
      await repository.submitResult(state.testId, request);
      emit(state.copyWithStatus(_resultKey, StateStatus.success));
    },
    errorHandler: (emit, error, _) {
      emit(state.copyWithStatus(_resultKey, StateStatus.error,
          errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );
}
