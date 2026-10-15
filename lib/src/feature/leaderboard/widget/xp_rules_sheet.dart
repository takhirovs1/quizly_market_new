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
                      for (final cap in caps) ...[const SizedBox(height: 8), _CapNote(text: cap)],
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
    final (emoji, tint) = _iconFor(context, rule.type);
    final label = rule.text.isNotEmpty ? rule.text : rule.title;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
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

  /// Emoji + tint for a rule type. The backend sends a type string; unknown
  /// types fall back to a neutral sparkle on the primary tint.
  (String, Color) _iconFor(BuildContext context, String type) {
    final hc = context.x.homeColors;
    return switch (type) {
      'correct_answer' || 'correct' => ('✅', hc.successTint),
      'streak' || 'daily_streak' => ('🔥', hc.warningTint),
      'test_complete' || 'complete' || 'finish' || 'test' => ('🎯', hc.primaryTint),
      'perfect' || 'perfect_score' => ('💯', hc.purpleTint),
      'first_attempt' || 'first_try' || 'first' => ('⭐', hc.warningTint),
      'daily' || 'daily_goal' || 'goal' => ('📅', hc.tealTint),
      'referral' || 'invite' => ('🎁', hc.successTint),
      _ => ('✨', hc.primaryTint),
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
        Text('ⓘ', style: quizText(13, wSemibold, hc.text3)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: quizText(13, wRegular, hc.text3, height: 1.35))),
      ],
    );
  }
}

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
