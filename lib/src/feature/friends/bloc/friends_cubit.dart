import 'package:equatable/equatable.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/sequential_cubit.dart';
import '../../../common/util/state_status.dart';
import '../data/friends_repository.dart';
import '../models/friend_requests_model.dart';
import '../models/friend_user_model.dart';
import '../models/friends_discovery_model.dart';
import '../models/friends_group_model.dart';
import '../models/friends_leaderboard_model.dart';
import '../models/friends_list_model.dart';
import '../models/remove_friend_model.dart';

part 'friends_state.dart';

/// Owns the Friends screen. Sections load in parallel and fail independently
/// (same [FriendsEndpoints] status-map pattern as the home sections). Mutations
/// (send / accept / reject / remove) are optimistic and revert on error.
class FriendsCubit extends SequentialCubit<FriendsState> {
  FriendsCubit({required this.repository}) : super(const FriendsState());

  final IFriendsRepository repository;

  /// Load every section in parallel. One failure only flips its own status.
  Future<void> loadAll() => handle<void>((emit) async {
    emit(
      state.copyWith(
        statuses: <String, StateStatus>{for (final key in FriendsEndpoints.all) key: StateStatus.loading},
        sectionErrors: const <String, String?>{},
      ),
    );
    await Future.wait<void>(<Future<void>>[
      _loadSection(
        emit,
        FriendsEndpoints.list,
        () => repository.getFriends(const FriendsListRequest()),
        (s, r) => s.copyWith(friendsList: r),
      ),
      _loadSection(
        emit,
        FriendsEndpoints.requests,
        () => repository.getRequests(const FriendRequestsRequest()),
        (s, r) => s.copyWith(requests: r),
      ),
      _loadSection(
        emit,
        FriendsEndpoints.discovery,
        () => repository.getSuggestions(const FriendsSuggestionsRequest()),
        (s, r) => s.copyWith(suggestions: r),
      ),
      _loadSection(
        emit,
        FriendsEndpoints.leaderboard,
        () => repository.getLeaderboard(const FriendsLeaderboardRequest()),
        (s, r) => s.copyWith(leaderboard: r),
      ),
      _loadSection(
        emit,
        FriendsEndpoints.groups,
        () => repository.getGroups(const FriendsGroupsRequest()),
        (s, r) => s.copyWith(groups: r),
      ),
    ]);
  });

  Future<void> _loadSection<T>(
    void Function(FriendsState state) emit,
    String key,
    Future<T> Function() fetch,
    FriendsState Function(FriendsState state, T data) apply,
  ) async {
    try {
      final data = await fetch();
      emit(apply(state, data).copyWithStatus(key, StateStatus.success));
    } on Object catch (error) {
      emit(state.copyWithStatus(key, StateStatus.error, error: ErrorUtil.toUserFriendlyMessage(error)));
    }
  }

  Future<void> retrySection(String key) {
    switch (key) {
      case FriendsEndpoints.list:
        return _reloadSection(
          key,
          () => repository.getFriends(const FriendsListRequest()),
          (s, r) => s.copyWith(friendsList: r),
        );
      case FriendsEndpoints.requests:
        return _reloadSection(
          key,
          () => repository.getRequests(const FriendRequestsRequest()),
          (s, r) => s.copyWith(requests: r),
        );
      case FriendsEndpoints.discovery:
        return _reloadSection(
          key,
          () => repository.getSuggestions(const FriendsSuggestionsRequest()),
          (s, r) => s.copyWith(suggestions: r),
        );
      case FriendsEndpoints.leaderboard:
        return _reloadSection(
          key,
          () => repository.getLeaderboard(const FriendsLeaderboardRequest()),
          (s, r) => s.copyWith(leaderboard: r),
        );
      case FriendsEndpoints.groups:
        return _reloadSection(
          key,
          () => repository.getGroups(const FriendsGroupsRequest()),
          (s, r) => s.copyWith(groups: r),
        );
    }
    return Future<void>.value();
  }

  Future<void> _reloadSection<T>(
    String key,
    Future<T> Function() fetch,
    FriendsState Function(FriendsState state, T data) apply,
  ) => handle<void>(
    (emit) async {
      emit(state.copyWithStatus(key, StateStatus.loading));
      final data = await fetch();
      emit(apply(state, data).copyWithStatus(key, StateStatus.success));
    },
    errorHandler: (emit, error, stackTrace) {
      emit(state.copyWithStatus(key, StateStatus.error, error: ErrorUtil.toUserFriendlyMessage(error)));
    },
  );

