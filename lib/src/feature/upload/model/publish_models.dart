/// Quote details returned from `GET /api/tests/:id/publish-quote`.
class PublishQuoteModel {
  const PublishQuoteModel({
    required this.testId,
    required this.code,
    required this.status,
    required this.questionCount,
    required this.perQuestionPrice,
    required this.publishFee,
    required this.cashbackPercent,
    this.publishedAt,
  });

  factory PublishQuoteModel.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    DateTime? publishedAt;
    if (data['published_at'] != null) {
      publishedAt = DateTime.tryParse(data['published_at'].toString());
    }

    return PublishQuoteModel(
      testId: (data['test_id'] ?? data['id'] ?? '').toString(),
      code: (data['code'] ?? '').toString(),
      status: (data['status'] ?? 'draft').toString(),
      questionCount: (data['question_count'] as num?)?.toInt() ?? 0,
      perQuestionPrice: (data['per_question_price'] as num?)?.toInt() ?? 100,
      publishFee: (data['publish_fee'] as num?)?.toInt() ?? 0,
      cashbackPercent: (data['cashback_percent'] as num?)?.toInt() ?? 20,
      publishedAt: publishedAt,
    );
  }

  final String testId;
  final String code;
  final String status;
  final int questionCount;
  final int perQuestionPrice;
  final int publishFee;
  final int cashbackPercent;
  final DateTime? publishedAt;

  Map<String, Object?> toJson() => {
    'test_id': testId,
    'code': code,
    'status': status,
    'question_count': questionCount,
    'per_question_price': perQuestionPrice,
    'publish_fee': publishFee,
    'cashback_percent': cashbackPercent,
    'published_at': publishedAt?.toIso8601String(),
  };
}

/// Response returned from wallet payment `POST /api/payments/tests/:id/publish`.
class PublishWalletResponse {
  const PublishWalletResponse({
    required this.testId,
    required this.status,
    required this.fee,
    required this.balance,
    required this.code,
  });

  factory PublishWalletResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return PublishWalletResponse(
      testId: (data['test_id'] ?? '').toString(),
      status: (data['status'] ?? 'uploaded').toString(),
      fee: (data['fee'] as num?)?.toInt() ?? 0,
      balance: (data['balance'] as num?)?.toInt() ?? 0,
      code: (data['code'] ?? '').toString(),
    );
  }

  final String testId;
  final String status;
  final int fee;
  final int balance;
  final String code;
}

/// Response returned from card checkout `POST /api/payments/tests/:id/publish/checkout`.
class PublishCheckoutResponse {
  const PublishCheckoutResponse({required this.url, required this.paymentId});

  factory PublishCheckoutResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return PublishCheckoutResponse(
      url: (data['url'] ?? '').toString(),
      paymentId: (data['payment_id'] ?? '').toString(),
    );
  }

  final String url;
  final String paymentId;
}

/// Status response returned from `GET /api/payments/:payment_id/status`.
class PaymentStatusResponse {
  const PaymentStatusResponse({required this.status, this.retryAfter});

  factory PaymentStatusResponse.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return PaymentStatusResponse(
      status: (data['status'] ?? '').toString(),
      retryAfter: (data['retry_after'] as num?)?.toInt(),
    );
  }

  final String status;
  final int? retryAfter;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed' || status == 'cancelled';
}
