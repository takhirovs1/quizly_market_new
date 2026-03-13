import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_source/local_source.dart';

import '../data/authentication_repository.dart';
import '../model/user.dart';
import 'authentication_state.dart';

final class AuthenticationController extends ChangeNotifier {
  AuthenticationController({
    required LocalSource localSource,
    required IAuthenticationRepository repository,
    AuthenticationState initialState = const AuthenticationState.idle(user: User.unauthenticated()),
  }) : _repository = repository,
       _localSource = localSource,

       _state = initialState {
    _userSubscription = repository
        .userChanges()
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .where((newState) => state.isProcessing || !identical(newState.user, state.user))
        .listen(setState, cancelOnError: false);
  }

  final IAuthenticationRepository _repository;
  final LocalSource _localSource;

  StreamSubscription<AuthenticationState>? _userSubscription;
  StreamSubscription<User?>? _userStreamSubscription;

  /// The current state of the controller.
  AuthenticationState get state => _state;
  AuthenticationState _state;

  void setState(AuthenticationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Restore the session from the cache.
  Future<void> restore() async {
    setState(AuthenticationState.processing(user: state.user, message: 'Restoring session...'));

    await _repository.restore();
    setState(AuthenticationState.idle(user: state.user));
  }

  Future<void> login() async {}

  /// Sign out.
  Future<void> signOut() async {
    await _repository.signOut();
    await _localSource.clearAllPersonalData();

    await _userStreamSubscription?.cancel();
    _userStreamSubscription = null;

    setState(AuthenticationState.processing(user: state.user, message: 'Logging out...'));
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
