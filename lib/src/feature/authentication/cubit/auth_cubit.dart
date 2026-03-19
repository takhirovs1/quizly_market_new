import 'package:equatable/equatable.dart';

import '../../../common/service/auth_service.dart';
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
      final response = await AuthService.signInWithGoogleNew();
      if (response == null) return emit(state.copyWith(status: .error, errorMessage: 'Failed to sign in with Google'));
      emit(state.copyWith(status: .success));
    } on Object catch (error) {
      return emit(state.copyWith(status: .error, errorMessage: error.toString()));
    }
  });

  Future<void> signInWithApple() => handle<void>((emit) async {
    try {
      emit(state.copyWith(status: .loading));
      final response = await AuthService.signInWithApple();
      if (response == null) return emit(state.copyWith(status: .error, errorMessage: 'Failed to sign in with Google'));
      emit(state.copyWith(status: .success));
    } on Object catch (error) {
      return emit(state.copyWith(status: .error, errorMessage: error.toString()));
    }
  });

  Future<void> signInWithTelegram() => handle<void>((emit) async {
    try {
      emit(state.copyWith(status: .loading));
      // final response = await AuthService.signInWithTelegram();
      // if (response == null) return emit(state.copyWith(status: .error, errorMessage: 'Failed to sign in with Google'));
      emit(state.copyWith(status: .success));
    } on Object catch (error) {
      return emit(state.copyWith(status: .error, errorMessage: error.toString()));
    }
  });
}
