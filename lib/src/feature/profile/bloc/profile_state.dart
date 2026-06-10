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
  });

  final StateStatus status;
  final String? errorMessage;
  final ProfileModelResponse? user;
  final List<Transaction> transactions;
  final int transactionsLimit;
  final int transactionsOffset;
  final int transactionsTotal;

  ProfileState copyWith({
    StateStatus? status,
    String? errorMessage,
    ProfileModelResponse? user,
    List<Transaction>? transactions,
    int? transactionsLimit,
    int? transactionsOffset,
    int? transactionsTotal,
  }) => ProfileState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    user: user ?? this.user,
    transactions: transactions ?? this.transactions,
    transactionsLimit: transactionsLimit ?? this.transactionsLimit,
    transactionsOffset: transactionsOffset ?? this.transactionsOffset,
    transactionsTotal: transactionsTotal ?? this.transactionsTotal,
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
  ];
}
