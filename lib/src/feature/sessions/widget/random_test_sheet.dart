import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';

/// Figma "D1/D2 · Random test sheet" — pick how many random questions (10/20/30)
/// from the user's purchased tests, or a locked state when they own none.
Future<void> showRandomTestSheet(
  BuildContext context, {
  required bool hasPurchased,
  required void Function(int count) onStart,
  required VoidCallback onGoToMarket,
}) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (sheetContext) => _RandomSheet(
    hasPurchased: hasPurchased,
    onStart: (count) {
      Navigator.of(sheetContext).pop();
      onStart(count);
    },
    onGoToMarket: () {
      Navigator.of(sheetContext).pop();
      onGoToMarket();
    },
  ),
);

const _counts = [10, 20, 30];

class _RandomSheet extends StatefulWidget {
  const _RandomSheet({required this.hasPurchased, required this.onStart, required this.onGoToMarket});

  final bool hasPurchased;
  final void Function(int count) onStart;
  final VoidCallback onGoToMarket;

  @override
  State<_RandomSheet> createState() => _RandomSheetState();
}

class _RandomSheetState extends State<_RandomSheet> {
  int _count = 20;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Container(
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
              const SizedBox(height: 12),
              Text(l10n.homeActionRandom, style: quizText(17, wBold, hc.text)),
              const SizedBox(height: 16),
              if (widget.hasPurchased) _picker(context) else _locked(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picker(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.randomPurchasedHint, style: quizText(13, wRegular, hc.text3)),
        const SizedBox(height: 16),
        Text(l10n.randomQuestionsCount, style: quizText(14, wSemibold, hc.text)),
        const SizedBox(height: 10),
        _Segmented(counts: _counts, selected: _count, onSelect: (c) => setState(() => _count = c)),
        const SizedBox(height: 20),
        QuizButton(label: l10n.randomStart, size: QuizButtonSize.l, expand: true, onTap: () => widget.onStart(_count)),
      ],
    );
  }

  Widget _locked(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: hc.bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('🔒', style: TextStyle(fontSize: 32)),
        ),
        const SizedBox(height: 16),
        Text(l10n.randomLockedTitle, textAlign: TextAlign.center, style: quizText(17, wSemibold, hc.text)),
        const SizedBox(height: 6),
        Text(l10n.randomLockedDesc, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3, height: 1.4)),
        const SizedBox(height: 20),
        QuizButton(label: l10n.homeGoToMarket, size: QuizButtonSize.l, expand: true, onTap: widget.onGoToMarket),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.counts, required this.selected, required this.onSelect});

  final List<int> counts;
  final int selected;
  final void Function(int count) onSelect;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: hc.bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final c in counts)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(c),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c == selected ? hc.surface : colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: c == selected ? [hc.softShadow] : null,
                  ),
                  child: Text('$c', style: quizText(15, wSemibold, c == selected ? hc.primary : hc.text2)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
