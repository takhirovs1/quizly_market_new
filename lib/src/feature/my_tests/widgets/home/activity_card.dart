import 'dart:math' as math;

import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/home_activity_model.dart';

/// Figma "Activity Card" (Filled / Empty) — weekly finished-session bar chart,
/// total, delta chip and streak chip (docs §4.8).
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.data, super.key});

  final HomeActivityResponse data;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final empty = data.totalThisWeek == 0 && data.streak == 0 && data.days.every((d) => d.count == 0);

    return Container(
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(20), boxShadow: [hc.softShadow]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.homeActivityTitle, style: quizText(17, wSemibold, hc.text)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(l10n.homeActivityTestCount(data.totalThisWeek), style: quizText(13, wRegular, hc.text3)),
                        if (!empty && data.deltaPercent != 0) ...[
                          const SizedBox(width: 6),
                          QuizPill(
                            text: '${data.deltaPercent >= 0 ? '↑' : '↓'} ${data.deltaPercent.abs()}%',
                            background: data.deltaPercent >= 0 ? hc.successTint : hc.dangerTint,
                            foreground: data.deltaPercent >= 0 ? hc.success : hc.danger,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: empty ? 0.6 : 1,
                child: QuizPill(
                  leading: const QuizLottieIcon(QuizLottie.fire, size: 14),
                  text: empty ? l10n.homeStreakDaysShort(0) : l10n.homeStreakDays(data.streak),
                  background: hc.streakBg,
                  foreground: hc.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BarChart(days: data.days, empty: empty),
          if (empty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: hc.surface2, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const QuizLottieIcon(QuizLottie.lamp, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.homeActivityHint, style: quizText(13, wRegular, hc.text2))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.days, required this.empty});
  final List<ActivityDay> days;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final maxCount = days.fold<int>(1, (m, d) => math.max(m, d.count));

    String label(ActivityDay d) => switch (d.weekday) {
      1 => l10n.homeDowMon,
      2 => l10n.homeDowTue,
      3 => l10n.homeDowWed,
      4 => l10n.homeDowThu,
      5 => l10n.homeDowFri,
      6 => l10n.homeDowSat,
      _ => l10n.homeDowSun,
    };

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (days[i].isToday && !empty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: hc.text, borderRadius: BorderRadius.circular(6)),
                      child: Text('${days[i].count}', style: quizText(11, wBold, hc.onAccent)),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Container(
                    width: double.infinity,
                    // Cap so the tallest column (today = badge + bar + label)
                    // fits inside the 120px chart without a RenderFlex overflow.
                    height: empty ? 4 : (days[i].count == 0 ? 6 : 10 + (days[i].count / maxCount) * 64),
                    decoration: BoxDecoration(
                      gradient: days[i].isToday && !empty ? hc.heroGradient : null,
                      color: empty ? hc.track : (days[i].isToday ? null : hc.primaryTint),
                      borderRadius: BorderRadius.circular(empty ? 2 : 8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i].isToday ? l10n.homeToday : label(days[i]),
                    style: quizText(11, days[i].isToday ? wSemibold : wMedium, days[i].isToday ? hc.primary : hc.text3),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
