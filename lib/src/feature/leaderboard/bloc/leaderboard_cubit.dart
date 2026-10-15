import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../../friends/data/friends_repository.dart';
import '../../friends/models/friends_leaderboard_model.dart';
import '../../tests/model/xp_rules_model.dart';

/// The two leaderboard scopes (Figma "G5a · Do‘stlar" / "G5b · Umumiy").
enum LeaderboardTab { friends, global }

/// State for the leaderboard screen. The two boards load independently so one
/// failing scope never blocks the other; the XP rules back the "How XP" sheet.
class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.tab = LeaderboardTab.friends,
    this.friendsStatus = StateStatus.idle,
    this.globalStatus = StateStatus.idle,
    this.friendsBoard,
    this.globalBoard,
    this.xpRules,
  });

  final LeaderboardTab tab;
  final StateStatus friendsStatus;
  final StateStatus globalStatus;
  final FriendsLeaderboardResponse? friendsBoard;
  final FriendsLeaderboardResponse? globalBoard;
  final XpRulesResponse? xpRules;

  StateStatus get activeStatus => tab == LeaderboardTab.friends ? friendsStatus : globalStatus;
  FriendsLeaderboardResponse? get activeBoard => tab == LeaderboardTab.friends ? friendsBoard : globalBoard;

  LeaderboardState copyWith({
    LeaderboardTab? tab,
    StateStatus? friendsStatus,
    StateStatus? globalStatus,
    FriendsLeaderboardResponse? friendsBoard,
    FriendsLeaderboardResponse? globalBoard,
    XpRulesResponse? xpRules,
  }) => LeaderboardState(
    tab: tab ?? this.tab,
    friendsStatus: friendsStatus ?? this.friendsStatus,
    globalStatus: globalStatus ?? this.globalStatus,
    friendsBoard: friendsBoard ?? this.friendsBoard,
    globalBoard: globalBoard ?? this.globalBoard,
    xpRules: xpRules ?? this.xpRules,
  );

  @override
  List<Object?> get props => [tab, friendsStatus, globalStatus, friendsBoard, globalBoard, xpRules];
}

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit({required this.repository}) : super(const LeaderboardState());

  final IFriendsRepository repository;

  /// Both boards and the XP rules load in parallel; the user can switch tabs
  /// instantly once each scope resolves.
  Future<void> load() => Future.wait<void>([_loadFriends(), _loadGlobal(), _loadXpRules()]);

  Future<void> _loadFriends() async {
    emit(state.copyWith(friendsStatus: StateStatus.loading));
    try {
      final board = await repository.getLeaderboard(const FriendsLeaderboardRequest());
      emit(state.copyWith(friendsStatus: StateStatus.success, friendsBoard: board));
    } on Object catch (e, s) {
      info('LEADERBOARD FRIENDS LOAD ERROR: $e $s');
      emit(state.copyWith(friendsStatus: StateStatus.error));
    }
  }

  Future<void> _loadGlobal() async {
    emit(state.copyWith(globalStatus: StateStatus.loading));
    try {
      final board = await repository.getGlobalLeaderboard();
      emit(state.copyWith(globalStatus: StateStatus.success, globalBoard: board));
    } on Object catch (e, s) {
      info('LEADERBOARD GLOBAL LOAD ERROR: $e $s');
      emit(state.copyWith(globalStatus: StateStatus.error));
    }
  }

  Future<void> _loadXpRules() async {
    try {
      emit(state.copyWith(xpRules: await repository.getXpRules()));
    } on Object catch (e, s) {
      info('XP RULES LOAD ERROR: $e $s');
    }
  }

  void setTab(LeaderboardTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
  }
}
