import '../../../common/extension/number_extension.dart';

class UserModelRequest {}

class UserModelResponse {
  UserModelResponse({
    this.id,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.status,
    this.phone,
    this.gender,
    this.role,
    this.username,
    this.avatarUrl,
    this.premium,
    this.balance,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModelResponse.fromJson(Map<String, Object?> json) => UserModelResponse(
    id: json['id'].toIntOrNull,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    fatherName: json['father_name'] as String?,
    status: json['status'] as String?,
    phone: json['phone'] as String?,
    gender: json['gender'] as String?,
    role: json['role'] as String?,
    username: json['username'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    premium: json['premium'] as bool?,
    balance: json['balance'].toIntOrNull,
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
  );

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? fatherName;
  final String? status;
  final String? phone;
  final String? gender;
  final String? role;
  final String? username;
  final String? avatarUrl;
  final bool? premium;
  final int? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

DateTime? _parseDateTime(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
