import '../../../common/constant/urls.dart';
import '../../../common/service/api_client.dart';
import '../../../common/util/logger.dart';
import '../../tests/model/xp_rules_model.dart';
import '../models/friend_requests_model.dart';
import '../models/friends_discovery_model.dart';
import '../models/friends_group_model.dart';
import '../models/friends_leaderboard_model.dart';
import '../models/friends_list_model.dart';
import '../models/remove_friend_model.dart';

/// Section keys for the Friends feature (same pattern as [HomeEndpoints]):
/// each section has its own status in the cubit and loads independently.
abstract final class FriendsEndpoints {
  static const String list = 'friendsList';
  static const String requests = 'friendRequests';
  static const String discovery = 'friendsDiscovery';
  static const String leaderboard = 'friendsLeaderboard';
  static const String groups = 'friendsGroups';

  static const Set<String> all = <String>{list, requests, discovery, leaderboard, groups};
}

/// Repository for the Friends feature (docs §4 / backend_integration.md §4).
abstract interface class IFriendsRepository {
  Future<FriendsListResponse> getFriends(FriendsListRequest request);
  Future<FriendRequestsResponse> getRequests(FriendRequestsRequest request);
  Future<FriendsSuggestionsResponse> getSuggestions(FriendsSuggestionsRequest request);
  Future<FriendsSearchResponse> search(FriendsSearchRequest request);
  Future<FriendsLeaderboardResponse> getLeaderboard(FriendsLeaderboardRequest request);

  /// GET /leaderboard — the global weekly XP board (the "Umumiy" tab).
  Future<FriendsLeaderboardResponse> getGlobalLeaderboard();

  /// GET /xp/rules — the "XP qanday yig'iladi?" sheet content.
  Future<XpRulesResponse> getXpRules();

  Future<FriendsGroupsResponse> getGroups(FriendsGroupsRequest request);
  Future<SendFriendRequestResponse> sendRequest(SendFriendRequestRequest request);
  Future<FriendRequestActionResponse> acceptRequest(FriendRequestActionRequest request);
  Future<FriendRequestActionResponse> rejectRequest(FriendRequestActionRequest request);
  Future<RemoveFriendResponse> removeFriend(RemoveFriendRequest request);
}

final class FriendsRepositoryImpl implements IFriendsRepository {
  const FriendsRepositoryImpl({required this.apiClient});

  final ApiClient apiClient;

  /// Several Friends endpoints are not live on the backend yet. A `404` for a
  /// read section means "no data here", so we degrade to an [empty] response
  /// (the UI shows its empty / invite state) instead of surfacing an error.
  /// Any other failure still propagates to the section's error state.
  Future<T> _readOrEmpty<T>(String label, Future<T> Function() fetch, T empty) async {
    try {
      return await fetch();
    } on ApiResponseException catch (e) {
      if (e.statusCode == 404) return empty;
      info('$label: $e');
      rethrow;
    } catch (e, s) {
      info('$label: $e $s');
      rethrow;
    }
  }

  @override
  Future<FriendsListResponse> getFriends(FriendsListRequest request) => _readOrEmpty(
    'FRIENDS LIST API ERROR',
    () async => FriendsListResponse.fromJson(await apiClient.get(Urls.friends, queryParameters: request.toJson())),
    const FriendsListResponse(),
  );

  @override
  Future<FriendRequestsResponse> getRequests(FriendRequestsRequest request) => _readOrEmpty(
    'FRIEND REQUESTS API ERROR',
    () async => FriendRequestsResponse.fromJson(await apiClient.get(Urls.friendRequests)),
    const FriendRequestsResponse(),
  );

  @override
  Future<FriendsSuggestionsResponse> getSuggestions(FriendsSuggestionsRequest request) => _readOrEmpty(
    'FRIENDS SUGGESTIONS API ERROR',
    () async => FriendsSuggestionsResponse.fromJson(await apiClient.get(Urls.friendsSuggestions)),
    const FriendsSuggestionsResponse(),
  );

  @override
  Future<FriendsSearchResponse> search(FriendsSearchRequest request) => _readOrEmpty(
    'FRIENDS SEARCH API ERROR',
    () async =>
        FriendsSearchResponse.fromJson(await apiClient.get(Urls.friendsSearch, queryParameters: request.toJson())),
    const FriendsSearchResponse(),
  );

  @override
  Future<FriendsLeaderboardResponse> getLeaderboard(FriendsLeaderboardRequest request) => _readOrEmpty(
    'FRIENDS LEADERBOARD API ERROR',
    () async => FriendsLeaderboardResponse.fromJson(await apiClient.get(Urls.friendsLeaderboard)),
    const FriendsLeaderboardResponse(),
  );

  @override
  Future<FriendsLeaderboardResponse> getGlobalLeaderboard() => _readOrEmpty(
    'GLOBAL LEADERBOARD API ERROR',
    () async => FriendsLeaderboardResponse.fromJson(await apiClient.get(Urls.leaderboard)),
    const FriendsLeaderboardResponse(),
  );

  @override
  Future<XpRulesResponse> getXpRules() => _readOrEmpty(
    'XP RULES API ERROR',
    () async => XpRulesResponse.fromJson(await apiClient.get(Urls.xpRules)),
    const XpRulesResponse(),
  );

  @override
  Future<FriendsGroupsResponse> getGroups(FriendsGroupsRequest request) => _readOrEmpty(
    'FRIENDS GROUPS API ERROR',
    () async => FriendsGroupsResponse.fromJson(await apiClient.get(Urls.friendsGroups)),
    const FriendsGroupsResponse(),
  );

  @override
  Future<SendFriendRequestResponse> sendRequest(SendFriendRequestRequest request) async {
    try {
      final response = await apiClient.post(Urls.friendRequests, body: request.toJson());
      return SendFriendRequestResponse.fromJson(response);
    } catch (e, s) {
      info('SEND FRIEND REQUEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<FriendRequestActionResponse> acceptRequest(FriendRequestActionRequest request) async {
    try {
      final response = await apiClient.post(Urls.friendRequestAccept(request.requestId), body: request.toJson());
      return FriendRequestActionResponse.fromJson(response);
    } catch (e, s) {
      info('ACCEPT FRIEND REQUEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<FriendRequestActionResponse> rejectRequest(FriendRequestActionRequest request) async {
    try {
      final response = await apiClient.post(Urls.friendRequestReject(request.requestId), body: request.toJson());
      return FriendRequestActionResponse.fromJson(response);
    } catch (e, s) {
      info('REJECT FRIEND REQUEST API ERROR: $e $s');
      rethrow;
    }
  }

  @override
  Future<RemoveFriendResponse> removeFriend(RemoveFriendRequest request) async {
    try {
      final response = await apiClient.delete(Urls.removeFriend(request.friendId), body: request.toJson());
      return RemoveFriendResponse.fromJson(response);
    } catch (e, s) {
      info('REMOVE FRIEND API ERROR: $e $s');
      rethrow;
    }
  }
}
