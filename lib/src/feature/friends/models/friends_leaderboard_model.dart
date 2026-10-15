import 'friend_user_model.dart';

/// Weekly XP leaderboard board. Serves both GET /friends/leaderboard (friends,
/// the user included) and GET /leaderboard (global): the friends board sends
/// me_rank/me_xp/resets_at flat, the global board nests the caller in `me` and
/// uses `points`; this model reads both.
class FriendsLeaderboardRequest {
  const FriendsLeaderboardRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendsLeaderboardResponse {
  const FriendsLeaderboardResponse({
    this.entries = const <LeaderboardEntry>[],
    this.meRank,
    this.meXp = 0,
    this.resetsAt,
  });

  factory FriendsLeaderboardResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['entries'] as List<Object?>? ?? const <Object?>[];
    final me = root['me'] is Map<String, Object?> ? root['me']! as Map<String, Object?> : const <String, Object?>{};
    return FriendsLeaderboardResponse(
      entries: list.whereType<Map<String, Object?>>().map(LeaderboardEntry.fromJson).toList(),
      meRank: (root['me_rank'] as num?)?.toInt() ?? (me['rank'] as num?)?.toInt(),
      meXp: (root['me_xp'] as num?)?.toInt() ?? ((me['xp'] ?? me['points']) as num?)?.toInt() ?? 0,
      resetsAt: DateTime.tryParse(root['resets_at'] as String? ?? ''),
    );
  }

  final List<LeaderboardEntry> entries;
  final int? meRank;

  /// The caller's own XP this period — shown on the pinned "me" row when they
  /// fall outside the visible list.
  final int meXp;
  final DateTime? resetsAt;
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.user, required this.rank, required this.xp, this.isMe = false});

  factory LeaderboardEntry.fromJson(Map<String, Object?> json) => LeaderboardEntry(
    user: FriendUser.fromJson(json['user'] as Map<String, Object?>? ?? const <String, Object?>{}),
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    // Friends board uses `xp`; the global board uses `points`.
    xp: ((json['xp'] ?? json['points']) as num?)?.toInt() ?? 0,
    isMe: json['is_me'] as bool? ?? false,
  );

  final FriendUser user;
  final int rank;
  final int xp;
  final bool isMe;
}
