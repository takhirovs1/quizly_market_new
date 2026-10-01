String? _nonEmptyString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value;
  return null;
}

class FlashcardCardModel {
  const FlashcardCardModel({
    required this.id,
    required this.front,
    required this.back,
    this.explanation,
    this.options,
    this.correctOptionId,
    this.imageUrl,
  });

  factory FlashcardCardModel.fromJson(Map<String, Object?> json) => FlashcardCardModel(
    id: json['id']?.toString() ?? '',
    front: json['front']?.toString() ?? json['text']?.toString() ?? '',
    back: json['back']?.toString() ?? json['answer']?.toString() ?? '',
    explanation: _nonEmptyString(json['explanation']),
    options: (json['options'] as List<Object?>?)
        ?.map((e) => FlashcardOptionModel.fromJson(e as Map<String, Object?>))
        .toList(),
    correctOptionId: _nonEmptyString(json['correct_option_id']),
    imageUrl: _nonEmptyString(json['image_url']) ?? _nonEmptyString(json['photo_url']),
  );

  final String id;
  final String front;
  final String back;
  final String? explanation;
  final List<FlashcardOptionModel>? options;
  final String? correctOptionId;
  final String? imageUrl;
}

class FlashcardOptionModel {
  const FlashcardOptionModel({required this.id, required this.text, this.imageUrl});

  factory FlashcardOptionModel.fromJson(Map<String, Object?> json) => FlashcardOptionModel(
    id: json['id']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    imageUrl: _nonEmptyString(json['image_url']) ?? _nonEmptyString(json['photo_url']),
  );

  final String id;
  final String text;
  final String? imageUrl;
}

class FlashcardResponseModel {
  const FlashcardResponseModel({
    required this.testId,
    required this.title,
    required this.source,
    required this.total,
    required this.cards,
  });

  factory FlashcardResponseModel.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? json;
    return FlashcardResponseModel(
      testId: data['test_id']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? data['name']?.toString() ?? '',
      source: data['source']?.toString() ?? 'custom',
      total: (data['total'] as num?)?.toInt() ?? 0,
      cards: (data['cards'] as List<Object?>?)
              ?.map((e) => FlashcardCardModel.fromJson(e as Map<String, Object?>))
              .toList() ??
          const [],
    );
  }

  final String testId;
  final String title;
  final String source;
  final int total;
  final List<FlashcardCardModel> cards;
}

class FlashcardResultResponseModel {
  const FlashcardResultResponseModel({required this.sessionId, required this.accuracy});

  factory FlashcardResultResponseModel.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? json;
    return FlashcardResultResponseModel(
      sessionId: data['session_id']?.toString() ?? '',
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String sessionId;
  final double accuracy;
}
