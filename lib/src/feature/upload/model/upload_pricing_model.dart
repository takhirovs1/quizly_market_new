/// Pricing model returned from `GET /api/tests/pricing`
class UploadPricingModel {
  const UploadPricingModel({this.perQuestionPrice = 100, this.cashbackPercent = 20, this.minQuestions = 30});

  factory UploadPricingModel.fromJson(Map<String, Object?> json) {
    final data = (json['data'] as Map<String, Object?>?) ?? json;
    return UploadPricingModel(
      perQuestionPrice: (data['per_question_price'] as num?)?.toInt() ?? 100,
      cashbackPercent: (data['cashback_percent'] as num?)?.toInt() ?? 20,
      minQuestions: (data['min_questions'] as num?)?.toInt() ?? 30,
    );
  }

  final int perQuestionPrice;
  final int cashbackPercent;
  final int minQuestions;

  /// Calculate total publish fee for given number of questions.
  int calculatePublishFee(int questionCount) => perQuestionPrice * questionCount;

  Map<String, Object?> toJson() => {
    'per_question_price': perQuestionPrice,
    'cashback_percent': cashbackPercent,
    'min_questions': minQuestions,
  };
}
