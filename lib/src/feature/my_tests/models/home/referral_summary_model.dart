import '../../../../common/extension/number_extension.dart';

/// GET /referral/summary — docs/home-flow.en.md §4.9 / §5.
///
/// Per-friend reward model: every friend who joins through the user's link is a
/// separately-claimable bonus (not milestone-gated). Reward values may arrive
/// as server display strings (v5) or raw numbers (real backend); numbers are
/// formatted client-side. On iOS the amount must already be omitted (Apple 3.1.1).
class ReferralSummaryRequest {
  const ReferralSummaryRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class ReferralSummaryResponse {
  const ReferralSummaryResponse({
    this.joinedCount = 0,
    this.unclaimedCount = 0,
    this.perFriendReward,
    this.perFriendRewardAmount,
    this.inviteCode,
    this.friends = const <ReferralFriend>[],
    this.currentMilestone,
    this.nextMilestone,
  });

  factory ReferralSummaryResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['friends'] as List<Object?>? ?? const <Object?>[];
    final current = root['current_milestone'];
    final next = root['next_milestone'];
    return ReferralSummaryResponse(
      joinedCount: (root['joined_count'] as num?)?.toInt() ?? 0,
      unclaimedCount: (root['unclaimed_count'] as num?)?.toInt() ?? 0,
      perFriendReward: money(root['per_friend_reward']),
      perFriendRewardAmount: (root['per_friend_reward_amount'] ?? root['per_friend_reward']).toIntOrNull,
      inviteCode: root['invite_code'] as String?,
      friends: list.whereType<Map<String, Object?>>().map(ReferralFriend.fromJson).toList(),
      currentMilestone: current is Map<String, Object?> ? ReferralMilestone.fromJson(current) : null,
      nextMilestone: next is Map<String, Object?> ? ReferralMilestone.fromJson(next) : null,
    );
  }

  /// A money value that may be a server display string or a raw number →
  /// display string (null when absent). Numbers are formatted ("1 000 UZS").
  static String? money(Object? value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is num) return value.formatUzs;
    return value.toString();
  }

  final int joinedCount;

  /// How many of [friends] have a claimable, unclaimed bonus.
  final int unclaimedCount;

  /// Per-friend bonus display string (server-provided; amount-free on iOS).
  final String? perFriendReward;

  /// Numeric per-friend reward (v5); null on iOS. Display uses [perFriendReward].
  final int? perFriendRewardAmount;

  /// The user's referral code, used to build the share link (`?startapp=r<code>`).
  final String? inviteCode;

  /// Friends who joined via the link, each a separately-claimable bonus.
  final List<ReferralFriend> friends;

  /// The tier the user is working toward (lowest unclaimed), driving the home
  /// card's progress bar. Null when the backend sends no milestone data.
  final ReferralMilestone? currentMilestone;

  /// The tier after [currentMilestone]; null at the top tier.
  final ReferralMilestone? nextMilestone;

  ReferralSummaryResponse copyWith({int? joinedCount, int? unclaimedCount, List<ReferralFriend>? friends}) =>
      ReferralSummaryResponse(
        joinedCount: joinedCount ?? this.joinedCount,
        unclaimedCount: unclaimedCount ?? this.unclaimedCount,
        perFriendReward: perFriendReward,
        perFriendRewardAmount: perFriendRewardAmount,
        inviteCode: inviteCode,
        friends: friends ?? this.friends,
        currentMilestone: currentMilestone,
        nextMilestone: nextMilestone,
      );
}

/// One referral tier (migration 081: 5/10/25 joined friends by default). The
/// user reaches it by inviting [required] friends, then claims [rewardText]
/// (amount-free on iOS). Powers the home card's milestone progress.
class ReferralMilestone {
  const ReferralMilestone({
    required this.id,
    required this.required,
    required this.rewardText,
    this.reward,
    this.claimable = false,
    this.claimed = false,
  });

  factory ReferralMilestone.fromJson(Map<String, Object?> json) => ReferralMilestone(
    id: json['id']?.toString() ?? '',
    required: (json['required'] as num?)?.toInt() ?? 0,
    rewardText: ReferralSummaryResponse.money(json['reward_text']) ?? '',
    reward: (json['reward'] as num?)?.toInt(),
    claimable: json['claimable'] as bool? ?? false,
    claimed: json['claimed'] as bool? ?? false,
  );

  final String id;

  /// Joined friends needed to reach this tier.
  final int required;

  /// Display-only bonus for reaching the tier (e.g. "+5 000 UZS"; "Bonus" on iOS).
  final String rewardText;

  /// Numeric reward in so'm (v5); null on iOS. Display uses [rewardText].
  final int? reward;

  /// Reached, active and not yet claimed.
  final bool claimable;
  final bool claimed;
}

/// One referred friend. `claimable && !claimed` → a "Claim" button; `claimed` →
/// shows the collected state.
class ReferralFriend {
  const ReferralFriend({
    required this.id,
    required this.name,
    required this.rewardText,
    required this.claimable,
    required this.claimed,
    this.avatarUrl,
    this.color,
    this.joinedAt,
  });

  factory ReferralFriend.fromJson(Map<String, Object?> json) => ReferralFriend(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    rewardText: ReferralSummaryResponse.money(json['reward_text']) ?? '',
    claimable: json['claimable'] as bool? ?? false,
    claimed: json['claimed'] as bool? ?? false,
    avatarUrl: json['avatar_url'] as String?,
    color: json['color'] as String?,
    joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? ''),
  );

  final String id;
  final String name;

  /// Display-only, server-provided (e.g. "+1 000 UZS", or amount-free on iOS).
  final String rewardText;
  final bool claimable;
  final bool claimed;
  final String? avatarUrl;

  /// Fallback tile color (hex) when [avatarUrl] is empty — see backend_integration.md §4.
  final String? color;
  final DateTime? joinedAt;

  ReferralFriend copyWith({bool? claimable, bool? claimed}) => ReferralFriend(
    id: id,
    name: name,
    rewardText: rewardText,
    claimable: claimable ?? this.claimable,
    claimed: claimed ?? this.claimed,
    avatarUrl: avatarUrl,
    color: color,
    joinedAt: joinedAt,
  );
}
