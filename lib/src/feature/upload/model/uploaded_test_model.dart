/// Model for customer tests returned in `GET /api/tests/my`.
class UploadedTestModel {
  const UploadedTestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.questionCount,
    this.code,
    this.price,
    this.status = 'draft',
    this.publishedAt,
    this.createdAt,
  });

  factory UploadedTestModel.fromJson(Map<String, Object?> json) {
    DateTime? publishedAt;
    if (json['published_at'] != null) {
      publishedAt = DateTime.tryParse(json['published_at'].toString());
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    final categoryObj = json['category'];
    var categoryName = '';
    if (categoryObj is Map) {
      categoryName = (categoryObj['name'] ?? '').toString();
    } else if (categoryObj is String) {
      categoryName = categoryObj;
    }

    final statusVal = (json['status'] ?? 'draft').toString();

    return UploadedTestModel(
      id: (json['id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? '').toString(),
      category: categoryName.isNotEmpty ? categoryName : (json['university'] ?? '').toString(),
      subtitle: (json['description'] ?? json['subtitle'] ?? '').toString(),
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString(),
      price: (json['price'] as num?)?.toInt(),
      status: statusVal,
      publishedAt: publishedAt,
      createdAt: createdAt,
    );
  }

  final String id;
  final String title;
  final String category;
  final String subtitle;
  final int questionCount;
  final String? code;
  final int? price;
  final String status;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  bool get isDraft => status == 'draft';
  bool get isUploaded => status == 'uploaded';
  bool get isMarket => status == 'market';
  bool get isBlocked => status == 'blocked';
  bool get isPublished => isUploaded || isMarket;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': title,
    'category': category,
    'description': subtitle,
    'question_count': questionCount,
    'code': code,
    'price': price,
    'status': status,
    'published_at': publishedAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
  };
}
