import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/test_rating_cubit.dart';
import '../model/test_rating_model.dart';

/// Figma "C · Test rating" — the per-test leaderboard: podium top-3, the ranked
/// list and the caller's pinned row (or a "solve to join" CTA).
class TestRatingScreen extends StatelessWidget {
  const TestRatingScreen({required this.testName, required this.organizationName, super.key});

  final String testName;
  final String organizationName;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        title: l10n.ratingScreenTitle,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<TestRatingCubit, TestRatingState>(
          builder: (context, state) => switch (state.status) {
            StateStatus.success => _content(context, state.data!),
            StateStatus.error => _error(context),
            _ => const Center(child: CircularProgressIndicator.adaptive()),
          },
        ),
      ),
    );
  }

  Widget _error(BuildContext context) {
    final hc = context.x.homeColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.x.l10n.errorOccurred, textAlign: TextAlign.center, style: quizText(14, wMedium, hc.text3)),
            const SizedBox(height: 12),
            QuizButton(
              label: context.x.l10n.retry,
              size: QuizButtonSize.s,
              onTap: () => context.read<TestRatingCubit>().load(''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, TestRatingResponse data) {
    final entries = data.entries;
    // Rows below the podium start at rank 4 (index 3).
    final listRows = entries.length > 3 ? entries.sublist(3) : const <RatingEntry>[];
    final me = data.me;
    // Pin "me" only when not already visible among the podium / list.
    final meVisible = me == null || entries.any((e) => e.isMe);
    final showMe = me != null && !meVisible;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, showMe || data.canJoin ? 120 : 24),
          children: [
            _header(context, data),
            const SizedBox(height: 16),
            if (entries.isNotEmpty) ...[
              _Podium(
                first: entries.isNotEmpty ? entries[0] : null,
                second: entries.length > 1 ? entries[1] : null,
                third: entries.length > 2 ? entries[2] : null,
              ),
              const SizedBox(height: 16),
            ],
            if (listRows.isNotEmpty)
              for (var i = 0; i < listRows.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _RatingRow(entry: listRows[i]),
              ]
            else if (entries.isEmpty)
              _EmptyBoard(onStart: () => Navigator.of(context).maybePop()),
          ],
        ),
        if (showMe)
          _PinnedBottom(child: _RatingRow(entry: me, highlighted: true))
        else if (data.canJoin)
          _PinnedBottom(child: _JoinCard(onStart: () => Navigator.of(context).maybePop())),
      ],
    );
  }

  Widget _header(BuildContext context, TestRatingResponse data) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final subtitle = organizationName.isEmpty
        ? l10n.ratingScreenTitle
        : '$organizationName · ${l10n.ratingScreenTitle}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(testName, style: quizText(24, wBold, hc.text)),
        const SizedBox(height: 6),
        Row(
          children: [
            Flexible(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: quizText(13, wRegular, hc.text3),
              ),
            ),
            const SizedBox(width: 6),
            QuizPill(
              text: l10n.ratingStudents(data.totalParticipants),
              background: hc.primaryTint,
              foreground: hc.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: hc.primaryTint, borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ℹ︎', style: quizText(13, wBold, hc.primary)),
              const SizedBox(width: 6),
              Expanded(child: Text(l10n.ratingRule, style: quizText(12, wMedium, hc.primary, height: 1.3))),
            ],
          ),
        ),
      ],
    );
  }
}

