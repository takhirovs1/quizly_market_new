import 'referral_summary_model.dart';

/// POST /referral/friends/{id}/claim — docs/home-flow.en.md §4.9 / §5.
/// Idempotent (unique user_id + friend_id). Collects the bonus for one referred
/// friend and returns that friend advanced to `claimed`, plus a toast string and
/// the remaining unclaimed count. Separate model from the summary endpoint per
/// the "one model per endpoint" rule.
class ReferralClaimRequest {
  const ReferralClaimRequest({required this.friendId});

  final String friendId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class ReferralClaimResponse {
  const ReferralClaimResponse({this.friend, this.unclaimedCount = 0, this.rewardText});

  factory ReferralClaimResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final friend = root['friend'] as Map<String, Object?>?;
    return ReferralClaimResponse(
      friend: friend == null ? null : ReferralFriend.fromJson(friend),
      unclaimedCount: (root['unclaimed_count'] as num?)?.toInt() ?? 0,
      rewardText: root['reward_text'] as String?,
    );
  }

  /// The claimed friend, now `claimed: true`.
  final ReferralFriend? friend;

  /// Remaining claimable-but-unclaimed friends after this claim.
  final int unclaimedCount;

  /// Server-provided toast text after a successful claim (amount-free on iOS).
  final String? rewardText;
}
