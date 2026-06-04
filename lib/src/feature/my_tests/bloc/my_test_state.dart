part of 'my_test_cubit.dart';

class MyTestState extends Equatable {
  const MyTestState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.search = '',
    this.myTests = const [],
    this.myTestsLimit = 20,
    this.myTestsOffset = 0,
    this.myTestsTotal = 0,
    this.isMyTestsLoadingMore = false,
    this.topTests = const [],
    this.topTestsLimit = 20,
    this.topTestsOffset = 0,
    this.topTestsTotal = 0,
    this.isTopTestsLoadingMore = false,
  });

  final StateStatus status;
  final String? errorMessage;
  final String search;
  final List<TestModel> myTests;
  final int myTestsLimit;
  final int myTestsOffset;
  final int myTestsTotal;
  final bool isMyTestsLoadingMore;
  final List<TestModel> topTests;
  final int topTestsLimit;
  final int topTestsOffset;
  final int topTestsTotal;
  final bool isTopTestsLoadingMore;

  MyTestState copyWith({
    StateStatus? status,
    String? errorMessage,
    String? search,
    List<TestModel>? myTests,
    int? myTestsLimit,
    int? myTestsOffset,
    int? myTestsTotal,
    bool? isMyTestsLoadingMore,
    List<TestModel>? topTests,
    int? topTestsLimit,
    int? topTestsOffset,
    int? topTestsTotal,
    bool? isTopTestsLoadingMore,
  }) => MyTestState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    search: search ?? this.search,
    myTests: myTests ?? this.myTests,
    myTestsLimit: myTestsLimit ?? this.myTestsLimit,
    myTestsOffset: myTestsOffset ?? this.myTestsOffset,
    myTestsTotal: myTestsTotal ?? this.myTestsTotal,
    isMyTestsLoadingMore: isMyTestsLoadingMore ?? this.isMyTestsLoadingMore,
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
    search,
    myTests,
    myTestsLimit,
    myTestsOffset,
    myTestsTotal,
    isMyTestsLoadingMore,
    topTests,
    topTestsLimit,
    topTestsOffset,
    topTestsTotal,
    isTopTestsLoadingMore,
  ];
}
