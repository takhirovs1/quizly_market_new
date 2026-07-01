part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.telegramDeviceId,
    this.sessions = const [],
    this.sessionStatus = StateStatus.idle,
    this.revokeStatus = StateStatus.idle,
    this.revokeErrorMessage,
  });

  final StateStatus status;
  final String? errorMessage;
  final String? telegramDeviceId;
  final List<SessionModel> sessions;
  final StateStatus sessionStatus;
  final StateStatus revokeStatus;
  final String? revokeErrorMessage;

  bool get isTelegramOtpStep => telegramDeviceId != null;

  AuthState copyWith({
    StateStatus? status,
    String? errorMessage,
    String? telegramDeviceId,
    List<SessionModel>? sessions,
    StateStatus? sessionStatus,
    StateStatus? revokeStatus,
    String? revokeErrorMessage,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    telegramDeviceId: telegramDeviceId ?? this.telegramDeviceId,
    sessions: sessions ?? this.sessions,
    sessionStatus: sessionStatus ?? this.sessionStatus,
    revokeStatus: revokeStatus ?? this.revokeStatus,
    revokeErrorMessage: revokeErrorMessage ?? this.revokeErrorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    telegramDeviceId,
    sessions,
    sessionStatus,
    revokeStatus,
    revokeErrorMessage,
  ];
}
