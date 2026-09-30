part of 'create_test_cubit.dart';

class CreateTestState extends Equatable {
  const CreateTestState({this.status = StateStatus.idle, this.createdTest, this.errorMessage});

  final StateStatus status;
  final ManualTestCreateResponse? createdTest;
  final String? errorMessage;

  CreateTestState copyWith({StateStatus? status, ManualTestCreateResponse? createdTest, String? errorMessage}) =>
      CreateTestState(
        status: status ?? this.status,
        createdTest: createdTest ?? this.createdTest,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, createdTest, errorMessage];
}
