part of 'auth_cubit.dart';

class AuthState extends Equatable {
  const AuthState({this.status = StateStatus.idle, this.errorMessage});

  final StateStatus status;
  final String? errorMessage;

  AuthState copyWith({StateStatus? status, String? errorMessage}) =>
      AuthState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}
