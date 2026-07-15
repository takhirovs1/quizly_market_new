class SupportPhotoModel {
  const SupportPhotoModel({required this.path, required this.url});

  factory SupportPhotoModel.fromJson(Map<String, Object?> json) => SupportPhotoModel(
    path: json['path'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );

  final String path;
  final String url;
}

class SupportReplyToModel {
  const SupportReplyToModel({
    required this.id,
    required this.sender,
    required this.hasPhoto,
    this.textPreview,
  });

  factory SupportReplyToModel.fromJson(Map<String, Object?> json) => SupportReplyToModel(
    id: json['id'] as String? ?? '',
    sender: json['sender'] as String? ?? '',
    hasPhoto: json['has_photo'] as bool? ?? false,
    textPreview: json['text_preview'] as String?,
  );

  final String id;
  final String sender;
  final bool hasPhoto;
  final String? textPreview;
}

class SupportMessageModel {
  const SupportMessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.photos,
    required this.createdAt,
    this.text,
    this.replyTo,
  });

  factory SupportMessageModel.fromJson(Map<String, Object?> json) => SupportMessageModel(
    id: json['id'] as String? ?? '',
    chatId: json['chat_id'] as String? ?? '',
    sender: json['sender'] as String? ?? '',
    text: json['text'] as String?,
    photos: (json['photos'] as List<Object?>? ?? [])
        .map((e) => SupportPhotoModel.fromJson(e as Map<String, Object?>))
        .toList(),
    replyTo: json['reply_to'] is Map<String, Object?>
        ? SupportReplyToModel.fromJson(json['reply_to'] as Map<String, Object?>)
        : null,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;
  final String chatId;
  final String sender;
  final String? text;
  final List<SupportPhotoModel> photos;
  final SupportReplyToModel? replyTo;
  final DateTime createdAt;

  bool get isUser => sender == 'user';
  bool get isAdmin => sender == 'admin';
  bool get isSystem => sender == 'system';

  String get formattedTime {
    final local = createdAt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class SupportChatModel {
  const SupportChatModel({
    required this.id,
    required this.status,
    required this.unreadCount,
    required this.createdAt,
    this.lastMessageAt,
  });

  factory SupportChatModel.fromJson(Map<String, Object?> json) => SupportChatModel(
    id: json['id'] as String? ?? '',
    status: json['status'] as String? ?? 'new',
    unreadCount: json['unread_count'] as int? ?? 0,
    lastMessageAt: json['last_message_at'] is String
        ? DateTime.tryParse(json['last_message_at'] as String)
        : null,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;
  final String status;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
}

class SendMessageRequest {
  const SendMessageRequest({this.text, this.photoPaths, this.replyToId});

  final String? text;
  final List<String>? photoPaths;
  final String? replyToId;

  Map<String, Object?> toJson() => {
    if (text != null && text!.isNotEmpty) 'text': text,
    if (photoPaths != null && photoPaths!.isNotEmpty) 'photo_paths': photoPaths,
    if (replyToId != null) 'reply_to_id': replyToId,
  };
}

class UploadedFileModel {
  const UploadedFileModel({required this.path, required this.url});

  factory UploadedFileModel.fromJson(Map<String, Object?> json) => UploadedFileModel(
    path: json['path'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );

  final String path;
  final String url;
}
