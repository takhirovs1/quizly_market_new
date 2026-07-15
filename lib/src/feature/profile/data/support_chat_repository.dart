import 'package:dio/dio.dart';

import '../model/support_chat_model.dart';

abstract interface class ISupportChatRepository {
  Future<SupportChatModel> getChat();
  Future<List<SupportMessageModel>> getMessages({int limit = 20, String? before});
  Future<SupportMessageModel> sendMessage(SendMessageRequest request);
  Future<UploadedFileModel> uploadFile(List<int> bytes, String fileName);
}

final class SupportChatRepositoryImpl implements ISupportChatRepository {
  const SupportChatRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<SupportChatModel> getChat() async {
    final response = await dio.get<Map<String, Object?>>('/api/support/chat');
    final data = response.data?['data'] as Map<String, Object?>? ?? {};
    return SupportChatModel.fromJson(data);
  }

  @override
  Future<List<SupportMessageModel>> getMessages({int limit = 20, String? before}) async {
    final params = <String, Object?>{'limit': limit};
    if (before != null) params['before'] = before;
    final response = await dio.get<Map<String, Object?>>(
      '/api/support/messages',
      queryParameters: params,
    );
    final data = response.data?['data'] as Map<String, Object?>? ?? {};
    final list = data['messages'] as List<Object?>? ?? [];
    return list.map((e) => SupportMessageModel.fromJson(e as Map<String, Object?>)).toList();
  }

  @override
  Future<SupportMessageModel> sendMessage(SendMessageRequest request) async {
    final response = await dio.post<Map<String, Object?>>(
      '/api/support/messages',
      data: request.toJson(),
    );
    final data = response.data?['data'] as Map<String, Object?>? ?? {};
    return SupportMessageModel.fromJson(data);
  }

  @override
  Future<UploadedFileModel> uploadFile(List<int> bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await dio.post<Map<String, Object?>>('/api/files', data: formData);
    final data = response.data?['data'] as Map<String, Object?>? ?? {};
    return UploadedFileModel.fromJson(data);
  }
}
