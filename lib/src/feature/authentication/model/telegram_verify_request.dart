final class TelegramVerifyRequest {
  const TelegramVerifyRequest({required this.deviceId, required this.code, this.referralCode});

  final String deviceId;
  final String code;
  final String? referralCode;

  Map<String, Object?> toJson() => {'device_id': deviceId, 'code': code, 'referral_code': referralCode ?? ''};
}
