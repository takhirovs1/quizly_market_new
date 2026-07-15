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
    // Read the resolved user after restore() so the idle state reflects the
    // Firebase-persisted session immediately rather than waiting for the stream.
    final user = await _repository.getUser();
    setState(.idle(user: user));
  }

  Future<void> login() async {}

  /// Sign out.
  Future<void> signOut() async {
    setState(.processing(user: state.user, message: 'Logging out...'));
    try {
      await _repository.signOut();
      await _localSource.clearAllPersonalData();

      await _userStreamSubscription?.cancel();
      _userStreamSubscription = null;
    } finally {
      setState(const .idle(user: .unauthenticated()));
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
