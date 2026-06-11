import '../../../common/extension/string_extension.dart';

class DemoTestRequest {
  const DemoTestRequest({required this.testId});

  final String testId;

  Map<String, Object?> toJson() => {'testId': testId};
}

class DemoTestResponse {
  const DemoTestResponse({this.data});

  factory DemoTestResponse.fromJson(Map<String, Object?> json) => DemoTestResponse(
    data: json['data'] == null ? null : DemoTestDetail.fromJson(json['data'] as Map<String, Object?>),
  );

  final DemoTestDetail? data;

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
    this.academicYear,
    this.semester,
    this.isPurchased,
    this.isLiked,
    this.likeCount,
    this.questionCount,
    this.isDemo,
    this.questions,
    this.createdAt,
    this.code,
    this.isArchived,
  });

  factory DemoTestDetail.fromJson(Map<String, Object?> json) => DemoTestDetail(
    id: json['id'] as String?,
    categoryId: json['category_id'] as String?,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    price: (json['price'] as num?)?.toInt(),
    academicYear: json['academic_year'] as String?,
    semester: (json['semester'] as num?)?.toInt(),
    isPurchased: json['is_purchased'] as bool?,
    isLiked: json['liked'] as bool?,
    likeCount: (json['like_count'] as num?)?.toInt(),
    questionCount: (json['question_count'] as num?)?.toInt(),
    isDemo: json['is_demo'] as bool?,
    questions: (json['questions'] as List<Object?>?)
        ?.map((e) => DemoQuestion.fromJson(e as Map<String, Object?>))
        .toList(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
    code: json['code'] as String?,
    isArchived: json['is_archived'] as bool?,
  );

  final String? id;
  final String? categoryId;
  final String? createdBy;
  final String? name;
  final String? description;
  final int? price;
  final String? academicYear;
  final int? semester;
  final bool? isPurchased;
  final bool? isLiked;
  final int? likeCount;
  final int? questionCount;
  final bool? isDemo;
  final List<DemoQuestion>? questions;
  final DateTime? createdAt;
  final String? code;
  final bool? isArchived;

  Map<String, Object?> toJson() => {
    'id': id,
    'category_id': categoryId,
    'created_by': createdBy,
    'name': name,
    'description': description,
    'price': price,
    'academic_year': academicYear,
    'semester': semester,
    'is_purchased': isPurchased,
    'liked': isLiked,
    'like_count': likeCount,
    'question_count': questionCount,
    'is_demo': isDemo,
    'questions': questions?.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
    'code': code,
    'is_archived': isArchived,
  };

  DemoTestDetail copyWith({
    String? id,
    String? categoryId,
    String? createdBy,
    String? name,
    String? description,
    int? price,
    String? academicYear,
    int? semester,
    bool? isPurchased,
    bool? isLiked,
    int? likeCount,
    int? questionCount,
    bool? isDemo,
    List<DemoQuestion>? questions,
    DateTime? createdAt,
    String? code,
    bool? isArchived,
  }) => DemoTestDetail(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    createdBy: createdBy ?? this.createdBy,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    academicYear: academicYear ?? this.academicYear,
    semester: semester ?? this.semester,
    isPurchased: isPurchased ?? this.isPurchased,
    isLiked: isLiked ?? this.isLiked,
    likeCount: likeCount ?? this.likeCount,
    questionCount: questionCount ?? this.questionCount,
    isDemo: isDemo ?? this.isDemo,
    questions: questions ?? this.questions,
    createdAt: createdAt ?? this.createdAt,
    code: code ?? this.code,
    isArchived: isArchived ?? this.isArchived,
  );
}

class DemoQuestion {
  const DemoQuestion({this.id, this.testId, this.text, this.position, this.score, this.options, this.createdAt});

  factory DemoQuestion.fromJson(Map<String, Object?> json) => DemoQuestion(
    id: json['id'] as String?,
    testId: json['test_id'] as String?,
    text: json['text'] as String?,
    position: (json['position'] as num?)?.toInt(),
    score: (json['score'] as num?)?.toInt(),
    options: (json['options'] as List<Object?>?)?.map((e) => DemoOption.fromJson(e as Map<String, Object?>)).toList(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  final String? id;
  final String? testId;
  final String? text;
  final int? position;
  final int? score;
  final List<DemoOption>? options;
  final DateTime? createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'test_id': testId,
    'text': text,
    'position': position,
    'score': score,
    'options': options?.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
}

class DemoOption {
  const DemoOption({this.id, this.questionId, this.text, this.isCorrect, this.position, this.createdAt});

  factory DemoOption.fromJson(Map<String, Object?> json) => DemoOption(
    id: json['id'] as String?,
    questionId: json['question_id'] as String?,
    text: json['text'] as String?,
    isCorrect: json['is_correct'] as bool?,
    position: (json['position'] as num?)?.toInt(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  final String? id;
  final String? questionId;
  final String? text;
  final bool? isCorrect;
  final int? position;
  final DateTime? createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'question_id': questionId,
    'text': text,
    'is_correct': isCorrect,
    'position': position,
    'created_at': createdAt?.toIso8601String(),
  };
}
