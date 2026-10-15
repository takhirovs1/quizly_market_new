import '../../../common/extension/number_extension.dart';

/// GET /api/referral/summary — the referral screen's header data.
///
/// The v5 backend returns a rich payload (joined_count, per-friend reward and
/// milestone tiers); the legacy backend returned flat totals. This model reads
/// both so the screen lights up either way.
class ReferralSummary {
  const ReferralSummary({
    required this.totalReferrals,
    required this.totalEarned,
    this.perFriendReward,
    this.currentTier,
    this.nextTier,
  });

  factory ReferralSummary.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? json;
    final joined = (data['joined_count'] as num?)?.toInt();
    final current = data['current_milestone'];
    final next = data['next_milestone'];
    return ReferralSummary(
      // v5 sends `joined_count`; the legacy backend sent `total_referrals`.
      totalReferrals: (data['total_referrals'] as num?)?.toInt() ?? joined ?? 0,
      totalEarned: (data['total_earned'] as num?)?.toInt() ?? 0,
      perFriendReward: money(data['per_friend_reward']),
      currentTier: current is Map<String, Object?> ? ReferralTier.fromJson(current) : null,
      nextTier: next is Map<String, Object?> ? ReferralTier.fromJson(next) : null,
    );
  }

  /// A money value that may be a server display string or a raw number → display
  /// string (null when absent). Numbers are formatted ("5 000 so'm").
  static String? money(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.formatUzs;
    return value.toString();
  }

  final int totalReferrals;
  final int totalEarned;

  /// Per-friend bonus display string (amount-free on iOS); null when off.
  final String? perFriendReward;

  /// The tier the user is working toward, driving the header progress bar.
  final ReferralTier? currentTier;

  /// The tier after [currentTier]; null at the top.
  final ReferralTier? nextTier;

  Map<String, Object?> toJson() => {'total_referrals': totalReferrals, 'total_earned': totalEarned};
}

/// One referral milestone tier (5/10/25 friends by default) as the screen shows
/// it: reach [required] friends, then claim [rewardText] (amount-free on iOS).
class ReferralTier {
  const ReferralTier({required this.required, required this.rewardText, this.claimable = false});

  factory ReferralTier.fromJson(Map<String, Object?> json) => ReferralTier(
    required: (json['required'] as num?)?.toInt() ?? 0,
    rewardText: ReferralSummary.money(json['reward_text']) ?? '',
    claimable: json['claimable'] as bool? ?? false,
  );

  final int required;
  final String rewardText;
  final bool claimable;
}
