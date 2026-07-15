import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:local_source/local_source.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/support_chat_repository.dart';
import '../model/support_chat_model.dart';

part 'support_chat_state.dart';

class SupportChatCubit extends SequentialCubit<SupportChatCubitState> {
  SupportChatCubit({
    required this.repository,
    required this.localSource,
    required this.wsBaseUrl,
  }) : super(const SupportChatCubitState());

  final ISupportChatRepository repository;
  final LocalSource localSource;
  final String wsBaseUrl;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSubscription;

  Future<void> initialize() => handle<void>(
    (emit) async {
      emit(state.copyWith(status: .loading));
      final messages = await repository.getMessages(limit: 30);
      emit(
        state.copyWith(
          status: .success,
          messages: messages,
          hasMore: messages.length >= 30,
          oldestCreatedAt: messages.isNotEmpty ? messages.first.createdAt.toIso8601String() : null,
        ),
      );
      _connectWebSocket();
    },
    errorHandler: (emit, error, _) =>
        emit(state.copyWith(status: .error, errorMessage: error.toString())),
  );

  Future<void> loadMore() => handle<void>(
    (emit) async {
      if (!state.hasMore || state.status.isLoadingMore) return;
      emit(state.copyWith(status: .loadingMore));
      final messages = await repository.getMessages(limit: 20, before: state.oldestCreatedAt);
      emit(
        state.copyWith(
          status: .success,
          messages: [...messages, ...state.messages],
          hasMore: messages.length >= 20,
          oldestCreatedAt: messages.isNotEmpty ? messages.first.createdAt.toIso8601String() : state.oldestCreatedAt,
        ),
      );
    },
    errorHandler: (emit, error, _) =>
        emit(state.copyWith(status: .success)),
  );

  Future<void> sendMessage(String text, {List<String> photoPaths = const []}) => handle<void>(
    (emit) async {
      emit(state.copyWith(isSending: true));
      final request = SendMessageRequest(
        text: text.trim().isEmpty ? null : text.trim(),
        photoPaths: photoPaths.isEmpty ? null : photoPaths,
      );
      final message = await repository.sendMessage(request);
      final alreadyIn = state.messages.any((m) => m.id == message.id);
      emit(
        state.copyWith(
          isSending: false,
          messages: alreadyIn ? state.messages : [...state.messages, message],
        ),
      );
    },
    errorHandler: (emit, error, _) => emit(
      state.copyWith(
        isSending: false,
        sendErrorCount: state.sendErrorCount + 1,
        errorMessage: error.toString(),
      ),
    ),
  );

  Future<UploadedFileModel?> uploadFile(List<int> bytes, String fileName) async {
    try {
      return await repository.uploadFile(bytes, fileName);
    } on Object catch (e) {
      debugPrint('SupportChatCubit.uploadFile: $e');
      return null;
    }
  }

  void _connectWebSocket() {
    final token = localSource.accessToken;
    if (token.isEmpty) return;
    final wsUrl = wsBaseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    try {
      _channel = .connect(.parse('$wsUrl/api/support/ws?token=${Uri.encodeComponent(token)}'));
      _wsSubscription = _channel!.stream.listen(
        (data) => _onWsFrame(data as String),
        onError: (_) => Future<void>.delayed(const Duration(seconds: 5), _reconnect),
        onDone: () => Future<void>.delayed(const Duration(seconds: 5), _reconnect),
        cancelOnError: false,
      );
    } on Object catch (e) {
      debugPrint('SupportChatCubit WS connect: $e');
    }
  }

  void _reconnect() {
    if (isClosed) return;
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _connectWebSocket();
  }

  void _onWsFrame(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      if (map['type'] != 'message.created') return;
      final data = map['data'] as Map<String, Object?>?;
      final msgMap = data?['message'] as Map<String, Object?>?;
      if (msgMap == null) return;
      final message = SupportMessageModel.fromJson(msgMap);
      if (state.messages.any((m) => m.id == message.id)) return;
      emit(state.copyWith(messages: [...state.messages, message]));
    } on Object catch (e) {
      debugPrint('SupportChatCubit WS parse: $e');
    }
  }

  @override
  Future<void> close() async {
    await _wsSubscription?.cancel();
    await _channel?.sink.close();
    return super.close();
  }
}
