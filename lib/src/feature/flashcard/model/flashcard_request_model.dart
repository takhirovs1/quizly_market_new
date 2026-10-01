class FlashcardRequestModel {
  const FlashcardRequestModel({required this.testId, this.count, this.shuffle, this.source});

  final String testId;
  final int? count;
  final bool? shuffle;
  final String? source;

  Map<String, Object?> toQueryParams() => {
    if (count != null) 'count': count,
    if (shuffle != null) 'shuffle': shuffle,
    if (source != null) 'source': source,
  };
}

class FlashcardResultRequestModel {
  const FlashcardResultRequestModel({
    required this.mode,
    required this.direction,
    required this.total,
    required this.knownIds,
    required this.unknownIds,
    required this.durationSec,
  });

  final String mode;
  final String direction;
  final int total;
  final List<String> knownIds;
  final List<String> unknownIds;
  final int durationSec;

  Map<String, Object?> toJson() => {
    'mode': mode,
    'direction': direction,
    'total': total,
    'known_ids': knownIds,
    'unknown_ids': unknownIds,
    'duration_sec': durationSec,
  };
}
