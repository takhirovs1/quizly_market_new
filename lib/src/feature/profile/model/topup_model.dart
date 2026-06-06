import '../../../common/util/app_enum.dart';

class TopUpRequest {
  const TopUpRequest({required this.amount, required this.provider});
  final int amount;
  final PaymentProvider provider;

  Map<String, Object?> toJson() => {'amount': amount, 'provider': provider.value};
}

class TopUpResponse {
  const TopUpResponse({this.payUrl, this.paymentId});

  factory TopUpResponse.fromJson(Map<String, Object?> json) {
    final root = json;
    final data = root['data'] as Map<String, Object?>? ?? root;
    return TopUpResponse(
      payUrl: (data['url'] ?? data['payUrl'] ?? data['pay_url']) as String?,
      paymentId: data['payment_id'] as String?,
    );
  }
  final String? payUrl;
  final String? paymentId;
}
