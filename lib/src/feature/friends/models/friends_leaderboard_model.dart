import 'friend_user_model.dart';

/// GET /friends/leaderboard — weekly XP standing among friends (the user
/// included). Window Mon 00:00 → Sun 23:59 in the user's timezone; ties share a
/// rank. Mirrors the home "friends rating" card but as a full list.
class FriendsLeaderboardRequest {
  const FriendsLeaderboardRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendsLeaderboardResponse {
  const FriendsLeaderboardResponse({this.entries = const <LeaderboardEntry>[], this.meRank, this.resetsAt});

  factory FriendsLeaderboardResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['entries'] as List<Object?>? ?? const <Object?>[];
    return FriendsLeaderboardResponse(
      entries: list.whereType<Map<String, Object?>>().map(LeaderboardEntry.fromJson).toList(),
      meRank: (root['me_rank'] as num?)?.toInt(),
      resetsAt: DateTime.tryParse(root['resets_at'] as String? ?? ''),
    );
  }

  final List<LeaderboardEntry> entries;
  final int? meRank;
  final DateTime? resetsAt;
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.user, required this.rank, required this.xp, this.isMe = false});

  factory LeaderboardEntry.fromJson(Map<String, Object?> json) => LeaderboardEntry(
    user: FriendUser.fromJson(json['user'] as Map<String, Object?>? ?? const <String, Object?>{}),
    rank: (json['rank'] as num?)?.toInt() ?? 0,
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    isMe: json['is_me'] as bool? ?? false,
  );

  final FriendUser user;
  final int rank;
  final int xp;
  final bool isMe;
}
