import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:local_source/local_source.dart';

import '../../../common/constant/urls.dart';
import '../../../common/service/api_service.dart';
import '../../../common/service/auth_service.dart';
import '../model/auth_service_response.dart';
import '../model/auth_token_response.dart';
import '../model/telegram_verify_request.dart';
import '../model/user.dart';

abstract interface class IAuthenticationRepository {
  const IAuthenticationRepository();

  Stream<User> userChanges();

  FutureOr<User> getUser();

  Future<User> fetchUser({required final String token});

  Future<void> restore();

  Future<User> login();

  Future<void> signOut();

  Future<AuthServiceResponse?> signInWithGoogle();

  Future<AuthServiceResponse?> signInWithApple();

  Future<void> signInWithTelegramOtp({required String deviceId, required String code});
}

class AuthenticationRepositoryImpl implements IAuthenticationRepository {
  AuthenticationRepositoryImpl({required this.apiService, required this.localSource});

  final ApiService apiService;
  final LocalSource localSource;

  final StreamController<User> _userController = StreamController<User>.broadcast();
  User _user = const .unauthenticated();

  @override
  Stream<User> userChanges() => _userController.stream;

  @override
  FutureOr<User> getUser() => _user;

  @override
  Future<void> restore() async {
    if (localSource.isUserAuthenticated) {
      _userController.add(
        _user = .authenticated(
          id: localSource.id,
          token: localSource.accessToken,
          refreshToken: localSource.refreshToken,
        ),
      );
    } else {
      _userController.add(_user = const .unauthenticated());
    }
  }

  @override
  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    _userController.add(_user = const .unauthenticated());
  }

  @override
  Future<User> login() async => _user;

  @override
  Future<User> fetchUser({required final String token}) {
    throw const FormatException('AuthenticationRepositoryImpl > fetchUser > not implemented');
  }

  @override
  Future<AuthServiceResponse?> signInWithGoogle() => _signIn(
    provider: AuthService.signInWithGoogle,
    endpoint: '/api/auth/google',
    dataBuilder: (token) => {'id_token': token},
  );

  @override
  Future<AuthServiceResponse?> signInWithApple() => _signIn(
    provider: AuthService.signInWithApple,
    endpoint: '/api/auth/apple',
    dataBuilder: (token) => {'identity_token': token, 'referral_code': ''},
  );

  @override
  Future<void> signInWithTelegramOtp({required String deviceId, required String code}) async {
    final json = await apiService.request<Map<String, Object?>>(
      Urls.mobileVerify,
      method: .post,
      data: TelegramVerifyRequest(deviceId: deviceId, code: code).toJson(),
    );
    final tokenResponse = AuthTokenResponse.fromJson(json);

    await Future.wait([
      localSource.setAccessToken(tokenResponse.accessToken),
      localSource.setRefreshToken(tokenResponse.refreshToken),
      localSource.setId(tokenResponse.userId),
    ]);

    _userController.add(
      _user = .authenticated(
        id: tokenResponse.userId,
        token: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      ),
    );
  }

  Future<AuthServiceResponse?> _signIn({
    required Future<AuthServiceResponse?> Function() provider,
    required String endpoint,
    required Map<String, Object?> Function(String token) dataBuilder,
  }) async {
    final serviceResponse = await provider();
    if (serviceResponse == null) return null;

    final json = await apiService.request<Map<String, Object?>>(
      endpoint,
      method: .post,
      data: dataBuilder(serviceResponse.idToken),
    );
    final tokenResponse = AuthTokenResponse.fromJson(json);

    await Future.wait([
      localSource.setAccessToken(tokenResponse.accessToken),
      localSource.setRefreshToken(tokenResponse.refreshToken),
      localSource.setId(tokenResponse.userId),
    ]);

    _userController.add(
      _user = .authenticated(
        id: tokenResponse.userId,
        token: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      ),
    );

    return serviceResponse;
  }
}
