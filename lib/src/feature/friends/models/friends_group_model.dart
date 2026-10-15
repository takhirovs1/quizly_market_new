import 'friend_user_model.dart';

/// GET /friends/groups — live "solve together" sessions.
///
/// STUB: group live-solve runs over a websocket (real-time invites + shared
/// session state) and is a separate task. For now the endpoint reports
/// [comingSoon] and an (empty) list of [active] sessions so the UI can show a
/// disabled "Tez kunda" entry without faking real-time behaviour.
class FriendsGroupsRequest {
  const FriendsGroupsRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendsGroupsResponse {
  const FriendsGroupsResponse({this.active = const <GroupSession>[], this.comingSoon = true});

  factory FriendsGroupsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['active'] as List<Object?>? ?? const <Object?>[];
    return FriendsGroupsResponse(
      active: list.whereType<Map<String, Object?>>().map(GroupSession.fromJson).toList(),
      comingSoon: root['coming_soon'] as bool? ?? true,
    );
  }

  final List<GroupSession> active;
  final bool comingSoon;
}

class GroupSession {
  const GroupSession({
    required this.id,
    required this.testName,
    required this.hostName,
    this.participants = const <FriendUser>[],
    this.status = 'waiting',
  });

  factory GroupSession.fromJson(Map<String, Object?> json) => GroupSession(
    id: json['id'] as String? ?? '',
    testName: json['test_name'] as String? ?? '',
    hostName: json['host_name'] as String? ?? '',
    participants: (json['participants'] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<String, Object?>>()
        .map(FriendUser.fromJson)
        .toList(),
    status: json['status'] as String? ?? 'waiting',
  );

  final String id;
  final String testName;
  final String hostName;
  final List<FriendUser> participants;

  /// `waiting` | `live` | `finished`.
  final String status;
}
