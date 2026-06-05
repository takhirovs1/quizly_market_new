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
  LoginWithTelegramResponse({required this.accessToken, required this.refreshToken, this.language});

  factory LoginWithTelegramResponse.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? json;
    return LoginWithTelegramResponse(
      accessToken: data['access_token'] as String? ?? '',
      refreshToken: data['refresh_token'] as String? ?? '',
      language: data['language'] as String?,
    );
  }
  final String accessToken;
  final String refreshToken;
  final String? language;
}
