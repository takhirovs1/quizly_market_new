final class TelegramVerifyRequest {
  const TelegramVerifyRequest({required this.deviceId, required this.code});

  final String deviceId;
  final String code;

  Map<String, Object?> toJson() => {'device_id': deviceId, 'code': code};
}
