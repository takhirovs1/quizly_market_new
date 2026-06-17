import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../common/service/auth_service.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/authentication_repository.dart';

part 'auth_state.dart';

class AuthCubit extends SequentialCubit<AuthState> {
  AuthCubit({required this.authenticationRepository}) : super(const AuthState());

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

  Future<void> signInWithTelegram() => handle<void>((emit) {
    try {
      emit(state.copyWith(status: .loading));
      emit(state.copyWith(status: .success));
    } on Object catch (error) {
      emit(state.copyWith(status: .error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    }
  });

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
