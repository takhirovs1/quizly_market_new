part of '../local_source.dart';

abstract interface class UserDataSource {
  const UserDataSource._();

  bool get isUserAuthenticated;

  // Access Token
  String get accessToken;
  Future<void> setAccessToken(String accessToken);

  // Refresh Token
  String get refreshToken;
  Future<void> setRefreshToken(String refreshToken);

  // ID
  String get id;
  Future<void> setId(String id);

  // Onboarding Completed
  bool get onboardingCompleted;
  Future<void> setOnboardingCompleted({required bool completed});

  // Device ID
  String get deviceId;
  Future<void> setDeviceId(String deviceId);

  // Referral Code
  String get referralCode;
  Future<void> setReferralCode(String referralCode);
}

base mixin UserDataSourceImpl on PreferenceDao implements UserDataSource {
  /// Getter [isUserAuthenticated]
  @override
  bool get isUserAuthenticated => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  // Storage Keys
  PreferenceEntry<String> get _idKey => stringEntry(key: 'user.id');
  PreferenceEntry<String> get _accessTokenKey => stringEntry(key: 'user.access_token');
  PreferenceEntry<String> get _refreshTokenKey => stringEntry(key: 'user.refresh_token');
  PreferenceEntry<bool> get _onboardingCompletedKey => boolEntry(key: 'user.onboarding_completed');
  PreferenceEntry<String> get _deviceIdKey => stringEntry(key: 'user.device_id');
  PreferenceEntry<String> get _referralCodeKey => stringEntry(key: 'user.referral_code');
  // --- * end Storage Keys * ---

  /// Encrypted [accessToken] using [SecureStorage] to store it
  @override
  String get accessToken => readCachedOrDecrypted(_accessTokenKey);
  @override
  Future<void> setAccessToken(String accessToken) async {
    cache[_accessTokenKey.key] = accessToken;
    await SecureStorage.setUsingEncryption(accessToken, entry: _accessTokenKey);
  }

  /// Encrypted [refreshToken] using [SecureStorage] to store it
  @override
  String get refreshToken => readCachedOrDecrypted(_refreshTokenKey);
  @override
  Future<void> setRefreshToken(String refreshToken) async {
    cache[_refreshTokenKey.key] = refreshToken;
    await SecureStorage.setUsingEncryption(refreshToken, entry: _refreshTokenKey);
  }

  /// Onboarding Completed
  @override
  bool get onboardingCompleted => readFromCache<bool>(_onboardingCompletedKey) ?? false;
  @override
  Future<void> setOnboardingCompleted({required bool completed}) async {
    cache[_onboardingCompletedKey.key] = completed;
    await _onboardingCompletedKey.set(completed);
  }

  /// id
  @override
  String get id => readFromCache<String>(_idKey) ?? '';
  @override
  Future<void> setId(String id) async {
    cache[_idKey.key] = id;
    await _idKey.set(id);
  }

  /// Device ID
  @override
  String get deviceId => readFromCache<String>(_deviceIdKey) ?? '';
  @override
  Future<void> setDeviceId(String deviceId) async {
    cache[_deviceIdKey.key] = deviceId;
    await _deviceIdKey.set(deviceId);
  }

  /// Referral Code
  @override
  String get referralCode => readFromCache<String>(_referralCodeKey) ?? '';
  @override
  Future<void> setReferralCode(String referralCode) async {
    cache[_referralCodeKey.key] = referralCode;
    await _referralCodeKey.set(referralCode);
  }

  /// Clear user info
  Future<void> clearUserData() async {
    cache[_idKey.key] = '';
    cache[_accessTokenKey.key] = '';
    cache[_refreshTokenKey.key] = '';
    cache[_onboardingCompletedKey.key] = false;
    cache[_referralCodeKey.key] = '';

    await Future.wait<void>([
      _idKey.remove(),
      _accessTokenKey.remove(),
      _refreshTokenKey.remove(),
      _onboardingCompletedKey.remove(),
      _referralCodeKey.remove(),
    ]);
  }
}
