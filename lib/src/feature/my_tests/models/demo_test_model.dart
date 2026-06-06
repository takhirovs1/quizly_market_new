import '../../../common/extension/string_extension.dart';

class LocalizedValue {
  const LocalizedValue({this.uz, this.ru, this.en});

  final String? uz;
  final String? ru;
  final String? en;

  factory LocalizedValue.fromJson(Map<String, Object?> json) =>
      LocalizedValue(uz: json['uz'] as String?, ru: json['ru'] as String?, en: json['en'] as String?);

  Map<String, Object?> toJson() => {'uz': uz, 'ru': ru, 'en': en};

  String get(String languageCode) {
    switch (languageCode) {
      case 'uz':
        return uz ?? ru ?? en ?? '';
      case 'ru':
        return ru ?? uz ?? en ?? '';
      case 'en':
      default:
        return en ?? uz ?? ru ?? '';
    }
  }
}

class DemoTestRequest {
  const DemoTestRequest({required this.testId});

  final String testId;

  Map<String, Object?> toJson() => {'testId': testId};
}

class DemoTestResponse {
  const DemoTestResponse({this.data});

  final DemoTestDetail? data;

  factory DemoTestResponse.fromJson(Map<String, Object?> json) => DemoTestResponse(
    data: json['data'] == null ? null : DemoTestDetail.fromJson(json['data'] as Map<String, Object?>),
  );

  Map<String, Object?> toJson() => {'data': data?.toJson()};
}

class DemoTestDetail {
  const DemoTestDetail({
    this.id,
    this.categoryId,
    this.createdBy,
    this.name,
    this.description,
    this.price,
    this.isPurchased,
    this.isLiked,
    this.questionCount,
    this.isDemo,
    this.questions,
    this.createdAt,
  });

  final String? id;
  final String? categoryId;
  final String? createdBy;
  final LocalizedValue? name;
  final LocalizedValue? description;
  final int? price;
  final bool? isPurchased;
  final bool? isLiked;
  final int? questionCount;
  final bool? isDemo;
  final List<DemoQuestion>? questions;
  final DateTime? createdAt;

  factory DemoTestDetail.fromJson(Map<String, Object?> json) => DemoTestDetail(
    id: json['id'] as String?,
    categoryId: json['category_id'] as String?,
    createdBy: json['created_by'] as String?,
    name: json['name'] == null ? null : LocalizedValue.fromJson(json['name'] as Map<String, Object?>),
    description: json['description'] == null
        ? null
        : LocalizedValue.fromJson(json['description'] as Map<String, Object?>),
    price: (json['price'] as num?)?.toInt(),
    isPurchased: json['is_purchased'] as bool?,
    isLiked: json['is_liked'] as bool?,
    questionCount: (json['question_count'] as num?)?.toInt(),
    isDemo: json['is_demo'] as bool?,
    questions: (json['questions'] as List<Object?>?)
        ?.map((e) => DemoQuestion.fromJson(e as Map<String, Object?>))
        .toList(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'category_id': categoryId,
    'created_by': createdBy,
    'name': name?.toJson(),
    'description': description?.toJson(),
    'price': price,
    'is_purchased': isPurchased,
    'is_liked': isLiked,
    'question_count': questionCount,
    'is_demo': isDemo,
    'questions': questions?.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };

  DemoTestDetail copyWith({
    String? id,
    String? categoryId,
    String? createdBy,
    LocalizedValue? name,
    LocalizedValue? description,
    int? price,
    bool? isPurchased,
    bool? isLiked,
    int? questionCount,
    bool? isDemo,
    List<DemoQuestion>? questions,
    DateTime? createdAt,
  }) => DemoTestDetail(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    createdBy: createdBy ?? this.createdBy,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    isPurchased: isPurchased ?? this.isPurchased,
    isLiked: isLiked ?? this.isLiked,
    questionCount: questionCount ?? this.questionCount,
    isDemo: isDemo ?? this.isDemo,
    questions: questions ?? this.questions,
    createdAt: createdAt ?? this.createdAt,
  );
}

class DemoQuestion {
  const DemoQuestion({this.id, this.testId, this.text, this.position, this.score, this.options, this.createdAt});

  final String? id;
  final String? testId;
  final LocalizedValue? text;
  final int? position;
  final int? score;
  final List<DemoOption>? options;
  final DateTime? createdAt;

  factory DemoQuestion.fromJson(Map<String, Object?> json) => DemoQuestion(
    id: json['id'] as String?,
    testId: json['test_id'] as String?,
    text: json['text'] == null ? null : LocalizedValue.fromJson(json['text'] as Map<String, Object?>),
    position: (json['position'] as num?)?.toInt(),
    score: (json['score'] as num?)?.toInt(),
    options: (json['options'] as List<Object?>?)?.map((e) => DemoOption.fromJson(e as Map<String, Object?>)).toList(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'test_id': testId,
    'text': text?.toJson(),
    'position': position,
    'score': score,
    'options': options?.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
}

class DemoOption {
  const DemoOption({this.id, this.questionId, this.text, this.isCorrect, this.position, this.createdAt});

  final String? id;
  final String? questionId;
  final LocalizedValue? text;
  final bool? isCorrect;
  final int? position;
  final DateTime? createdAt;

  factory DemoOption.fromJson(Map<String, Object?> json) => DemoOption(
    id: json['id'] as String?,
    questionId: json['question_id'] as String?,
    text: json['text'] == null ? null : LocalizedValue.fromJson(json['text'] as Map<String, Object?>),
    isCorrect: json['is_correct'] as bool?,
    position: (json['position'] as num?)?.toInt(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'question_id': questionId,
    'text': text?.toJson(),
    'is_correct': isCorrect,
    'position': position,
    'created_at': createdAt?.toIso8601String(),
  };
}
