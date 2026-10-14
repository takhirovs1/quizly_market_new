enum FlashcardDirection { questionFirst, answerFirst }

enum FlashcardMode { study, test }

class FlashcardConfig {
  const FlashcardConfig({
    this.rangeStart,
    this.rangeEnd,
    this.shuffle = false,
    this.direction = FlashcardDirection.questionFirst,
    this.mode = FlashcardMode.study,
  });

  /// Inclusive-exclusive card range selected on the setup screen.
  /// `null` on both means "all cards".
  final int? rangeStart;
  final int? rangeEnd;
  final bool shuffle;
  final FlashcardDirection direction;
  final FlashcardMode mode;

  /// Number of cards covered by the selected range. `null` = all cards.
  int? get cardCount => (rangeStart != null && rangeEnd != null) ? (rangeEnd! - rangeStart!) : null;

  FlashcardConfig copyWith({
    Object? rangeStart = _sentinel,
    Object? rangeEnd = _sentinel,
    bool? shuffle,
    FlashcardDirection? direction,
    FlashcardMode? mode,
  }) => FlashcardConfig(
    rangeStart: rangeStart == _sentinel ? this.rangeStart : rangeStart as int?,
    rangeEnd: rangeEnd == _sentinel ? this.rangeEnd : rangeEnd as int?,
    shuffle: shuffle ?? this.shuffle,
    direction: direction ?? this.direction,
    mode: mode ?? this.mode,
  );

  Map<String, String> toArguments() => {
    if (rangeStart != null) 'rangeStart': rangeStart!.toString(),
    if (rangeEnd != null) 'rangeEnd': rangeEnd!.toString(),
    'shuffle': shuffle.toString(),
    'direction': direction.name,
    'mode': mode.name,
  };

  factory FlashcardConfig.fromArguments(Map<String, String> args) => FlashcardConfig(
    rangeStart: int.tryParse(args['rangeStart'] ?? ''),
    rangeEnd: int.tryParse(args['rangeEnd'] ?? ''),
    shuffle: args['shuffle'] == 'true',
    direction: FlashcardDirection.values.firstWhere(
      (d) => d.name == args['direction'],
      orElse: () => FlashcardDirection.questionFirst,
    ),
    mode: FlashcardMode.values.firstWhere((m) => m.name == args['mode'], orElse: () => FlashcardMode.study),
  );

  Map<String, String> toPrefsMap() => {
    if (rangeStart != null) 'fc_rangeStart': rangeStart!.toString(),
    if (rangeEnd != null) 'fc_rangeEnd': rangeEnd!.toString(),
    'fc_shuffle': shuffle.toString(),
    'fc_direction': direction.name,
  };

  factory FlashcardConfig.fromPrefsMap(Map<String, String?> prefs) => FlashcardConfig(
    rangeStart: int.tryParse(prefs['fc_rangeStart'] ?? ''),
    rangeEnd: int.tryParse(prefs['fc_rangeEnd'] ?? ''),
    shuffle: prefs['fc_shuffle'] == 'true',
    direction: FlashcardDirection.values.firstWhere(
      (d) => d.name == prefs['fc_direction'],
      orElse: () => FlashcardDirection.questionFirst,
    ),
  );
}

const _sentinel = Object();
