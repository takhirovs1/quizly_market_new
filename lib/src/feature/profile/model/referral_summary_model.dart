class ReferralSummary {
  const ReferralSummary({required this.totalReferrals, required this.totalEarned});

  factory ReferralSummary.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? json;
    return ReferralSummary(
      totalReferrals: (data['total_referrals'] as num?)?.toInt() ?? 0,
      totalEarned: (data['total_earned'] as num?)?.toInt() ?? 0,
    );
  }

  final int totalReferrals;
  final int totalEarned;

  Map<String, Object?> toJson() => {'total_referrals': totalReferrals, 'total_earned': totalEarned};
}