  // ── Add-friend search ────────────────────────────────────────────────────
  /// Debounced by the UI. Empty query clears results.
  Future<void> searchUsers(String query) => handle<void>((emit) async {
    final q = query.trim();
    if (q.isEmpty) {
      emit(
        state.copyWith(searchQuery: query, searchStatus: StateStatus.idle, searchResults: const <FriendSuggestion>[]),
      );
      return;
    }
    emit(state.copyWith(searchQuery: query, searchStatus: StateStatus.loading));
    try {
      final res = await repository.search(FriendsSearchRequest(query: q));
      emit(state.copyWith(searchStatus: StateStatus.success, searchResults: res.results));
    } on Object {
      emit(state.copyWith(searchStatus: StateStatus.error, searchResults: const <FriendSuggestion>[]));
    }
  });

  void clearSearch() =>
      emit(state.copyWith(searchQuery: '', searchStatus: StateStatus.idle, searchResults: const <FriendSuggestion>[]));

  // ── Mutations (optimistic) ─────────────────────────────────────────────────
  Future<void> sendFriendRequest(String userId) => handle<void>((emit) async {
    emit(_withRelation(userId, FriendRelation.requested));
    try {
      await repository.sendRequest(SendFriendRequestRequest(userId: userId));
    } on Object {
      emit(_withRelation(userId, FriendRelation.none));
    }
  });

  Future<void> acceptRequest(String requestId) => handle<void>((emit) async {
    final reqs = state.requests;
    final list = state.friendsList;
    if (reqs == null) return;
    FriendRequestItem? item;
    for (final r in reqs.incoming) {
      if (r.requestId == requestId) {
        item = r;
        break;
      }
    }
    final newIncoming = reqs.incoming.where((r) => r.requestId != requestId).toList();
    emit(
      state.copyWith(
        requests: FriendRequestsResponse(incoming: newIncoming, outgoing: reqs.outgoing),
        friendsList: item != null && list != null
            ? FriendsListResponse(friends: <FriendUser>[item.user, ...list.friends], totalCount: list.totalCount + 1)
            : list,
      ),
    );
    try {
      await repository.acceptRequest(FriendRequestActionRequest(requestId: requestId));
    } on Object {
      emit(state.copyWith(requests: reqs, friendsList: list));
    }
  });

  Future<void> rejectRequest(String requestId) => handle<void>((emit) async {
    final reqs = state.requests;
    if (reqs == null) return;
    final newIncoming = reqs.incoming.where((r) => r.requestId != requestId).toList();
    emit(
      state.copyWith(
        requests: FriendRequestsResponse(incoming: newIncoming, outgoing: reqs.outgoing),
      ),
    );
    try {
      await repository.rejectRequest(FriendRequestActionRequest(requestId: requestId));
    } on Object {
      emit(state.copyWith(requests: reqs));
    }
  });

  Future<void> removeFriend(String friendId) => handle<void>((emit) async {
    final list = state.friendsList;
    if (list == null) return;
    final updated = list.friends.where((f) => f.id != friendId).toList();
    emit(
      state.copyWith(
        friendsList: FriendsListResponse(friends: updated, totalCount: (list.totalCount - 1).clamp(0, 1 << 31)),
      ),
    );
    try {
      await repository.removeFriend(RemoveFriendRequest(friendId: friendId));
    } on Object {
      emit(state.copyWith(friendsList: list));
    }
  });

  /// Set [userId]'s relation in both suggestions and live search results.
  FriendsState _withRelation(String userId, FriendRelation relation) {
    final suggestions = state.suggestions;
    final newSuggestions = suggestions == null
        ? null
        : FriendsSuggestionsResponse(
            suggestions: suggestions.suggestions
                .map((s) => s.user.id == userId ? s.copyWith(relation: relation) : s)
                .toList(),
          );
    final newSearch = state.searchResults.map((s) => s.user.id == userId ? s.copyWith(relation: relation) : s).toList();
    return state.copyWith(suggestions: newSuggestions, searchResults: newSearch);
  }
}
