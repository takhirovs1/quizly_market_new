import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/home/my_tests_filters_model.dart';

/// Figma "B4 · Filter sheet" — Fan (subjects), Tashkilot (organizations) and
/// Saralash (sort) choices. Returns the applied [MyTestsFilterSelection], or
/// null when dismissed. Status lives in the toolbar chips, not here.
Future<MyTestsFilterSelection?> showMyTestsFilterSheet(
  BuildContext context, {
  required MyTestsFiltersResponse options,
  required MyTestsFilterSelection selection,
}) => showModalBottomSheet<MyTestsFilterSelection>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _FilterSheet(options: options, selection: selection),
);

const _sortKeys = ['last_opened', 'score', 'name'];

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.options, required this.selection});

  final MyTestsFiltersResponse options;
  final MyTestsFilterSelection selection;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _subjects = {...widget.selection.subjectIds};
  late Set<String> _orgs = {...widget.selection.orgIds};
  late String _sort = widget.selection.sort;

  MyTestsFilterSelection get _draft =>
      widget.selection.copyWith(subjectIds: _subjects, orgIds: _orgs, sort: _sort);

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final applyCount = widget.options.total;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: hc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet header: grabber + title.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: hc.track, borderRadius: BorderRadius.circular(100)),
                ),
                const SizedBox(height: 12),
                Text(l10n.filterSheetTitle, style: quizText(17, wBold, hc.text)),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              shrinkWrap: true,
              children: [
                if (widget.options.subjects.isNotEmpty) ...[
                  _section(
                    context,
                    l10n.filterSubject,
                    [
                      for (final s in widget.options.subjects)
                        _chip(context, '${s.name} · ${s.count}', _subjects.contains(s.id), () {
                          setState(() => _subjects.contains(s.id) ? _subjects.remove(s.id) : _subjects.add(s.id));
                        }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                if (widget.options.organizations.isNotEmpty) ...[
                  _section(
                    context,
                    l10n.filterOrganization,
                    [
                      for (final o in widget.options.organizations)
                        _chip(context, '${o.name} · ${o.count}', _orgs.contains(o.id), () {
                          setState(() => _orgs.contains(o.id) ? _orgs.remove(o.id) : _orgs.add(o.id));
                        }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                _sortSection(context),
              ],
            ),
          ),
          // Actions: Reset + Apply(count).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  QuizButton(
                    label: l10n.filterReset,
                    type: QuizButtonType.outline,
                    size: QuizButtonSize.l,
                    onTap: () => setState(() {
                      _subjects = {};
                      _orgs = {};
                      _sort = 'last_opened';
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuizButton(
                      label: l10n.filterApply(applyCount),
                      size: QuizButtonSize.l,
                      expand: true,
                      onTap: () => Navigator.of(context).pop(_draft),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> chips) {
    final hc = context.x.homeColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: quizText(13, wSemibold, hc.text3)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _sortSection(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final labels = {
      'last_opened': l10n.filterSortLastOpened,
      'score': l10n.filterSortScore,
      'name': l10n.filterSortName,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sort, style: quizText(13, wSemibold, hc.text3)),
        const SizedBox(height: 4),
        for (final key in _sortKeys)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _sort = key),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(child: Text(labels[key]!, style: quizText(15, wMedium, hc.text))),
                  _radio(hc, _sort == key),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _radio(HomeColors hc, bool selected) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: selected ? hc.primary : hc.border, width: 2),
    ),
    child: selected
        ? Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(color: hc.primary, shape: BoxShape.circle),
            ),
          )
        : null,
  );

  Widget _chip(BuildContext context, String label, bool active, VoidCallback onTap) {
    final hc = context.x.homeColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? hc.primary : hc.surface,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: hc.border),
        ),
        child: Text(label, style: quizText(14, wSemibold, active ? hc.onAccent : hc.text2)),
      ),
    );
  }
}
