import '../../../common/util/app_enum.dart';

class TestCheckoutRequest {
  const TestCheckoutRequest({required this.provider, required this.redirectUrl});

  final PaymentProvider provider;
  final String redirectUrl;

  Map<String, Object?> toJson() => {'provider': provider.value, 'redirect_url': redirectUrl};
}

class TestCheckoutResponse {
  const TestCheckoutResponse({this.url, this.paymentId});

  factory TestCheckoutResponse.fromJson(Map<String, Object?> json) {
    final root = json;
    final data = root['data'] as Map<String, Object?>? ?? root;
    return TestCheckoutResponse(
      url: (data['url'] ?? data['payUrl'] ?? data['pay_url'] ?? data['redirect_url']) as String?,
      paymentId: data['payment_id'] as String?,
    );
  }

  final String? url;
  final String? paymentId;
}
