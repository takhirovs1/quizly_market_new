part of 'my_test_cubit.dart';

class MyTestState extends Equatable {
  const MyTestState({this.status = .idle, this.errorMessage});

  final StateStatus status;
  final String? errorMessage;

  MyTestState copyWith({StateStatus? status, String? errorMessage}) =>
      MyTestState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);

  @override
  List<Object?> get props => [status, errorMessage];
}
