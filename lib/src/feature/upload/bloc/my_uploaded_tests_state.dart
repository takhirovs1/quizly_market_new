part of 'my_uploaded_tests_cubit.dart';

class MyUploadedTestsCubitState extends Equatable {
  const MyUploadedTestsCubitState({
    this.status = StateStatus.idle,
    this.tests = const [],
    this.selectedStatus,
    this.offset = 0,
    this.hasMore = false,
    this.errorMessage,
  });

  final StateStatus status;
  final List<UploadedTestModel> tests;
  final String? selectedStatus;
  final int offset;
  final bool hasMore;
  final String? errorMessage;

  MyUploadedTestsCubitState copyWith({
    StateStatus? status,
    List<UploadedTestModel>? tests,
    String? selectedStatus,
    int? offset,
    bool? hasMore,
    String? errorMessage,
  }) => MyUploadedTestsCubitState(
    status: status ?? this.status,
    tests: tests ?? this.tests,
    selectedStatus: selectedStatus ?? this.selectedStatus,
    offset: offset ?? this.offset,
    hasMore: hasMore ?? this.hasMore,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, tests, selectedStatus, offset, hasMore, errorMessage];
}
