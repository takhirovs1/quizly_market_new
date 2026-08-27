class UploadedTestModel {
  const UploadedTestModel({
    required this.id,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.questionCount,
    this.price,
    this.isPublished = false,
  });

  factory UploadedTestModel.fromJson(Map<String, Object?> json) => UploadedTestModel(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '') as String,
    category: (json['category'] ?? '') as String,
    subtitle: (json['subtitle'] ?? '') as String,
    questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toInt(),
    isPublished: (json['is_published'] as bool?) ?? false,
  );

  final String id;
  final String title;
  final String category;
  final String subtitle;
  final int questionCount;
  final int? price;
  final bool isPublished;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'subtitle': subtitle,
    'question_count': questionCount,
    'price': price,
    'is_published': isPublished,
  };

  static const List<UploadedTestModel> mockList = [
    UploadedTestModel(
      id: '1',
      title: "Akademik ko'nikmalar",
      category: 'Alfragnus',
      subtitle: 'Iqtisodiyot 1-kurs (kechki) 1-semester',
      questionCount: 100,
      price: null,
      isPublished: false,
    ),
    UploadedTestModel(
      id: '2',
      title: "Akademik ko'nikmalar",
      category: 'Alfragnus',
      subtitle: 'Iqtisodiyot 1-kurs (kechki) 1-semester',
      questionCount: 100,
      price: 10000,
      isPublished: true,
    ),
    UploadedTestModel(
      id: '3',
      title: "Akademik ko'nikmalar",
      category: 'Alfragnus',
      subtitle: 'Iqtisodiyot 1-kurs (kechki) 1-semester',
      questionCount: 100,
      price: 10000,
      isPublished: true,
    ),
  ];
}
