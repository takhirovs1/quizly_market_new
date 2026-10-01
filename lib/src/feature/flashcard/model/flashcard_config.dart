enum FlashcardDirection { questionFirst, answerFirst }

enum FlashcardMode { study, test }

class FlashcardConfig {
  const FlashcardConfig({
    this.cardCount,
    this.shuffle = false,
    this.direction = FlashcardDirection.questionFirst,
    this.mode = FlashcardMode.study,
  });

  final int? cardCount;
  final bool shuffle;
  final FlashcardDirection direction;
  final FlashcardMode mode;

  FlashcardConfig copyWith({
    Object? cardCount = _sentinel,
    bool? shuffle,
    FlashcardDirection? direction,
    FlashcardMode? mode,
  }) => FlashcardConfig(
    cardCount: cardCount == _sentinel ? this.cardCount : cardCount as int?,
    shuffle: shuffle ?? this.shuffle,
    direction: direction ?? this.direction,
    mode: mode ?? this.mode,
  );

  Map<String, String> toArguments() => {
    if (cardCount != null) 'cardCount': cardCount!.toString(),
    'shuffle': shuffle.toString(),
    'direction': direction.name,
    'mode': mode.name,
  };

  factory FlashcardConfig.fromArguments(Map<String, String> args) => FlashcardConfig(
    cardCount: args['cardCount'] != null ? int.tryParse(args['cardCount']!) : null,
    shuffle: args['shuffle'] == 'true',
    direction: FlashcardDirection.values.firstWhere(
      (d) => d.name == args['direction'],
      orElse: () => FlashcardDirection.questionFirst,
    ),
    mode: FlashcardMode.values.firstWhere(
      (m) => m.name == args['mode'],
      orElse: () => FlashcardMode.study,
    ),
  );

  Map<String, String> toPrefsMap() => {
    if (cardCount != null) 'fc_cardCount': cardCount!.toString(),
    'fc_shuffle': shuffle.toString(),
    'fc_direction': direction.name,
    'fc_mode': mode.name,
  };

  factory FlashcardConfig.fromPrefsMap(Map<String, String?> prefs) => FlashcardConfig(
    cardCount: prefs['fc_cardCount'] != null ? int.tryParse(prefs['fc_cardCount']!) : null,
    shuffle: prefs['fc_shuffle'] == 'true',
    direction: FlashcardDirection.values.firstWhere(
      (d) => d.name == prefs['fc_direction'],
      orElse: () => FlashcardDirection.questionFirst,
    ),
    mode: FlashcardMode.values.firstWhere(
      (m) => m.name == prefs['fc_mode'],
      orElse: () => FlashcardMode.study,
    ),
  );
}

const _sentinel = Object();
