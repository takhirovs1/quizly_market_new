part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.user,
    this.transactions = const [],
    this.transactionsLimit = 20,
    this.transactionsOffset = 0,
    this.transactionsTotal = 0,
    this.archiveStatus = StateStatus.idle,
    this.archiveErrorMessage,
    this.archiveTests = const [],
    this.archiveLimit = 20,
    this.archiveOffset = 0,
    this.archiveTotal = 0,
  });

  final StateStatus status;
  final String? errorMessage;
  final ProfileModelResponse? user;
  final List<Transaction> transactions;
  final int transactionsLimit;
  final int transactionsOffset;
  final int transactionsTotal;
  final StateStatus archiveStatus;
  final String? archiveErrorMessage;
  final List<TestModel> archiveTests;
  final int archiveLimit;
  final int archiveOffset;
  final int archiveTotal;

  bool get isArchiveLoadingMore => archiveStatus == StateStatus.loadingMore;
  bool get archiveHasMore => archiveTests.length < archiveTotal;

  ProfileState copyWith({
    StateStatus? status,
    String? errorMessage,
    ProfileModelResponse? user,
    List<Transaction>? transactions,
    int? transactionsLimit,
    int? transactionsOffset,
    int? transactionsTotal,
    StateStatus? archiveStatus,
    String? archiveErrorMessage,
    List<TestModel>? archiveTests,
    int? archiveLimit,
    int? archiveOffset,
    int? archiveTotal,
  }) => ProfileState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    user: user ?? this.user,
    transactions: transactions ?? this.transactions,
    transactionsLimit: transactionsLimit ?? this.transactionsLimit,
    transactionsOffset: transactionsOffset ?? this.transactionsOffset,
    transactionsTotal: transactionsTotal ?? this.transactionsTotal,
    archiveStatus: archiveStatus ?? this.archiveStatus,
    archiveErrorMessage: archiveErrorMessage ?? this.archiveErrorMessage,
    archiveTests: archiveTests ?? this.archiveTests,
    archiveLimit: archiveLimit ?? this.archiveLimit,
    archiveOffset: archiveOffset ?? this.archiveOffset,
    archiveTotal: archiveTotal ?? this.archiveTotal,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    user,
    transactions,
    transactionsLimit,
    transactionsOffset,
    transactionsTotal,
    archiveStatus,
    archiveErrorMessage,
    archiveTests,
    archiveLimit,
    archiveOffset,
    archiveTotal,
  ];
}
