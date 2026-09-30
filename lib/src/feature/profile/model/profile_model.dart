// {"id":"8435fc63-69b3-404e-a138-0993adcd97b3","name":"Takhirov","status":"active","role":"customer","username":"Takhirovs","avatar_url":"https://t.me/i/userpic/...","premium":false,"balance":570000,"telegram_chat_id":1251798314,"referral_code":"C9C48356FF","language":"uz","created_at":"2025-12-30T05:00:19.462763Z","updated_at":"2026-06-14T15:24:36.111157Z"}

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
    this.email,
    this.phone,
    this.gender,
    this.role,
    this.username,
    this.avatarUrl,
    this.premium,
    this.balance,
    this.telegramChatId,
    this.googleId,
    this.authMethods,
    this.referralCode,
    this.paymentCode,
    this.language,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModelResponse.fromJson(Map<String, Object?> json) => ProfileModelResponse(
    id: json['id'] as String?,
    name: json['name'] as String?,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    fatherName: json['father_name'] as String?,
    status: json['status'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    gender: json['gender'] as String?,
    role: json['role'] as String?,
    username: json['username'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    premium: json['premium'] as bool?,
    balance: json['balance'].toIntOrNull,
    telegramChatId: json['telegram_chat_id'].toIntOrNull,
    googleId: json['google_id'] as String?,
    authMethods: (json['auth_methods'] as List<Object?>?)?.cast<String>(),
    referralCode: json['referral_code'] as String?,
    paymentCode: json['payment_code'] as String?,
    language: json['language'] as String?,
    createdAt: json['created_at'].toDateTimeOrNull,
    updatedAt: json['updated_at'].toDateTimeOrNull,
  );

  final String? id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? fatherName;
  final String? status;
  final String? email;
  final String? phone;
  final String? gender;
  final String? role;
  final String? username;
  final String? avatarUrl;
  final bool? premium;
  final int? balance;
  final int? telegramChatId;
  final String? googleId;
  final List<String>? authMethods;
  final String? referralCode;
  final String? paymentCode;
  final String? language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isGoogleLinked => authMethods?.contains('google') ?? false;
  bool get isAppleLinked => authMethods?.contains('apple') ?? false;
  bool get isTelegramLinked => authMethods?.contains('telegram') ?? false;

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    final first = firstName ?? '';
    final last = lastName ?? '';
    if (first.isEmpty && last.isEmpty) return '';
    return '$first $last'.trim();
  }
}
