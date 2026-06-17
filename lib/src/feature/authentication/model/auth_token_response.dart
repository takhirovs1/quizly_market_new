import 'dart:convert';

final class AuthTokenResponse {
  const AuthTokenResponse({required this.accessToken, required this.refreshToken, required this.userId});

  factory AuthTokenResponse.fromJson(Map<String, Object?> json) {
    final inner = json['data'] as Map<String, Object?>? ?? json;
    final accessToken = (inner['access_token'] as String?) ?? '';
    return AuthTokenResponse(
      accessToken: accessToken,
      refreshToken: (inner['refresh_token'] as String?) ?? '',
      userId: _extractUserIdFromJwt(accessToken),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String userId;

  static String _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = base64Url.normalize(parts[1]);
      final data = jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, Object?>;
      return (data['user_id'] ?? data['uid'] ?? data['sub'] ?? '').toString();
    } on Object catch (_) {
      return '';
    }
  }
}
