part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({this.status = StateStatus.idle, this.errorMessage, this.telegramDeviceId});

  final StateStatus status;
  final String? errorMessage;
  final String? telegramDeviceId;

  bool get isTelegramOtpStep => telegramDeviceId != null;

  AuthState copyWith({StateStatus? status, String? errorMessage, String? telegramDeviceId}) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    telegramDeviceId: telegramDeviceId ?? this.telegramDeviceId,
  );

  @override
  List<Object?> get props => [status, errorMessage, telegramDeviceId];
}
