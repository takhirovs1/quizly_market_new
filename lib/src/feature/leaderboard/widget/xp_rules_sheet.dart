import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../tests/model/xp_rules_model.dart';

/// Figma "G6 · How XP works" — a bottom sheet listing how each action earns XP,
/// any daily caps, and a close button. Opened from the leaderboard's
/// "XP qanday yig'iladi?" link.
Future<void> showXpRulesSheet(BuildContext context, {required XpRulesResponse? rules}) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (_) => _XpRulesSheet(rules: rules?.rules ?? const <XpRule>[]),
);

class _XpRulesSheet extends StatelessWidget {
  const _XpRulesSheet({required this.rules});
  final List<XpRule> rules;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final caps = <String>{
      for (final r in rules)
        if (r.cap.isNotEmpty) r.cap,
    }.toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: hc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: hc.track, borderRadius: BorderRadius.circular(100)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Text(l10n.xpHowTitle, style: quizText(20, wBold, hc.text))),
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (rules.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(l10n.friendsLeaderboardEmpty, style: quizText(14, wRegular, hc.text3)),
                          ),
                        )
                      else
                        for (final r in rules) _RuleRow(rule: r),
                      for (final cap in caps) ...[const SizedBox(height: 8), _CapNote(text: _capLabel(cap))],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              QuizButton(
                label: l10n.leaderboardGotIt,
                size: QuizButtonSize.l,
                expand: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.rule});
  final XpRule rule;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final (icon, tint, iconColor) = _iconFor(context, rule.type);
    final label = rule.text.isNotEmpty ? rule.text : (rule.title.isNotEmpty ? rule.title : rule.description);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: quizText(15, wMedium, hc.text))),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: hc.purpleTint, borderRadius: BorderRadius.circular(100)),
            child: Text(context.x.l10n.xpPlusValue(rule.xp), style: quizText(12, wSemibold, hc.purple)),
          ),
        ],
      ),
    );
  }

  /// Icon + tint background + icon color for a rule type.
  (IconData, Color, Color) _iconFor(BuildContext context, String type) {
    final hc = context.x.homeColors;
    return switch (type) {
      'correct_answer' || 'correct' => (Icons.check_circle_rounded, hc.successTint, hc.success),
      'streak' || 'daily_streak' => (Icons.local_fire_department_rounded, hc.warningTint, hc.warning),
      'test_complete' || 'complete' || 'finish' || 'test' => (Icons.emoji_events_rounded, hc.primaryTint, hc.primary),
      'perfect' || 'perfect_score' => (Icons.workspace_premium_rounded, hc.purpleTint, hc.purple),
      'first_attempt' || 'first_try' || 'first' => (Icons.star_rounded, hc.warningTint, hc.warning),
      'daily' || 'daily_goal' || 'goal' => (Icons.calendar_today_rounded, hc.tealTint, hc.teal),
      'referral' || 'invite' => (Icons.card_giftcard_rounded, hc.successTint, hc.success),
      _ => (Icons.bolt_rounded, hc.primaryTint, hc.primary),
    };
  }
}

class _CapNote extends StatelessWidget {
  const _CapNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: hc.text3),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: quizText(13, wRegular, hc.text3, height: 1.35))),
      ],
    );
  }
}

String _capLabel(String cap) => switch (cap) {
  'once_per_question_per_day' => 'Har bir savolga kuniga 1 marta',
  'once_per_session' => 'Har bir sessiyada 1 marta',
  'once_per_day' => 'Kuniga 1 marta',
  'once_per_week' => 'Haftada 1 marta',
  'once_per_test' => 'Har bir testda 1 marta',
  _ => cap.replaceAll('_', ' '),
};

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: hc.bg, shape: BoxShape.circle),
        child: Icon(Icons.close_rounded, size: 18, color: hc.text2),
      ),
    );
  }
}
