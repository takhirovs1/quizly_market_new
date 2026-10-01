part of 'flashcard_cubit.dart';

class FlashcardState extends Equatable {
  const FlashcardState({
    this.statuses = const <String, StateStatus>{},
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.knownIds = const <String>{},
    this.unknownIds = const <String>{},
    this.config = const FlashcardConfig(),
    this.testId = '',
    this.testTitle = '',
    this.startedAt,
    this.isSessionFinished = false,
    this.selectedOptionId,
    this.isOptionChecked = false,
    this.errorMessage,
  });

  final Map<String, StateStatus> statuses;
  final List<FlashcardCardModel> cards;
  final int currentIndex;
  final bool isFlipped;
  final Set<String> knownIds;
  final Set<String> unknownIds;
  final FlashcardConfig config;
  final String testId;
  final String testTitle;
  final DateTime? startedAt;
  final bool isSessionFinished;
  final String? selectedOptionId;
  final bool isOptionChecked;
  final String? errorMessage;

  StateStatus statusOf(String key) => statuses[key] ?? StateStatus.idle;

  FlashcardCardModel? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;

  FlashcardState copyWith({
    Map<String, StateStatus>? statuses,
    List<FlashcardCardModel>? cards,
    int? currentIndex,
    bool? isFlipped,
    Set<String>? knownIds,
    Set<String>? unknownIds,
    FlashcardConfig? config,
    String? testId,
    String? testTitle,
    Object? startedAt = _sentinel,
    bool? isSessionFinished,
    Object? selectedOptionId = _sentinel,
    bool? isOptionChecked,
    Object? errorMessage = _sentinel,
  }) => FlashcardState(
    statuses: statuses ?? this.statuses,
    cards: cards ?? this.cards,
    currentIndex: currentIndex ?? this.currentIndex,
    isFlipped: isFlipped ?? this.isFlipped,
    knownIds: knownIds ?? this.knownIds,
    unknownIds: unknownIds ?? this.unknownIds,
    config: config ?? this.config,
    testId: testId ?? this.testId,
    testTitle: testTitle ?? this.testTitle,
    startedAt: startedAt == _sentinel ? this.startedAt : startedAt as DateTime?,
    isSessionFinished: isSessionFinished ?? this.isSessionFinished,
    selectedOptionId: selectedOptionId == _sentinel ? this.selectedOptionId : selectedOptionId as String?,
    isOptionChecked: isOptionChecked ?? this.isOptionChecked,
    errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
  );

  FlashcardState copyWithStatus(String key, StateStatus status, {String? errorMessage}) => copyWith(
    statuses: <String, StateStatus>{...statuses, key: status},
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    statuses,
    cards,
    currentIndex,
    isFlipped,
    knownIds,
    unknownIds,
    config,
    testId,
    testTitle,
    startedAt,
    isSessionFinished,
    selectedOptionId,
    isOptionChecked,
    errorMessage,
  ];
}

const _sentinel = Object();
