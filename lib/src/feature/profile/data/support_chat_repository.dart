import '../../../common/service/api_client.dart';
import '../model/support_chat_model.dart';

abstract interface class ISupportChatRepository {
  Future<SupportChatModel> getChat();
  Future<List<SupportMessageModel>> getMessages({int limit = 20, String? before});
  Future<SupportMessageModel> sendMessage(SendMessageRequest request);
  Future<UploadedFileModel> uploadFile(List<int> bytes, String fileName);
  Future<void> deleteMessage(String messageId);
  Future<SupportMessageModel> editMessage(String messageId, String text);
  Future<void> markMessagesAsRead();
}

final class SupportChatRepositoryImpl implements ISupportChatRepository {
  const SupportChatRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<SupportChatModel> getChat() async {
    final response = await apiClient.get('/api/support/chat');
    final data = response['data'] as Map<String, Object?>? ?? {};
    return SupportChatModel.fromJson(data);
  }

  @override
  Future<List<SupportMessageModel>> getMessages({int limit = 20, String? before}) async {
    final params = <String, Object?>{'limit': limit};
    if (before != null) params['before'] = before;
    final response = await apiClient.get('/api/support/messages', queryParameters: params);
    final data = response['data'] as Map<String, Object?>? ?? {};
    final list = data['messages'] as List<Object?>? ?? [];
    return list.map((e) => SupportMessageModel.fromJson(e as Map<String, Object?>)).toList();
  }

  @override
  Future<SupportMessageModel> sendMessage(SendMessageRequest request) async {
    final response = await apiClient.post('/api/support/messages', body: request.toJson());
    final data = response['data'] as Map<String, Object?>? ?? {};
    return SupportMessageModel.fromJson(data);
  }

  @override
  Future<UploadedFileModel> uploadFile(List<int> bytes, String fileName) async {
    final response = await apiClient.multipartPost('/api/files', field: 'file', bytes: bytes, filename: fileName);
    final data = response['data'] as Map<String, Object?>? ?? {};
    return UploadedFileModel.fromJson(data);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await apiClient.delete('/api/support/messages/$messageId');
  }

  @override
  Future<SupportMessageModel> editMessage(String messageId, String text) async {
    final response = await apiClient.put('/api/support/messages/$messageId', body: {'text': text});
    final data = response['data'] as Map<String, Object?>? ?? {};
    return SupportMessageModel.fromJson(data);
  }

  @override
  Future<void> markMessagesAsRead() async {
    await apiClient.post('/api/support/messages/read');
  }
}
