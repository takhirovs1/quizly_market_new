part of 'friends_cubit.dart';

class FriendsState extends Equatable {
  const FriendsState({
    this.statuses = const <String, StateStatus>{},
    this.sectionErrors = const <String, String?>{},
    this.friendsList,
    this.requests,
    this.suggestions,
    this.leaderboard,
    this.groups,
    this.searchQuery = '',
    this.searchStatus = StateStatus.idle,
    this.searchResults = const <FriendSuggestion>[],
  });

  final Map<String, StateStatus> statuses;
  final Map<String, String?> sectionErrors;

  final FriendsListResponse? friendsList;
  final FriendRequestsResponse? requests;
  final FriendsSuggestionsResponse? suggestions;
  final FriendsLeaderboardResponse? leaderboard;
  final FriendsGroupsResponse? groups;

  /// Add-friend search (separate from the loaded suggestions list).
  final String searchQuery;
  final StateStatus searchStatus;
  final List<FriendSuggestion> searchResults;

  StateStatus statusOf(String key) => statuses[key] ?? StateStatus.idle;

  String? sectionError(String key) => sectionErrors[key];

  int get incomingRequestCount => requests?.incoming.length ?? 0;

  FriendsState copyWithStatus(String key, StateStatus status, {String? error}) => copyWith(
    statuses: <String, StateStatus>{...statuses, key: status},
    sectionErrors: <String, String?>{...sectionErrors, key: error},
  );

  FriendsState copyWith({
    Map<String, StateStatus>? statuses,
    Map<String, String?>? sectionErrors,
    FriendsListResponse? friendsList,
    FriendRequestsResponse? requests,
    FriendsSuggestionsResponse? suggestions,
    FriendsLeaderboardResponse? leaderboard,
    FriendsGroupsResponse? groups,
    String? searchQuery,
    StateStatus? searchStatus,
    List<FriendSuggestion>? searchResults,
  }) => FriendsState(
    statuses: statuses ?? this.statuses,
    sectionErrors: sectionErrors ?? this.sectionErrors,
    friendsList: friendsList ?? this.friendsList,
    requests: requests ?? this.requests,
    suggestions: suggestions ?? this.suggestions,
    leaderboard: leaderboard ?? this.leaderboard,
    groups: groups ?? this.groups,
    searchQuery: searchQuery ?? this.searchQuery,
    searchStatus: searchStatus ?? this.searchStatus,
    searchResults: searchResults ?? this.searchResults,
  );

  @override
  List<Object?> get props => [
    statuses,
    sectionErrors,
    friendsList,
    requests,
    suggestions,
    leaderboard,
    groups,
    searchQuery,
    searchStatus,
    searchResults,
  ];
}