/// mm:ss for a rating entry's duration.
String _durationText(int? sec) {
  if (sec == null || sec <= 0) return '—';
  final m = (sec ~/ 60).toString().padLeft(2, '0');
  final s = (sec % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class _Podium extends StatelessWidget {
  const _Podium({this.first, this.second, this.third});

  final RatingEntry? first;
  final RatingEntry? second;
  final RatingEntry? third;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(child: _PodiumPlace(entry: second, place: 2)),
      const SizedBox(width: 8),
      Expanded(child: _PodiumPlace(entry: first, place: 1)),
      const SizedBox(width: 8),
      Expanded(child: _PodiumPlace(entry: third, place: 3)),
    ],
  );
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.place});

  final RatingEntry? entry;
  final int place;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final (Color top, Color bottom, double height) = switch (place) {
      1 => (colors.podiumGoldTop, colors.podiumGoldBottom, 84.0),
      2 => (colors.podiumSilverTop, colors.podiumSilverBottom, 60.0),
      _ => (colors.podiumBronzeTop, colors.podiumBronzeBottom, 44.0),
    };
    final medal = switch (place) {
      1 => '🥇',
      2 => '🥈',
      _ => '🥉',
    };
    final avatarSize = place == 1 ? 64.0 : 52.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (entry == null)
          _emptyAvatar(context, avatarSize)
        else ...[
          _podiumAvatar(context, entry!, avatarSize, medal),
          const SizedBox(height: 6),
          Text(entry!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(14, wSemibold, hc.text)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${entry!.scorePercent}%', style: quizText(13, wBold, hc.text)),
              const SizedBox(width: 4),
              Text('· ${_durationText(entry!.durationSec)}', style: quizText(12, wRegular, hc.text3)),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Text('$place', style: quizText(22, wHeavy, colors.pureWhite)),
        ),
      ],
    );
  }

  Widget _emptyAvatar(BuildContext context, double size) {
    final hc = context.x.homeColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: hc.surface2, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('?', style: quizText(size * 0.4, wSemibold, hc.text3)),
        ),
        const SizedBox(height: 6),
        Text(context.x.l10n.ratingPodiumEmpty, style: quizText(14, wMedium, hc.text3)),
      ],
    );
  }

  Widget _podiumAvatar(BuildContext context, RatingEntry entry, double size, String medal) {
    final hc = context.x.homeColors;
    final accent = colorFromHex(entry.color, fallback: hc.purple);
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          QuizInitialAvatar(
            initial: entry.initial,
            color: accent,
            background: accent.withValues(alpha: 0.14),
            size: size,
          ),
          Positioned(right: 0, bottom: 2, child: Text(medal, style: const TextStyle(fontSize: 20))),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.entry, this.highlighted = false});

  final RatingEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final accent = colorFromHex(entry.color, fallback: hc.primary);
    final rankColor = highlighted ? hc.primary : hc.text3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted ? hc.primaryTint : hc.surface,
        borderRadius: BorderRadius.circular(16),
        border: highlighted ? Border.all(color: hc.primary) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.rank}', textAlign: TextAlign.center, style: quizText(15, wBold, rankColor)),
          ),
          const SizedBox(width: 12),
          QuizInitialAvatar(
            initial: entry.initial,
            color: accent,
            background: accent.withValues(alpha: 0.14),
            size: 40,
            borderWidth: 0,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isMe ? l10n.you : entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: quizText(15, wSemibold, hc.text),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.ratingTimeLabel(_durationText(entry.durationSec)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: quizText(12, wRegular, hc.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${entry.scorePercent}%', style: quizText(16, wBold, highlighted ? hc.primary : hc.text)),
        ],
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  const _JoinCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(16), boxShadow: [hc.softShadow]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: hc.primaryTint, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text('🏁', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.ratingJoinTitle, style: quizText(14, wSemibold, hc.text)),
                    const SizedBox(height: 2),
                    Text(l10n.ratingJoinDesc, style: quizText(12, wRegular, hc.text3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          QuizButton(label: l10n.ratingJoinCta, size: QuizButtonSize.l, expand: true, onTap: onStart),
        ],
      ),
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.x.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: QuizEmptyState(
        emoji: '🏁',
        title: l10n.ratingEmptyTitle,
        description: l10n.ratingEmptyDesc,
        buttonLabel: l10n.ratingJoinCta,
        onPressed: onStart,
      ),
    );
  }
}

class _PinnedBottom extends StatelessWidget {
  const _PinnedBottom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: hc.surface.withValues(alpha: 0.96),
          boxShadow: [BoxShadow(color: hc.cardShadow, blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(top: false, child: child),
      ),
    );
  }
}
