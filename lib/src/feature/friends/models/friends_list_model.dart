import 'friend_user_model.dart';

/// GET /friends — the user's confirmed friends.
class FriendsListRequest {
  const FriendsListRequest({this.search});

  final String? search;

  Map<String, Object?> toJson() => <String, Object?>{if (search != null && search!.isNotEmpty) 'q': search};
}

class FriendsListResponse {
  const FriendsListResponse({this.friends = const <FriendUser>[], this.totalCount = 0});

  factory FriendsListResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['friends'] as List<Object?>? ?? const <Object?>[];
    return FriendsListResponse(
      friends: list.whereType<Map<String, Object?>>().map(FriendUser.fromJson).toList(),
      totalCount: (root['total_count'] as num?)?.toInt() ?? list.length,
    );
  }

  final List<FriendUser> friends;
  final int totalCount;
}
