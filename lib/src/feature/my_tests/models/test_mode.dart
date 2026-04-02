// {"items":[{"id":1,"category_id":1,"created_by":2,"name":"Basic Science Quiz","description":"A quiz about basic science topics.","price":0,"is_purchased":false,"created_at":"2026-01-10T09:00:00Z"},{"id":2,"category_id":1,"created_by":3,"name":"Advanced Physics","description":"Deep-dive into physics concepts.","price":5000000,"is_purchased":true,"created_at":"2026-02-05T11:00:00Z"}],"limit":20,"offset":0}

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
    this.createdAt,
  });
  factory TestModel.fromJson(Map<String, Object?> json) => TestModel(
    id: json['id'] as int,
    categoryId: json['category_id'] as int,
    createdBy: json['created_by'] as int,
    name: json['name'] as String,
    description: json['description'] as String,
    price: json['price'] as int,
    isPurchased: json['is_purchased'] as bool,
    createdAt: json['created_at'].toDateTimeOrNull,
  );

  final int? id;
  final int? categoryId;
  final int? createdBy;
  final String? name;
  final String? description;
  final int? price;
  final bool? isPurchased;
  final DateTime? createdAt;
}
