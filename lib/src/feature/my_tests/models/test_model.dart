// {"items":[{"id":1,"category_id":1,"created_by":2,"name":"Basic Science Quiz","description":"A quiz about basic science topics.","price":0,"is_purchased":false,"created_at":"2026-01-10T09:00:00Z"},{"id":2,"category_id":1,"created_by":3,"name":"Advanced Physics","description":"Deep-dive into physics concepts.","price":5000000,"is_purchased":true,"created_at":"2026-02-05T11:00:00Z"}],"limit":20,"offset":0}

import '../../../common/extension/number_extension.dart';
import '../../../common/extension/string_extension.dart';

class TestModelRequest {
  TestModelRequest({this.limit = 20, this.offset = 0, this.search});
  final int? limit;
  final int? offset;
  final String? search;
  Map<String, Object?> toJson() => {'limit': limit, 'offset': offset, 'search': search};
}

class TestModel {
  TestModel({
    this.id,
    this.categoryId,
    this.createdBy,
    this.name,
    this.description,
    this.price,
    this.isPurchased,
    this.isLiked,
    this.questionCount,
    this.likeCount,
    this.categoryName,
    this.createdAt,
    this.code,
    this.academicYear,
    this.semester,
  });

  factory TestModel.fromJson(Map<String, Object?> json) => TestModel(
    id: json['id']?.toString(),
    categoryId: json['category_id']?.toString(),
    createdBy: json['created_by'],
    name: json['name'] as String?,
    description: json['description'] as String?,
    price: json['price'].toIntOrNull,
    isPurchased: json['is_purchased'] as bool?,
    isLiked: (json['liked'] ?? json['is_liked']) as bool?,
    questionCount: json['question_count'].toIntOrNull,
    likeCount: json['like_count'].toIntOrNull,
    categoryName: json['category_name'] as String?,
    createdAt: json['created_at'].toDateTimeOrNull,
    code: json['code'] as String?,
    academicYear: json['academic_year'] as String?,
    semester: json['semester'].toIntOrNull,
  );

  final String? id;
  final String? categoryId;
  final Object? createdBy;
  final String? name;
  final String? description;
  final int? price;
  final bool? isPurchased;
  final bool? isLiked;
  final int? questionCount;
  final int? likeCount;
  final String? categoryName;
  final DateTime? createdAt;
  final String? code;
  final String? academicYear;
  final int? semester;

  TestModel copyWith({
    String? id,
    String? categoryId,
    Object? createdBy,
    String? name,
    String? description,
    int? price,
    bool? isPurchased,
    bool? isLiked,
    int? questionCount,
    int? likeCount,
    String? categoryName,
    DateTime? createdAt,
    String? code,
    String? academicYear,
    int? semester,
  }) => TestModel(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    createdBy: createdBy ?? this.createdBy,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    isPurchased: isPurchased ?? this.isPurchased,
    isLiked: isLiked ?? this.isLiked,
    questionCount: questionCount ?? this.questionCount,
    likeCount: likeCount ?? this.likeCount,
    categoryName: categoryName ?? this.categoryName,
    createdAt: createdAt ?? this.createdAt,
    code: code ?? this.code,
    academicYear: academicYear ?? this.academicYear,
    semester: semester ?? this.semester,
  );
}
