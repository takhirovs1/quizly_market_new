/// GET /home/friends-rating — docs/home-flow.en.md §4.7 / §5 (friends summary).
/// No friends → [friendsCount] == 0 and the client shows the invite state.
class FriendsRatingRequest {
  const FriendsRatingRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendsRatingResponse {
  const FriendsRatingResponse({
    this.friendsCount = 0,
    this.meRank,
    this.meXp,
    this.nextRankGap,
    this.isTie = false,
    this.tieWith,
    this.topAvatars = const [],
    this.resetsAt,
  });

  factory FriendsRatingResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final me = root['me'] as Map<String, Object?>?;
    final avatars = root['top_avatars'] as List<Object?>? ?? const <Object?>[];
    return FriendsRatingResponse(
      friendsCount: (root['friends_count'] as num?)?.toInt() ?? 0,
      meRank: (me?['rank'] as num?)?.toInt(),
      meXp: (me?['xp'] as num?)?.toInt(),
      nextRankGap: (root['next_rank_gap'] as num?)?.toInt(),
      isTie: root['is_tie'] as bool? ?? false,
      tieWith: root['tie_with'] as String?,
      topAvatars: avatars.whereType<Map<String, Object?>>().map(FriendAvatar.fromJson).toList(),
      resetsAt: DateTime.tryParse(root['resets_at'] as String? ?? ''),
    );
  }

  final int friendsCount;
  final int? meRank;
  final int? meXp;
  final int? nextRankGap;
  final bool isTie;
  final String? tieWith;
  final List<FriendAvatar> topAvatars;
  final DateTime? resetsAt;
}

class FriendAvatar {
  const FriendAvatar({required this.name, required this.avatarUrl});

  factory FriendAvatar.fromJson(Map<String, Object?> json) => FriendAvatar(
    name: json['name'] as String? ?? '',
    avatarUrl: (json['avatar_url'] as String?)?.isNotEmpty == true ? json['avatar_url'] as String? : null,
  );

  final String name;
  final String? avatarUrl;
}
