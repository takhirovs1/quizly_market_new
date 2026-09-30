class TestPurchaseRequest {
  const TestPurchaseRequest({required this.testId});

  final String testId;

  Map<String, Object?> toJson() => {};
}

class TestPurchaseResponse {
  const TestPurchaseResponse({this.data});

  factory TestPurchaseResponse.fromJson(Map<String, Object?> json) => TestPurchaseResponse(
    data: json['data'] == null ? null : TestPurchaseData.fromJson(json['data'] as Map<String, Object?>),
  );

  final TestPurchaseData? data;

  Map<String, Object?> toJson() => {'data': data?.toJson()};
}

class TestPurchaseData {
  const TestPurchaseData({this.id, this.testId, this.userId, this.createdAt});

  factory TestPurchaseData.fromJson(Map<String, Object?> json) => TestPurchaseData(
    id: (json['id'] as num?)?.toInt() ?? (json['purchase_id'] as num?)?.toInt(),
    testId: (json['test_id'] as num?)?.toInt() ?? (json['testId'] as num?)?.toInt(),
    userId: json['user_id'] as String? ?? json['userId'] as String?,
    createdAt: json['created_at'] as String?,
  );

  final int? id;
  final int? testId;
  final String? userId;
  final String? createdAt;

  Map<String, Object?> toJson() => {'id': id, 'test_id': testId, 'user_id': userId, 'created_at': createdAt};
}
