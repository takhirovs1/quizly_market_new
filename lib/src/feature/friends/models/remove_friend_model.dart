/// DELETE /friends/{id} — remove a confirmed friend.
class RemoveFriendRequest {
  const RemoveFriendRequest({required this.friendId});

  final String friendId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class RemoveFriendResponse {
  const RemoveFriendResponse({this.ok = true});

  factory RemoveFriendResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return RemoveFriendResponse(ok: root['ok'] as bool? ?? true);
  }

  final bool ok;
}
