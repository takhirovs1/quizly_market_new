part of 'support_chat_cubit.dart';

class SupportChatCubitState extends Equatable {
  const SupportChatCubitState({
    this.status = StateStatus.idle,
    this.messages = const [],
    this.isSending = false,
    this.hasMore = true,
    this.oldestCreatedAt,
    this.errorMessage,
    this.sendErrorCount = 0,
  });

  final StateStatus status;
  final List<SupportMessageModel> messages;
  final bool isSending;
  final bool hasMore;
  final String? oldestCreatedAt;
  final String? errorMessage;
  final int sendErrorCount;

  SupportChatCubitState copyWith({
    StateStatus? status,
    List<SupportMessageModel>? messages,
    bool? isSending,
    bool? hasMore,
    String? oldestCreatedAt,
    String? errorMessage,
    int? sendErrorCount,
  }) => SupportChatCubitState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    isSending: isSending ?? this.isSending,
    hasMore: hasMore ?? this.hasMore,
    oldestCreatedAt: oldestCreatedAt ?? this.oldestCreatedAt,
    errorMessage: errorMessage ?? this.errorMessage,
    sendErrorCount: sendErrorCount ?? this.sendErrorCount,
  );

  @override
  List<Object?> get props => [
    status,
    messages,
    isSending,
    hasMore,
    oldestCreatedAt,
    errorMessage,
    sendErrorCount,
  ];
}
