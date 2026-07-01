part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = StateStatus.idle,
    this.errorMessage,
    this.linkErrorCount = 0,
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
    this.referralStatus = StateStatus.idle,
    this.referralErrorMessage,
    this.referralSummary,
    this.referralItems = const [],
    this.referralLimit = 20,
    this.referralOffset = 0,
    this.referralTotal = 0,
    this.referralListStatus = StateStatus.idle,
  });

  final StateStatus status;
  final String? errorMessage;
  final int linkErrorCount;
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
  final StateStatus referralStatus;
  final String? referralErrorMessage;
  final ReferralSummary? referralSummary;
  final List<ReferralItem> referralItems;
  final int referralLimit;
  final int referralOffset;
  final int referralTotal;
  final StateStatus referralListStatus;

  bool get referralHasMore => referralItems.length < referralTotal;
  bool get isReferralListLoadingMore => referralListStatus == StateStatus.loadingMore;

  bool get isArchiveLoadingMore => archiveStatus == .loadingMore;
  bool get archiveHasMore => archiveTests.length < archiveTotal;

  ProfileState copyWith({
    StateStatus? status,
    String? errorMessage,
    int? linkErrorCount,
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
    StateStatus? referralStatus,
    String? referralErrorMessage,
    ReferralSummary? referralSummary,
    List<ReferralItem>? referralItems,
    int? referralLimit,
    int? referralOffset,
    int? referralTotal,
    StateStatus? referralListStatus,
  }) => ProfileState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    linkErrorCount: linkErrorCount ?? this.linkErrorCount,
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
    referralStatus: referralStatus ?? this.referralStatus,
    referralErrorMessage: referralErrorMessage ?? this.referralErrorMessage,
    referralSummary: referralSummary ?? this.referralSummary,
    referralItems: referralItems ?? this.referralItems,
    referralLimit: referralLimit ?? this.referralLimit,
    referralOffset: referralOffset ?? this.referralOffset,
    referralTotal: referralTotal ?? this.referralTotal,
    referralListStatus: referralListStatus ?? this.referralListStatus,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    linkErrorCount,
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
    referralStatus,
    referralErrorMessage,
    referralSummary,
    referralItems,
    referralLimit,
    referralOffset,
    referralTotal,
    referralListStatus,
  ];
}
