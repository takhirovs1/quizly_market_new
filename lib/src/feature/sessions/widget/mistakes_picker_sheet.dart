import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../data/session_repository.dart';
import '../model/session_models.dart';

/// Figma "E · Mistakes flow" picker — practise all mistakes or the ones from a
/// single test; an empty state when there are none left. [onStart] receives the
/// chosen test id, or null for all tests.
Future<void> showMistakesPickerSheet(
  BuildContext context, {
  required ISessionRepository repository,
  required void Function(String? testId) onStart,
  required VoidCallback onGoToMarket,
}) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (sheetContext) => _MistakesSheet(
    repository: repository,
    onStart: (testId) {
      Navigator.of(sheetContext).pop();
      onStart(testId);
    },
    onGoToMarket: () {
      Navigator.of(sheetContext).pop();
      onGoToMarket();
    },
  ),
);

class _MistakesSheet extends StatefulWidget {
  const _MistakesSheet({required this.repository, required this.onStart, required this.onGoToMarket});

  final ISessionRepository repository;
  final void Function(String? testId) onStart;
  final VoidCallback onGoToMarket;

  @override
  State<_MistakesSheet> createState() => _MistakesSheetState();
}

class _MistakesSheetState extends State<_MistakesSheet> {
  MistakesSummary? _summary;
  bool _loading = true;
  String? _selected; // null = all mistakes

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final summary = await widget.repository.mistakesSummary();
      if (mounted) setState(() {
        _summary = summary;
        _loading = false;
      });
    } on Object {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final summary = _summary;
    final isEmpty = !_loading && (summary == null || summary.total == 0);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
              Text(l10n.mistakesSheetTitle, style: quizText(17, wBold, hc.text)),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator.adaptive())
              else if (isEmpty)
                _empty(context)
              else
                _content(context, summary!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: hc.successTint, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('🎉', style: TextStyle(fontSize: 32)),
        ),
        const SizedBox(height: 16),
        Text(l10n.mistakesEmptyTitle, textAlign: TextAlign.center, style: quizText(17, wSemibold, hc.text)),
        const SizedBox(height: 6),
        Text(l10n.mistakesEmptyDesc, textAlign: TextAlign.center, style: quizText(14, wRegular, hc.text3, height: 1.4)),
        const SizedBox(height: 20),
        QuizButton(label: l10n.homeGoToMarket, type: QuizButtonType.tonal, size: QuizButtonSize.l, expand: true, onTap: widget.onGoToMarket),
      ],
    );
  }

  Widget _content(BuildContext context, MistakesSummary summary) {
    final l10n = context.x.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              _row(context, label: l10n.mistakesAll, count: summary.total, id: null),
              for (final t in summary.byTest) ...[
                const SizedBox(height: 8),
                _row(context, label: t.name, count: t.count, id: t.testId),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        QuizButton(
          label: l10n.retryTest,
          size: QuizButtonSize.l,
          expand: true,
          onTap: () => widget.onStart(_selected),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, {required String label, required int count, required String? id}) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final selected = _selected == id;
    return GestureDetector(
      onTap: () => setState(() => _selected = id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? hc.primaryTint : hc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? hc.primary : hc.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: quizText(15, wSemibold, hc.text),
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.mistakesCountLabel(count), style: quizText(13, wSemibold, colors.answerWrong)),
          ],
        ),
      ),
    );
  }
}
