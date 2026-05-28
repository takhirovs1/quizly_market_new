part of 'my_test_cubit.dart';

class MyTestState extends Equatable {
  const MyTestState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.myTests = const [],
    this.topTests = const [],
    this.topTestsLimit = 20,
    this.topTestsOffset = 0,
    this.topTestsTotal = 0,
    this.isTopTestsLoadingMore = false,
  });

  final StateStatus status;
  final String? errorMessage;
  final List<TestModel> myTests;
  final List<TestModel> topTests;
  final int topTestsLimit;
  final int topTestsOffset;
  final int topTestsTotal;
  final bool isTopTestsLoadingMore;

  MyTestState copyWith({
    StateStatus? status,
    String? errorMessage,
    List<TestModel>? myTests,
    List<TestModel>? topTests,
    int? topTestsLimit,
    int? topTestsOffset,
    int? topTestsTotal,
    bool? isTopTestsLoadingMore,
  }) => MyTestState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    myTests: myTests ?? this.myTests,
    topTests: topTests ?? this.topTests,
    topTestsLimit: topTestsLimit ?? this.topTestsLimit,
    topTestsOffset: topTestsOffset ?? this.topTestsOffset,
    topTestsTotal: topTestsTotal ?? this.topTestsTotal,
    isTopTestsLoadingMore: isTopTestsLoadingMore ?? this.isTopTestsLoadingMore,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    myTests,
    topTests,
    topTestsLimit,
    topTestsOffset,
    topTestsTotal,
    isTopTestsLoadingMore,
  ];
}
