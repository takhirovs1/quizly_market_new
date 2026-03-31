final class PaymentResponseModel {
  PaymentResponseModel({required this.paymentLink, required this.paymentId, required this.paymentName});

  factory PaymentResponseModel.fromJson(Map<String, Object?> json) => PaymentResponseModel(
    paymentLink: json['payment_link'] as String,
    paymentId: json['payment_id'] as String,
    paymentName: json['payment_name'] as String,
  );

  final String paymentLink;
  final String paymentId;
  final String paymentName;
}
