import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../common/constant/constant.dart';
import '../../../common/service/auth_service.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/authentication_repository.dart';

part 'auth_state.dart';

class AuthCubit extends SequentialCubit<AuthState> {
  AuthCubit({required this.authenticationRepository, String? telegramDeviceId})
    : super(AuthState(telegramDeviceId: telegramDeviceId));

  final IAuthenticationRepository authenticationRepository;

  Future<void> signInWithGoogle() => handle<void>((emit) async {
    try {
      emit(state.copyWith(status: .loading));
      final response = await authenticationRepository.signInWithGoogle();
      if (response == null) return emit(state.copyWith(status: .error, errorMessage: 'signInCancelled'));
      emit(state.copyWith(status: .success));
    } on AuthServiceException catch (e) {
      emit(state.copyWith(status: .error, errorMessage: _mapAuthServiceError(e)));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: .error, errorMessage: _mapFirebaseError(e)));
    } on Object catch (error) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    }
  });

  Future<void> signInWithApple() => handle<void>((emit) async {
    try {
      emit(state.copyWith(status: .loading));
      final response = await authenticationRepository.signInWithApple();
      if (response == null) return emit(state.copyWith(status: .error, errorMessage: 'signInCancelled'));
      emit(state.copyWith(status: .success));
    } on AuthServiceException catch (e) {
      emit(state.copyWith(status: .error, errorMessage: _mapAuthServiceError(e)));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: .error, errorMessage: _mapFirebaseError(e)));
    } on Object catch (error) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    }
  });

  Future<void> signInWithTelegram() => handle<void>((emit) async {
    try {
      final deviceId = _generateDeviceId();
      final username = Constant.botUrl.split('/').last;
      final tgUri = Uri.parse('tg://resolve?domain=$username&start=$deviceId');

      var launched = false;
      try {
        launched = await url_launcher.launchUrl(tgUri, mode: url_launcher.LaunchMode.externalApplication);
      } on Object catch (_) {
        launched = false;
      }

      if (!launched) {
        final httpUri = Uri.parse('${Constant.botUrl}?start=$deviceId');
        await url_launcher.launchUrl(httpUri, mode: url_launcher.LaunchMode.externalApplication);
      }

      emit(state.copyWith(telegramDeviceId: deviceId, status: .idle, errorMessage: null));
    } on Object catch (error) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    }
  });

  Future<void> verifyTelegramOtp(String code) => handle<void>((emit) async {
    try {
      final deviceId = state.telegramDeviceId;
      if (deviceId == null) return;
      emit(state.copyWith(status: .loading));
      await authenticationRepository.signInWithTelegramOtp(deviceId: deviceId, code: code);
      emit(const AuthState(status: .success));
    } on Object catch (error) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    }
  });

  Future<void> cancelTelegramLogin() => handle<void>((emit) {
    emit(const AuthState());
  });

  static String _generateDeviceId() {
    final rng = math.Random.secure();
    return List.generate(16, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  static String _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
    'account-exists-with-different-credential' => 'accountExistsWithDifferentCredential',
    'popup-closed-by-user' || 'web-context-cancelled' => 'signInCancelled',
    'network-request-failed' => 'connectionError',
    _ => 'somethingWentWrong',
  };

  static String _mapAuthServiceError(AuthServiceException e) => switch (e.code) {
    .telegramWebviewBlocked => 'telegramWebviewBlocked',
    .cancelled => 'signInCancelled',
    .networkError => 'connectionError',
    _ => 'somethingWentWrong',
  };
}
