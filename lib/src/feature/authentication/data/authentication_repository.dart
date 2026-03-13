import 'dart:async';

import '../../../common/service/api_service.dart';
import '../model/user.dart';

abstract interface class IAuthenticationRepository {
  const IAuthenticationRepository();

  Stream<User> userChanges();

  FutureOr<User> getUser();

  Future<User> fetchUser({required final String token});

  Future<void> restore();

  Future<User> login();

  Future<void> signOut();
}

class AuthenticationRepositoryImpl implements IAuthenticationRepository {
  AuthenticationRepositoryImpl({required this.apiService});

  final ApiService apiService;

  final StreamController<User> _userController = StreamController<User>.broadcast();
  User _user = const User.unauthenticated();

  @override
  Stream<User> userChanges() => _userController.stream;

  @override
  FutureOr<User> getUser() => _user;

  @override
  Future<void> signOut() => Future<void>.sync(() {
    const user = User.unauthenticated();

    _userController.add(_user = user);
  });

  @override
  Future<void> restore() async {}

  @override
  Future<User> login() async => const User.authenticated(id: '', token: '', refreshToken: '');

  @override
  Future<User> fetchUser({required final String token}) {
    throw const FormatException('AuthenticationRepositoryImpl > fetchUser > Invalid response body');
  }
}
