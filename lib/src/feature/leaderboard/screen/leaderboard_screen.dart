import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../friends/models/friend_user_model.dart';
import '../../friends/models/friends_leaderboard_model.dart';
import '../../friends/widgets/friend_avatar.dart';
import '../bloc/leaderboard_cubit.dart';
import '../widget/xp_rules_sheet.dart';

/// Figma "G5 · Leaderboard" — weekly XP standings with Do‘stlar / Umumiy tabs,
/// a period line, a "How XP works" link, and the caller's own row pinned when
/// they fall outside the visible list. Reached from the home friends card's
/// "Reyting ›".
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const _hPad = EdgeInsets.symmetric(horizontal: 16);

  @override
  void initState() {
    super.initState();
    context.read<LeaderboardCubit>().load();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final cubit = context.read<LeaderboardCubit>();
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        title: l10n.leaderboardTitle,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) {
                final board = state.activeBoard;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _Tabs(tab: state.tab, onChanged: cubit.setTab),
                    ),
                    const SizedBox(height: 14),
                    if (board?.resetsAt != null) ...[
                      Padding(
                        padding: _hPad,
                        child: _PeriodRow(resetsAt: board!.resetsAt!),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Padding(
                      padding: _hPad,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _HowXpLink(onTap: () => showXpRulesSheet(context, rules: state.xpRules)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _list(state)),
                    _pinnedMe(context, state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(LeaderboardState state) {
    final status = state.activeStatus;
    if (status.isLoading || status.isIdle) return const _ListSkeleton();
    final board = state.activeBoard;
    if (status.isError) return _hint(context.x.l10n.somethingWentWrong);
    final entries = board?.entries ?? const <LeaderboardEntry>[];
    if (entries.isEmpty) return _hint(context.x.l10n.friendsLeaderboardEmpty);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _LbTile(entry: entries[i]),
    );
  }

  /// The caller's own row, pinned above the nav when they aren't in the visible
  /// list (Figma G5b). Hidden when they already appear in the list.
  Widget _pinnedMe(BuildContext context, LeaderboardState state) {
    final board = state.activeBoard;
    final meRank = board?.meRank;
    if (board == null || meRank == null || board.entries.any((e) => e.isMe)) return const SizedBox.shrink();
    final hc = context.x.homeColors;
    final entry = LeaderboardEntry(
      user: FriendUser(id: 'me', name: context.x.l10n.friendsYou),
      rank: meRank,
      xp: board.meXp,
      isMe: true,
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: hc.border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: _LbTile(entry: entry),
    );
  }

  Widget _hint(String text) {
    final hc = context.x.homeColors;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: hc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: hc.border),
          ),
          alignment: Alignment.center,
          child: Text(text, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3)),
        ),
      ],
    );
  }
}

/// Segmented Do‘stlar / Umumiy control in the app's tab-bar language.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onChanged});
  final LeaderboardTab tab;
  final ValueChanged<LeaderboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;

    Widget seg(String label, LeaderboardTab value) {
      final selected = tab == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? hc.surface : context.x.colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected ? [hc.softShadow] : null,
            ),
            child: Text(label, style: quizText(15, selected ? wSemibold : wMedium, selected ? hc.text : hc.text3)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: hc.track, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          seg(l10n.friendsTitle, LeaderboardTab.friends),
          const SizedBox(width: 3),
          seg(l10n.leaderboardTabGlobal, LeaderboardTab.global),
        ],
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.resetsAt});
  final DateTime resetsAt;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final days = resetsAt.difference(DateTime.now()).inDays;
    final pill = days <= 0 ? l10n.leaderboardResetsToday : l10n.leaderboardDaysLeft(days);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.leaderboardPeriodWeek,
            style: quizText(13, wMedium, hc.text3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: hc.primaryTint, borderRadius: BorderRadius.circular(100)),
          child: Text('⏳ $pill', style: quizText(12, wSemibold, hc.primary)),
        ),
      ],
    );
  }
}

class _HowXpLink extends StatelessWidget {
  const _HowXpLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ⓘ', style: quizText(14, wSemibold, hc.primary)),
          const SizedBox(width: 6),
          Text(context.x.l10n.xpHowTitle, style: quizText(14, wSemibold, hc.primary)),
        ],
      ),
    );
  }
}

/// One leaderboard row (Figma "Leaderboard Row"): rank, avatar, name (+ handle),
/// XP. The caller's own row is tinted and outlined in the primary colour.
class _LbTile extends StatelessWidget {
  const _LbTile({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final isMe = entry.isMe;
    final username = entry.user.username;
    final subtitle = (username != null && username.isNotEmpty) ? '@$username' : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? hc.primaryTint : hc.surface,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: hc.primary) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: quizText(15, wBold, isMe ? hc.primary : hc.text3),
            ),
          ),
          const SizedBox(width: 12),
          FriendAvatar(user: entry.user, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? l10n.friendsYou : (entry.user.name.isEmpty ? '—' : entry.user.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: quizText(15, wSemibold, hc.text),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(12, wRegular, hc.text3)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(l10n.friendsXpValue(entry.xp), style: quizText(16, wBold, isMe ? hc.primary : hc.text)),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    itemCount: 8,
    physics: const NeverScrollableScrollPhysics(),
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (_, _) => const ShimmerBox(height: 60, width: double.infinity, radius: 16),
  );
}
