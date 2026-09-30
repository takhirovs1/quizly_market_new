part of 'main_cubit.dart';

class MainState extends Equatable {
  const MainState({this.status = .idle, this.loginWithTelegramResponse});

  final StateStatus status;
  final LoginWithTelegramResponse? loginWithTelegramResponse;

  MainState copyWith({
    StateStatus? status,
    LoginWithTelegramResponse? loginWithTelegramResponse,
    String? errorMessage,
  }) => MainState(
    status: status ?? this.status,
    loginWithTelegramResponse: loginWithTelegramResponse ?? this.loginWithTelegramResponse,
  );

  @override
  List<Object?> get props => [status, loginWithTelegramResponse];
}
