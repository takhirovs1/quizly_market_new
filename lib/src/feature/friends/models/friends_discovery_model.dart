import 'friend_user_model.dart';

/// A discoverable person — a [FriendUser] plus my current [relation] (so the row
/// can show add / pending / accept) and a human [reason] for the suggestion.
class FriendSuggestion {
  const FriendSuggestion({required this.user, this.relation = FriendRelation.none, this.reason});

  factory FriendSuggestion.fromJson(Map<String, Object?> json) => FriendSuggestion(
    user: FriendUser.fromJson(json['user'] as Map<String, Object?>? ?? const <String, Object?>{}),
    relation: FriendRelation.fromValue(json['relation'] as String?),
    reason: json['reason'] as String?,
  );

  final FriendUser user;
  final FriendRelation relation;

  /// e.g. `shared_test` (we both own a test) — surfaced from the user's paid
  /// contacts. Display handled client-side from a known key set.
  final String? reason;

  FriendSuggestion copyWith({FriendRelation? relation}) =>
      FriendSuggestion(user: user, relation: relation ?? this.relation, reason: reason);
}

/// GET /friends/suggestions — people the user can add (derived from the IDs of
/// people they shared a purchased test with, per the spec).
class FriendsSuggestionsRequest {
  const FriendsSuggestionsRequest();

  Map<String, Object?> toJson() => const <String, Object?>{};
}

class FriendsSuggestionsResponse {
  const FriendsSuggestionsResponse({this.suggestions = const <FriendSuggestion>[]});

  factory FriendsSuggestionsResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['suggestions'] as List<Object?>? ?? const <Object?>[];
    return FriendsSuggestionsResponse(
      suggestions: list.whereType<Map<String, Object?>>().map(FriendSuggestion.fromJson).toList(),
    );
  }

  final List<FriendSuggestion> suggestions;
}

/// GET /friends/search?q= — search users by name or username/ID.
class FriendsSearchRequest {
  const FriendsSearchRequest({required this.query});

  final String query;

  Map<String, Object?> toJson() => <String, Object?>{'q': query};
}

class FriendsSearchResponse {
  const FriendsSearchResponse({this.results = const <FriendSuggestion>[]});

  factory FriendsSearchResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    final list = root['results'] as List<Object?>? ?? const <Object?>[];
    return FriendsSearchResponse(
      results: list.whereType<Map<String, Object?>>().map(FriendSuggestion.fromJson).toList(),
    );
  }

  final List<FriendSuggestion> results;
}
