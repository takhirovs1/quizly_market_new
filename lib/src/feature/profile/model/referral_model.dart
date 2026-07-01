import '../../../common/extension/number_extension.dart';
import '../../../common/extension/string_extension.dart';

/// A single referral item returned by `GET /api/users/me/referrals`.
class ReferralItem {
  const ReferralItem({
    required this.referredUserId,
    required this.referredName,
    required this.referredAvatar,
    required this.referrerId,
    required this.referrerName,
    required this.bonusAmount,
    required this.signedUpAt,
  });

  factory ReferralItem.fromJson(Map<String, Object?> json) => ReferralItem(
    referredUserId: json['referred_user_id'] as String? ?? '',
    referredName: json['referred_name'] as String? ?? '',
    referredAvatar: json['referred_avatar'] as String? ?? '',
    referrerId: json['referrer_id'] as String? ?? '',
    referrerName: json['referrer_name'] as String? ?? '',
    bonusAmount: json['bonus_amount'].toIntOrNull ?? 0,
    signedUpAt: json['signed_up_at'].toDateTimeOrNull,
  );

  final String referredUserId;
  final String referredName;
  final String referredAvatar;
  final String referrerId;
  final String referrerName;
  final int bonusAmount;
  final DateTime? signedUpAt;
}

/// Paginated response for `GET /api/users/me/referrals`.
class ReferralListResponse {
  const ReferralListResponse({
    required this.items,
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory ReferralListResponse.fromJson(Map<String, Object?> json) {
    // The API wraps the list in "data"
    final dataRaw = json['data'];
    final dataList = dataRaw is List<Object?> ? dataRaw : <Object?>[];
    final items =
        dataList.whereType<Map<String, Object?>>().map(ReferralItem.fromJson).toList();
    return ReferralListResponse(
      items: items,
      limit: json['limit'].toIntOrNull ?? 20,
      offset: json['offset'].toIntOrNull ?? 0,
      total: json['total'].toIntOrNull ?? 0,
    );
  }

  final List<ReferralItem> items;
  final int limit;
  final int offset;
  final int total;
}
