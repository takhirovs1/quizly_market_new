/// DTO for a single option in manual test creation.
///
/// `answerFormat` ("text" | "latex") and `photo` are additive fields the
/// backend must accept — see docs/upload_backend_integration.md §3.
class ManualOptionDto {
  const ManualOptionDto({
    required this.text,
    required this.position,
    required this.isCorrect,
    this.answerFormat = 'text',
    this.photo,
  });

  final String text;
  final int position;
  final bool isCorrect;
  final String answerFormat;
  final String? photo;

  Map<String, Object?> toJson() => {
    'text': text,
    'position': position,
    'is_correct': isCorrect,
    'answer_format': answerFormat,
    if (photo != null && photo!.isNotEmpty) 'photo': photo,
  };
}

/// DTO for a single question in manual test creation.
class ManualQuestionDto {
  const ManualQuestionDto({
    required this.text,
    required this.position,
    required this.options,
    this.answerFormat = 'text',
    this.photo,
  });

  final String text;
  final int position;
  final List<ManualOptionDto> options;
  final String answerFormat;
  final String? photo;

  Map<String, Object?> toJson() => {
    'text': text,
    'position': position,
    'answer_format': answerFormat,
    if (photo != null && photo!.isNotEmpty) 'photo': photo,
    'options': options.map((e) => e.toJson()).toList(),
  };
}

/// Request body for `POST /api/tests`.
class ManualTestCreateRequest {
  const ManualTestCreateRequest({
    required this.name,
    this.description,
    this.price,
    this.isFree,
    this.categoryId,
    this.questions = const [],
  });

  final String name;
  final String? description;
  final int? price;
  final bool? isFree;
  final String? categoryId;
  final List<ManualQuestionDto> questions;

  Map<String, Object?> toJson() => {
    'name': name,
    if (description != null && description!.isNotEmpty) 'description': description,
    if (price != null) 'price': price,
    if (isFree != null) 'is_free': isFree,
    if (categoryId != null && categoryId!.isNotEmpty) 'category_id': categoryId,
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}

/// Response returned from `POST /api/tests`.
class ManualTestCreateResponse {
  const ManualTestCreateResponse({required this.id, required this.code, required this.status, this.price});

  factory ManualTestCreateResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return ManualTestCreateResponse(
      id: (data['id'] ?? '').toString(),
      code: (data['code'] ?? '').toString(),
      status: (data['status'] ?? 'draft').toString(),
      price: (data['price'] as num?)?.toInt(),
    );
  }

  final String id;
  final String code;
  final String status;
  final int? price;
}
