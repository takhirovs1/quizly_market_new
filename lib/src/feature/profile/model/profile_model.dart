// {"id":1,"first_name":"Akbarshoh","last_name":"Ismoilov","father_name":null,"status":"active","phone":"+998901234567","gender":"male","role":"customer","username":"akbar","avatar_url":"/uploads/abc123.jpg","premium":false,"balance":150000,"created_at":"2026-01-15T10:00:00Z","updated_at":"2026-03-20T12:00:00Z"}

import '../../../common/extension/number_extension.dart';
import '../../../common/extension/string_extension.dart';

class ProfileModelResponse {
  ProfileModelResponse({
    this.id,
    this.name,
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
    this.telegramChatId,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModelResponse.fromJson(Map<String, Object?> json) => ProfileModelResponse(
    id: json['id'].toIntOrNull,
    name: json['name'] as String?,
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
    telegramChatId: json['telegram_chat_id'].toIntOrNull,
    createdAt: json['created_at'].toDateTimeOrNull,
    updatedAt: json['updated_at'].toDateTimeOrNull,
  );

  final int? id;
  final String? name;
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
  final int? telegramChatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    final first = firstName ?? '';
    final last = lastName ?? '';
    if (first.isEmpty && last.isEmpty) return '';
    return '$first $last'.trim();
  }
}
