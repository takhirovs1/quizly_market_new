import '../../../common/extension/string_extension.dart';
import 'demo_test_model.dart';

class TestByCodeRequest {
  const TestByCodeRequest({required this.code});

  final String code;

  Map<String, Object?> toJson() => {'code': code};
}

class TestByCodeResponse {
  const TestByCodeResponse({this.data});

  factory TestByCodeResponse.fromJson(Map<String, Object?> json) => TestByCodeResponse(
    data: json['data'] == null ? null : TestByCodeDetail.fromJson(json['data'] as Map<String, Object?>),
  );

  final TestByCodeDetail? data;

  Map<String, Object?> toJson() => {'data': data?.toJson()};
}

class TestByCodeDetail {
  const TestByCodeDetail({
    this.id,
    this.code,
    this.categoryId,
    this.createdBy,
    this.name,
    this.description,
    this.photoUrl,
    this.price,
    this.timeLimitMinutes,
    this.academicYear,
    this.semester,
    this.isPurchased,
    this.isLiked,
    this.categoryName,
    this.questionCount,
    this.questions,
    this.createdAt,
  });

  factory TestByCodeDetail.fromJson(Map<String, Object?> json) => TestByCodeDetail(
    id: json['id'] as String?,
    code: json['code'] as String?,
    categoryId: json['category_id'] as String?,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    photoUrl: json['photo_url'] as String?,
    price: (json['price'] as num?)?.toInt(),
    timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
    academicYear: json['academic_year'] as String?,
    semester: (json['semester'] as num?)?.toInt(),
    isPurchased: json['is_purchased'] as bool?,
    isLiked: json['liked'] as bool?,
    categoryName: json['category_name'] as String?,
    questionCount: (json['question_count'] as num?)?.toInt(),
    questions: (json['questions'] as List<Object?>?)
        ?.map((e) => DemoQuestion.fromJson(e as Map<String, Object?>))
        .toList(),
    createdAt: (json['created_at'] as String?)?.toDateTimeOrNull(),
  );

  final String? id;
  final String? code;
  final String? categoryId;
  final String? createdBy;
  final String? name;
  final String? description;
  final String? photoUrl;
  final int? price;
  final int? timeLimitMinutes;
  final String? academicYear;
  final int? semester;
  final bool? isPurchased;
  final bool? isLiked;
  final String? categoryName;
  final int? questionCount;
  final List<DemoQuestion>? questions;
  final DateTime? createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'code': code,
    'category_id': categoryId,
    'created_by': createdBy,
    'name': name,
    'description': description,
    'photo_url': photoUrl,
    'price': price,
    'time_limit_minutes': timeLimitMinutes,
    'academic_year': academicYear,
    'semester': semester,
    'is_purchased': isPurchased,
    'liked': isLiked,
    'category_name': categoryName,
    'question_count': questionCount,
    'questions': questions?.map((e) => e.toJson()).toList(),
    'created_at': createdAt?.toIso8601String(),
  };
}
