import '../../../common/extension/string_extension.dart';

class SessionModel {
  const SessionModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.createdAt,
    required this.isCurrent,
  });

  factory SessionModel.fromJson(Map<String, Object?> json) => SessionModel(
    id: json['id'] as String? ?? json['session_id'] as String? ?? '',
    deviceName: json['device_name'] as String? ?? json['name'] as String? ?? '',
    deviceType: json['device_type'] as String? ?? json['type'] as String? ?? '',
    createdAt: ((json['created_at'] ?? json['signed_up_at']) as String?)?.toDateTimeOrNull() ?? DateTime.now(),
    isCurrent: json['is_current'] as bool? ?? false,
  );

  final String id;
  final String deviceName;
  final String deviceType;
  final DateTime createdAt;
  final bool isCurrent;

  Map<String, Object?> toJson() => {
    'id': id,
    'device_name': deviceName,
    'device_type': deviceType,
    'created_at': createdAt.toIso8601String(),
    'is_current': isCurrent,
  };
}

class SessionResponse {
  const SessionResponse({required this.sessions});

  factory SessionResponse.fromJson(Map<String, Object?> json) {
    final list = json['data'] as List<Object?>? ?? [];
    return SessionResponse(sessions: list.map((e) => SessionModel.fromJson(e as Map<String, Object?>)).toList());
  }

  final List<SessionModel> sessions;
}
