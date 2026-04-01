class LoginWithTelegramRequest {
  const LoginWithTelegramRequest({required this.initData});

  factory LoginWithTelegramRequest.fromJson(Map<String, Object?> json) =>
      LoginWithTelegramRequest(initData: json['init_data'] as String? ?? '');

  /// Raw Telegram Mini App init data query string.
  /// Example: `auth_date=...&user=...&hash=...`
  final String initData;

  Map<String, Object?> toJson() => {'init_data': initData};
}

class LoginWithTelegramResponse {
  LoginWithTelegramResponse({required this.accessToken, required this.refreshToken});

  factory LoginWithTelegramResponse.fromJson(Map<String, Object?> json) => LoginWithTelegramResponse(
    accessToken: json['access_token'] as String? ?? '',
    refreshToken: json['refresh_token'] as String? ?? '',
  );
  final String accessToken;
  final String refreshToken;
}
