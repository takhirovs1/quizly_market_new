/// Pricing model returned from `GET /api/tests/pricing`.
///
/// Carries both prices from the payment contract
/// (`docs/test-upload-payment-client.md` §1):
/// - the **publish fee** the owner pays once (`per_question_price × count`), and
/// - the **sale price** each buyer pays, seeded from `suggested_question_price`
///   but never allowed below `min_test_price`.
class UploadPricingModel {
  const UploadPricingModel({
    this.perQuestionPrice = 100,
    this.cashbackPercent = 20,
    this.minQuestions = 30,
    this.suggestedQuestionPrice = 200,
    this.minTestPrice = 5000,
  });

  factory UploadPricingModel.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return UploadPricingModel(
      perQuestionPrice: (data['per_question_price'] as num?)?.toInt() ?? 100,
      cashbackPercent: (data['cashback_percent'] as num?)?.toInt() ?? 20,
      minQuestions: (data['min_questions'] as num?)?.toInt() ?? 30,
      suggestedQuestionPrice: (data['suggested_question_price'] as num?)?.toInt() ?? 200,
      minTestPrice: (data['min_test_price'] as num?)?.toInt() ?? 5000,
    );
  }

  /// Publish fee charged per question when the owner publishes.
  final int perQuestionPrice;
  final int cashbackPercent;
  final int minQuestions;

  /// Per-question hint used to seed the sale price the buyers pay.
  final int suggestedQuestionPrice;

  /// Hard floor for any customer test's sale price ("Minimal narx").
  final int minTestPrice;

  /// Total publish fee the owner pays for [questionCount] questions.
  int calculatePublishFee(int questionCount) => perQuestionPrice * questionCount;

  /// Suggested sale price: `max(suggested_question_price × count, min_test_price)`.
  int suggestedPrice(int questionCount) {
    final byQuestions = suggestedQuestionPrice * questionCount;
    return byQuestions > minTestPrice ? byQuestions : minTestPrice;
  }

  Map<String, Object?> toJson() => {
    'per_question_price': perQuestionPrice,
    'cashback_percent': cashbackPercent,
    'min_questions': minQuestions,
    'suggested_question_price': suggestedQuestionPrice,
    'min_test_price': minTestPrice,
  };
}
