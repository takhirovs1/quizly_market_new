import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/all_tests_cubit.dart';
import '../models/home/home_enums.dart';
import '../models/home/my_tests_filters_model.dart';
import '../models/home/my_tests_preview_model.dart';
import '../widgets/home/home_test_card.dart';
import '../widgets/home/my_tests_filter_sheet.dart';

/// Figma "B · Mening testlarim — All tests": search, status chips, the filter
/// sheet, active-filter chips and the paginated card list.
class AllTestsScreen extends StatefulWidget {
  const AllTestsScreen({super.key});

  @override
  State<AllTestsScreen> createState() => _AllTestsScreenState();
}

class _AllTestsScreenState extends State<AllTestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  AllTestsCubit get _cubit => context.read<AllTestsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit
      ..load()
      ..loadFilters();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _cubit.setSearch(value.trim()));
  }

  Future<void> _openFilterSheet() async {
    final state = _cubit.state;
    final next = await showMyTestsFilterSheet(context, options: state.options, selection: state.selection);
    if (next != null) {
      _cubit
        ..applyFilters(next)
        ..loadFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        title: l10n.myTestsHeader,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AllTestsCubit, AllTestsState>(
          builder: (context, state) {
            final sel = state.selection;
            final searching = sel.search.isNotEmpty;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _searchRow(context, sel),
                ),
                if (!searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _statusChips(context, state.counts, sel.status),
                  ),
                if (sel.hasSheetFilters) _activeFilters(context, state),
                Expanded(child: _list(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _searchRow(BuildContext context, MyTestsFilterSelection sel) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: hc.border)),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: hc.text3),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: quizText(15, wRegular, hc.text),
                    cursorColor: hc.primary,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: l10n.allTestsSearchHint,
                      hintStyle: quizText(15, wRegular, hc.text3),
                    ),
                  ),
                ),
                if (sel.search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _cubit.setSearch('');
                    },
                    child: Icon(Icons.close_rounded, size: 18, color: hc.text3),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _openFilterSheet,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: hc.border)),
            child: Stack(
              children: [
                Center(child: Assets.lib.icon.filter.svg(width: 20, height: 20, package: 'ui')),
                if (sel.hasAny)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: hc.primary, shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChips(BuildContext context, MyTestsStatusCounts counts, String? status) {
    final l10n = context.x.l10n;
    final chips = <(String?, String, int)>[
      (null, l10n.homeChipAll, counts.all),
      (MyTestStatus.notStarted.value, l10n.homeStatusNotStarted, counts.notStarted),
      (MyTestStatus.inProgress.value, l10n.homeStatusInProgress, counts.inProgress),
      (MyTestStatus.completed.value, l10n.homeStatusCompleted, counts.completed),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _StatusChip(
              label: chips[i].$2,
              count: chips[i].$3,
              active: status == chips[i].$1,
              onTap: () => _cubit.setStatus(status == chips[i].$1 ? null : chips[i].$1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activeFilters(BuildContext context, AllTestsState state) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final sel = state.selection;
    String subjectName(String id) =>
        state.options.subjects.firstWhere((s) => s.id == id, orElse: () => FilterOption(id: id, name: id, count: 0)).name;
    String orgName(String id) =>
        state.options.organizations.firstWhere((o) => o.id == id, orElse: () => FilterOption(id: id, name: id, count: 0)).name;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final id in sel.subjectIds) _RemovableChip(label: subjectName(id), onRemove: () => _cubit.removeSubject(id)),
          for (final id in sel.orgIds) _RemovableChip(label: orgName(id), onRemove: () => _cubit.removeOrg(id)),
          GestureDetector(
            onTap: _cubit.clearSheetFilters,
            child: Text(l10n.allTestsClearAll, style: quizText(13, wSemibold, hc.primary)),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AllTestsState state) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    if (state.status.isLoading) return const Center(child: CircularProgressIndicator.adaptive());
    if (state.status.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorOccurred, textAlign: TextAlign.center, style: quizText(14, wMedium, hc.text3)),
              const SizedBox(height: 12),
              QuizButton(label: l10n.retry, size: QuizButtonSize.s, onTap: _cubit.load),
            ],
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: QuizEmptyState(
            card: false,
            emoji: '🔍',
            title: l10n.noTestsFound,
            description: l10n.trySearchingWithOtherKeywords,
            buttonLabel: l10n.allTestsClearAll,
            onPressed: () {
              _searchController.clear();
              _cubit
                ..setSearch('')
                ..setStatus(null)
                ..clearSheetFilters();
            },
          ),
        ),
      );
    }
    final searching = state.selection.search.isNotEmpty;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: state.items.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          final count = searching ? state.items.length : state.counts.all;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text(
              searching ? l10n.allTestsSearchCount(count) : l10n.allTestsResultsCount(count),
              style: quizText(13, wMedium, hc.text3),
            ),
          );
        }
        final item = state.items[index - 1];
        return HomeTestCard(
          title: item.name,
          organizationName: item.organizationName,
          organizationVerified: item.organizationVerified,
          status: item.status,
          answered: item.answered,
          total: item.total,
          percent: item.percent,
          resultPercent: item.bestScorePercent,
          ratingRank: item.ratingRank,
          ratingTotalParticipants: item.ratingTotalParticipants,
          onTap: () => context.octopus.push(Routes.testMode, arguments: <String, String>{'id': item.testId}),
          onRatingTap: () => context.octopus.push(
            Routes.testRating,
            arguments: <String, String>{'id': item.testId, 'name': item.name, 'org': item.organizationName},
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.count, required this.active, required this.onTap});

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeFg = isDark ? hc.surface : hc.onAccent;
    final fg = active ? activeFg : hc.text2;
    final countFg = active ? activeFg.withValues(alpha: 0.6) : hc.text3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? hc.text : hc.surface,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: hc.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: quizText(14, wSemibold, fg)),
            const SizedBox(width: 6),
            Text('$count', style: quizText(13, wMedium, countFg)),
          ],
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(color: hc.primaryTint, borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: quizText(13, wSemibold, hc.primary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 16, color: hc.primary),
          ),
        ],
      ),
    );
  }
}
