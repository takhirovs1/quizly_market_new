part of 'test_attempt_cubit.dart';

class TestAttemptState extends Equatable {
  const TestAttemptState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.attempts = const [],
    this.limit = 20,
    this.offset = 0,
    this.total = 0,
  });

  final StateStatus status;
  final String? errorMessage;
  final List<TestAttempt> attempts;
  final int limit;
  final int offset;
  final int total;

  TestAttemptState copyWith({
    StateStatus? status,
    String? errorMessage,
    List<TestAttempt>? attempts,
    int? limit,
    int? offset,
    int? total,
  }) =>
      TestAttemptState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        attempts: attempts ?? this.attempts,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        total: total ?? this.total,
      );

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        attempts,
        limit,
        offset,
        total,
      ];
}
