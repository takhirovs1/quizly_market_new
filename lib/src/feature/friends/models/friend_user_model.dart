/// Shared value object for a person shown anywhere in the Friends feature
/// (list, requests, search, leaderboard). Each endpoint still has its own
/// Request/Response wrapper — this is only the reused inner shape.
///
/// `color` is the server-provided avatar fallback (see backend_integration.md
/// §4): a deterministic hex rendered as a solid tile with the initial when
/// [avatarUrl] is empty.
class FriendUser {
  const FriendUser({
    required this.id,
    required this.name,
    this.username,
    this.avatarUrl,
    this.color,
    this.xp = 0,
    this.level,
    this.rank,
  });

  factory FriendUser.fromJson(Map<String, Object?> json) => FriendUser(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    username: json['username'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    color: json['color'] as String?,
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    level: (json['level'] as num?)?.toInt(),
    rank: (json['rank'] as num?)?.toInt(),
  );

  final String id;
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? color;
  final int xp;
  final int? level;
  final int? rank;
}

/// My relationship to a user surfaced in search/suggestions — drives the row's
/// trailing action (add / pending / accept / already-friend).
enum FriendRelation {
  none,
  requested, // I sent a request, awaiting their response
  incoming, // they sent me a request, awaiting mine
  friend;

  static FriendRelation fromValue(String? value) => switch (value) {
    'requested' => FriendRelation.requested,
    'incoming' => FriendRelation.incoming,
    'friend' => FriendRelation.friend,
    _ => FriendRelation.none,
  };
}
