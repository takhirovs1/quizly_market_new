import 'friend_user_model.dart';

/// GET /friends/requests — pending friend requests, both directions.
class FriendRequestsRequest {
  const FriendRequestsRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendRequestsResponse {
  const FriendRequestsResponse({
    this.incoming = const <FriendRequestItem>[],
    this.outgoing = const <FriendRequestItem>[],
  });

  factory FriendRequestsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    List<FriendRequestItem> parse(String key) => (root[key] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<String, Object?>>()
        .map(FriendRequestItem.fromJson)
        .toList();
    return FriendRequestsResponse(incoming: parse('incoming'), outgoing: parse('outgoing'));
  }

  final List<FriendRequestItem> incoming;
  final List<FriendRequestItem> outgoing;
}

class FriendRequestItem {
  const FriendRequestItem({required this.requestId, required this.user, this.createdAt});

  factory FriendRequestItem.fromJson(Map<String, Object?> json) => FriendRequestItem(
    requestId: json['request_id'] as String? ?? json['id'] as String? ?? '',
    user: FriendUser.fromJson(json['user'] as Map<String, Object?>? ?? const <String, Object?>{}),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );

  final String requestId;
  final FriendUser user;
  final DateTime? createdAt;
}

/// POST /friends/requests/{id}/accept · /reject — resolve one incoming request.
class FriendRequestActionRequest {
  const FriendRequestActionRequest({required this.requestId});

  final String requestId;

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendRequestActionResponse {
  const FriendRequestActionResponse({this.ok = true});

  factory FriendRequestActionResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return FriendRequestActionResponse(ok: root['ok'] as bool? ?? true);
  }

  final bool ok;
}

/// POST /friends/requests — send a new friend request to a user.
class SendFriendRequestRequest {
  const SendFriendRequestRequest({required this.userId});

  final String userId;

  Map<String, Object?> toJson() => <String, Object?>{'user_id': userId};
}

class SendFriendRequestResponse {
  const SendFriendRequestResponse({this.ok = true, this.requestId});

  factory SendFriendRequestResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    return SendFriendRequestResponse(ok: root['ok'] as bool? ?? true, requestId: root['request_id'] as String?);
  }

  final bool ok;
  final String? requestId;
}
