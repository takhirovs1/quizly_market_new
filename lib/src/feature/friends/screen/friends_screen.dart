import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/friends_cubit.dart';
import '../data/friends_repository.dart';
import '../state/friends_screen_state.dart';
import '../widgets/friend_request_tile.dart';
import '../widgets/friend_tile.dart';
import '../widgets/friends_invite_banner.dart';
import '../widgets/group_solve_card.dart';
import '../widgets/leaderboard_row.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({required this.inviteCode, super.key});

  /// Referral code used by the invite banner's share action (passed by the
  /// opener so sharing works without re-fetching the referral summary).
  final String inviteCode;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends FriendsScreenState {
  static const _hPad = EdgeInsets.symmetric(horizontal: 16);
  static const _gap = SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        title: l10n.friendsTitle,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: BlocBuilder<FriendsCubit, FriendsState>(
                bloc: friendsCubit,
                builder: (context, state) => ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 28),
                  children: [
                    Padding(
                      padding: _hPad,
                      child: FriendsInviteBanner(onShare: onShareInvite),
                    ),
                    _gap,
                    _requestsSection(state),
                    _friendsSection(state),
                    _gap,
                    _leaderboardSection(state),
                    _gap,
                    Padding(padding: _hPad, child: _groupsSection(state)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Requests (hidden when none) ─────────────────────────────────────────────
  Widget _requestsSection(FriendsState state) {
    final status = state.statusOf(FriendsEndpoints.requests);
    final incoming = state.requests?.incoming ?? const [];
    if (status.isSuccess && incoming.isEmpty) return const SizedBox.shrink();
    final l10n = context.x.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _hPad,
          child: QuizSectionHeader(title: l10n.friendsRequestsTitle),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: _hPad,
          child: _statusChild(
            status,
            FriendsEndpoints.requests,
            skeleton: _tileSkeletons(2),
            child: Column(
              children: [
                for (var i = 0; i < incoming.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  FriendRequestTile(
                    item: incoming[i],
                    onAccept: () => onAcceptRequest(incoming[i].requestId),
                    onReject: () => onRejectRequest(incoming[i].requestId),
                  ),
                ],
              ],
            ),
          ),
        ),
        _gap,
      ],
    );
  }

  // ── Friends list ─────────────────────────────────────────────────────────────
  Widget _friendsSection(FriendsState state) {
    final status = state.statusOf(FriendsEndpoints.list);
    final friends = state.friendsList?.friends ?? const [];
    final l10n = context.x.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _hPad,
          child: QuizSectionHeader(
            title: l10n.friendsYourFriends,
            seeAllLabel: l10n.friendsActionAdd,
            onSeeAll: onAddFriend,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: _hPad,
          child: _statusChild(
            status,
            FriendsEndpoints.list,
            skeleton: _tileSkeletons(3),
            child: friends.isEmpty
                ? QuizEmptyState(
                    title: l10n.friendsEmptyTitle,
                    description: l10n.friendsEmptyDesc,
                    buttonLabel: l10n.friendsActionAdd,
                    illustration: QuizLottieIcon(QuizLottie.addFriends, size: 52, color: context.x.homeColors.primary),
                    onPressed: onAddFriend,
                  )
                : Column(
                    children: [
                      for (var i = 0; i < friends.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        FriendTile(user: friends[i], onRemove: () => onRemoveFriend(friends[i])),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Weekly leaderboard ─────────────────────────────────────────────────────
  Widget _leaderboardSection(FriendsState state) {
    final status = state.statusOf(FriendsEndpoints.leaderboard);
    final entries = state.leaderboard?.entries ?? const [];
    final l10n = context.x.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _hPad,
          child: QuizSectionHeader(title: l10n.friendsLeaderboardTitle),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: _hPad,
          child: _statusChild(
            status,
            FriendsEndpoints.leaderboard,
            skeleton: _tileSkeletons(4),
            child: entries.isEmpty
                ? _hint(l10n.friendsLeaderboardEmpty)
                : Column(
                    children: [
                      for (var i = 0; i < entries.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        LeaderboardRow(entry: entries[i]),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Groups (stub) ──────────────────────────────────────────────────────────
  Widget _groupsSection(FriendsState state) => _statusChild(
    state.statusOf(FriendsEndpoints.groups),
    FriendsEndpoints.groups,
    skeleton: _tileSkeletons(1),
    child: state.groups == null ? const SizedBox.shrink() : GroupSolveCard(data: state.groups!),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _statusChild(StateStatus status, String key, {required Widget skeleton, required Widget child}) {
    if (status.isLoading || status.isIdle) return skeleton;
    if (status.isError) {
      final hc = context.x.homeColors;
      final l10n = context.x.l10n;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hc.border),
        ),
        child: Column(
          children: [
            Text(l10n.somethingWentWrong, textAlign: TextAlign.center, style: quizText(13, wRegular, hc.text3)),
            const SizedBox(height: 10),
            QuizButton(
              label: l10n.retry,
              type: QuizButtonType.tonal,
              size: QuizButtonSize.s,
              onTap: () => onRetrySection(key),
            ),
          ],
        ),
      );
    }
    return child;
  }

  Widget _tileSkeletons(int count) => Column(
    children: [
      for (var i = 0; i < count; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        const ShimmerBox(height: 64, width: double.infinity, radius: 16),
      ],
    ],
  );

  Widget _hint(String text) {
    final hc = context.x.homeColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: hc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hc.border),
      ),
      alignment: Alignment.center,
      child: Text(text, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3)),
    );
  }
}
