import 'package:equatable/equatable.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/authentication_repository.dart';
import '../model/session_model.dart';

class SessionCubitState extends Equatable {
  const SessionCubitState({
    this.status = StateStatus.idle,
    this.sessions = const [],
    this.errorMessage,
    this.revokeStatus = StateStatus.idle,
    this.revokeErrorMessage,
  });

  final StateStatus status;
  final List<SessionModel> sessions;
  final String? errorMessage;
  final StateStatus revokeStatus;
  final String? revokeErrorMessage;

  SessionCubitState copyWith({
    StateStatus? status,
    List<SessionModel>? sessions,
    String? errorMessage,
    StateStatus? revokeStatus,
    String? revokeErrorMessage,
  }) => SessionCubitState(
    status: status ?? this.status,
    sessions: sessions ?? this.sessions,
    errorMessage: errorMessage ?? this.errorMessage,
    revokeStatus: revokeStatus ?? this.revokeStatus,
    revokeErrorMessage: revokeErrorMessage ?? this.revokeErrorMessage,
  );

  @override
  List<Object?> get props => [status, sessions, errorMessage, revokeStatus, revokeErrorMessage];
}

class SessionCubit extends SequentialCubit<SessionCubitState> {
  SessionCubit({required this.repository}) : super(const SessionCubitState());

  final IAuthenticationRepository repository;

  Future<void> loadSessions() => handle<void>(
    (emit) async {
      emit(state.copyWith(status: StateStatus.loading));
      final sessions = await repository.getSessions();
      emit(state.copyWith(status: StateStatus.success, sessions: sessions));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWith(status: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  Future<bool> revokeSession(String sessionId) async {
    final result = await handle<bool>(
      (emit) async {
        emit(state.copyWith(revokeStatus: StateStatus.loading));
        await repository.revokeSession(sessionId);

        // After revoking, refresh current tokens to log back in
        await repository.refreshSessionToken();

        emit(state.copyWith(revokeStatus: StateStatus.success));
        return true;
      },
      errorHandler: (emit, error, stackTrace) {
        emit(
          state.copyWith(revokeStatus: StateStatus.error, revokeErrorMessage: ErrorUtil.toUserFriendlyMessage(error)),
        );
      },
    );
    return result ?? false;
  }
}
