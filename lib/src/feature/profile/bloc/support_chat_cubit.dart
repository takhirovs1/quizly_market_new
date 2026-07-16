import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:local_source/local_source.dart';
import 'package:thunder/thunder.dart';

import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/support_chat_repository.dart';
import '../model/support_chat_model.dart';

part 'support_chat_state.dart';

class SupportChatCubit extends SequentialCubit<SupportChatCubitState> {
  SupportChatCubit({required this.repository, required this.localSource, required this.wsBaseUrl})
    : super(const SupportChatCubitState());

  final ISupportChatRepository repository;
  final LocalSource localSource;
  final String wsBaseUrl;

  SocketClient? _socket;
  StreamSubscription<Object?>? _msgSubscription;

  Future<void> initialize() => handle<void>((emit) async {
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
  }, errorHandler: (emit, error, _) => emit(state.copyWith(status: .error, errorMessage: error.toString())));

  Future<void> loadMore() => handle<void>((emit) async {
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
  }, errorHandler: (emit, error, _) => emit(state.copyWith(status: .success)));

  Future<void> sendMessage(
    String text, {
    List<SupportPhotoModel> photos = const [],
    String? replyToId,
  }) => handle<void>((emit) async {
    final photoPaths = photos.map((p) => p.path).toList();
    final chatId = state.messages.isNotEmpty ? state.messages.last.chatId : '';

    final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
    final tempMessage = SupportMessageModel(
      id: tempId,
      chatId: chatId,
      sender: 'user',
      text: text.trim().isEmpty ? null : text.trim(),
      photos: photos,
      replyTo: replyToId != null
          ? () {
              final replied = state.messages.firstWhere((m) => m.id == replyToId, orElse: () => state.messages.last);
              return SupportReplyToModel(
                id: replyToId,
                sender: replied.sender,
                hasPhoto: replied.photos.isNotEmpty,
                textPreview: replied.text,
              );
            }()
          : null,
      createdAt: DateTime.now(),
      isPending: true,
      viewed: false,
    );

    // Add temporary message to the list
    emit(state.copyWith(messages: [...state.messages, tempMessage]));

    try {
      final request = SendMessageRequest(
        text: text.trim().isEmpty ? null : text.trim(),
        photoPaths: photoPaths.isEmpty ? null : photoPaths,
        replyToId: replyToId,
      );
      final message = await repository.sendMessage(request);

      // Replace temp message with server message if still present in the list
      final exists = state.messages.any((m) => m.id == tempId);
      if (exists) {
        final updated = state.messages.map((m) {
          if (m.id == tempId) {
            return message;
          }
          return m;
        }).toList();
        emit(state.copyWith(messages: updated));
      }
    } on Object catch (error) {
      // Mark temp message as failed
      final updated = state.messages.map((m) {
        if (m.id == tempId) {
          return m.copyWith(isPending: false, isFailed: true);
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: updated, errorMessage: error.toString(), sendErrorCount: state.sendErrorCount + 1));
      rethrow;
    }
  });

  Future<void> retryMessage(SupportMessageModel msg) => handle<void>((emit) async {
    final updated = state.messages.where((m) => m.id != msg.id).toList();
    emit(state.copyWith(messages: updated));
    await sendMessage(msg.text ?? '', photos: msg.photos, replyToId: msg.replyTo?.id);
  });

  Future<void> markAsRead() => handle<void>((emit) async {
    await repository.markMessagesAsRead();
    final updated = state.messages.map((m) {
      if (!m.isUser && !m.viewed) {
        return m.copyWith(viewed: true);
      }
      return m;
    }).toList();
    emit(state.copyWith(messages: updated));
  });

  void sendTyping(bool typing) {
    final socket = _socket;
    if (socket == null || socket.state is! SocketConnected) return;
    try {
      final frame = jsonEncode({'type': 'typing', 'typing': typing});
      socket.send(frame);
    } on Object catch (e) {
      debugPrint('SupportChatCubit.sendTyping error: $e');
    }
  }

  Future<UploadedFileModel?> uploadFile(List<int> bytes, String fileName) async {
    try {
      return await repository.uploadFile(bytes, fileName);
    } on Object catch (e) {
      debugPrint('SupportChatCubit.uploadFile: $e');
      return null;
    }
  }

  Future<void> deleteMessage(String messageId) => handle<void>((emit) async {
    await repository.deleteMessage(messageId);
    final updated = state.messages.where((m) => m.id != messageId).toList();
    emit(state.copyWith(messages: updated));
  });

  Future<void> editMessage(String messageId, String text) => handle<void>((emit) async {
    final updatedMessage = await repository.editMessage(messageId, text);
    final updated = state.messages.map((m) => m.id == messageId ? updatedMessage : m).toList();
    emit(state.copyWith(messages: updated));
  });

  StreamSubscription<SocketState>? _stateSubscription;
  bool _wasConnected = false;
  Timer? _typingTimer;

  void _connectWebSocket() {
    final token = localSource.accessToken;
    if (token.isEmpty) return;
    final wsUrl = wsBaseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final uri = Uri.parse('$wsUrl/api/support/ws?token=${Uri.encodeComponent(token)}');
    _socket = Thunder.socketClient(uri: uri, label: 'Support Chat', reconnectInterval: const Duration(seconds: 5));
    _msgSubscription = _socket!.messages.listen((data) => _onWsFrame(data?.toString() ?? ''));
    _stateSubscription = _socket!.states.listen(_onSocketStateChanged);
    _socket!.connect().ignore();
  }

  void _onSocketStateChanged(SocketState socketState) {
    if (socketState is SocketConnected) {
      if (_wasConnected) {
        _reconcileMessages();
      }
      _wasConnected = true;
    }
  }

  Future<void> _reconcileMessages() async {
    try {
      final freshMessages = await repository.getMessages(limit: 30);
      final Map<String, SupportMessageModel> merged = {};
      for (final m in state.messages) {
        merged[m.id] = m;
      }
      for (final m in freshMessages) {
        merged[m.id] = m;
      }
      final sortedList = merged.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(state.copyWith(messages: sortedList));
    } on Object catch (e) {
      debugPrint('SupportChatCubit._reconcileMessages error: $e');
    }
  }

  bool _photosMatch(List<SupportPhotoModel> a, List<SupportPhotoModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].path != b[i].path) return false;
    }
    return true;
  }

  void _onWsFrame(String raw) {
    if (raw.isEmpty) return;
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      final type = map['type'] as String?;

      if (type == 'message.created') {
        final data = map['data'] as Map<String, Object?>?;
        final msgMap = data?['message'] as Map<String, Object?>?;
        if (msgMap == null) return;
        final message = SupportMessageModel.fromJson(msgMap);

        if (state.messages.any((m) => m.id == message.id)) return;

        _typingTimer?.cancel();

        // De-duplicate / replace pending message if it was sent by user
        if (message.isUser) {
          int pendingIndex = -1;
          for (int i = 0; i < state.messages.length; i++) {
            final m = state.messages[i];
            if (m.isPending && m.text == message.text && _photosMatch(m.photos, message.photos)) {
              pendingIndex = i;
              break;
            }
          }
          if (pendingIndex != -1) {
            final updated = List<SupportMessageModel>.from(state.messages);
            updated[pendingIndex] = message;
            emit(state.copyWith(messages: updated, isAdminTyping: false));
            return;
          }
        }

        emit(state.copyWith(messages: [...state.messages, message], isAdminTyping: false));
      } else if (type == 'messages.viewed') {
        final data = map['data'] as Map<String, Object?>?;
        final role = data?['role'] as String?;
        if (role == 'admin') {
          final messageIds = (data?['message_ids'] as List<Object?>? ?? []).map((e) => e.toString()).toSet();
          if (messageIds.isNotEmpty) {
            final updated = state.messages.map((m) {
              if (messageIds.contains(m.id)) {
                return m.copyWith(viewed: true);
              }
              return m;
            }).toList();
            emit(state.copyWith(messages: updated));
          }
        }
      } else if (type == 'typing') {
        final data = map['data'] as Map<String, Object?>?;
        final role = data?['role'] as String?;
        if (role == 'admin') {
          final typing = data?['typing'] as bool? ?? false;
          _typingTimer?.cancel();
          if (typing) {
            emit(state.copyWith(isAdminTyping: true));
            _typingTimer = Timer(const Duration(seconds: 5), () {
              emit(state.copyWith(isAdminTyping: false));
            });
          } else {
            emit(state.copyWith(isAdminTyping: false));
          }
        }
      }
    } on Object catch (e) {
      debugPrint('SupportChatCubit WS parse: $e');
    }
  }

  @override
  Future<void> close() async {
    _typingTimer?.cancel();
    await _stateSubscription?.cancel();
    await _msgSubscription?.cancel();
    await _socket?.close();
    return super.close();
  }
}
