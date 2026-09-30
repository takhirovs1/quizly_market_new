part of 'test_view.dart';

class TestViewState extends Equatable {
  const TestViewState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.attempts = const [],
    this.limit = 20,
    this.offset = 0,
    this.total = 0,
    this.detail,
  });

  final StateStatus status;
  final String? errorMessage;
  final List<TestAttempt> attempts;
  final int limit;
  final int offset;
  final int total;
  final DemoTestDetail? detail;

  TestViewState copyWith({
    StateStatus? status,
    String? errorMessage,
    List<TestAttempt>? attempts,
    int? limit,
    int? offset,
    int? total,
    DemoTestDetail? detail,
  }) => TestViewState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    attempts: attempts ?? this.attempts,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    total: total ?? this.total,
    detail: detail ?? this.detail,
  );

  @override
  List<Object?> get props => [status, errorMessage, attempts, limit, offset, total, detail];
}
