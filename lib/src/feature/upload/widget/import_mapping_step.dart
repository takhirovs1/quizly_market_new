import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/import_mapping_cubit.dart';
import '../model/import_mapping_models.dart';

/// Column-mapping wizard body (step 2 of the file-import flow).
///
/// Mobile: one scrollable column. Desktop/tablet (≥900px): the raw grid and
/// mapping controls on the left, the live parsed preview on the right — both
/// fully virtualized, so ALL rows/questions are reachable, not a sample.
class ImportMappingStep extends StatelessWidget {
  const ImportMappingStep({required this.cubit, required this.onConfirm, super.key});

  final ImportMappingCubit cubit;
  final VoidCallback onConfirm;

  /// 0 → "A", 1 → "B", … 26 → "AA".
  static String columnLetter(int index) {
    var i = index;
    var s = '';
    do {
      s = String.fromCharCode(0x41 + (i % 26)) + s;
      i = i ~/ 26 - 1;
    } while (i >= 0);
    return s;
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ImportMappingCubit, ImportMappingState>(
    bloc: cubit,
    builder: (context, state) {
      final sheet = state.sheet;
      if (sheet == null) return const SizedBox.shrink();

      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (!isWide) return _MobileLayout(cubit: cubit, state: state, onConfirm: onConfirm);
          return _WideLayout(cubit: cubit, state: state, onConfirm: onConfirm);
        },
      );
    },
  );
}

// ═══ Layouts ═════════════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.cubit, required this.state, required this.onConfirm});

  final ImportMappingCubit cubit;
  final ImportMappingState state;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const .fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _MappingControls(cubit: cubit, state: state),
              ),
            ),
            SliverPadding(
              padding: const .fromLTRB(16, 14, 16, 0),
              sliver: SliverToBoxAdapter(child: _PreviewHeader(state: state)),
            ),
            _DraftsSliver(state: state),
            SliverPadding(
              padding: const .fromLTRB(16, 10, 16, 12),
              sliver: SliverToBoxAdapter(
                child: state.issues.isEmpty ? const SizedBox.shrink() : _IssuesBox(state: state, cubit: cubit),
              ),
            ),
          ],
        ),
      ),
      _BottomBar(state: state, onConfirm: onConfirm),
    ],
  );
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.cubit, required this.state, required this.onConfirm});

  final ImportMappingCubit cubit;
  final ImportMappingState state;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1240),
      child: Padding(
        padding: const .fromLTRB(24, 16, 24, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: raw grid + mapping controls.
            Expanded(
              flex: 7,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _MappingControls(cubit: cubit, state: state, expandGrid: true),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right: live preview + issues + confirm.
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _PreviewHeader(state: state)),
                        _DraftsSliver(state: state, horizontalPadding: 0),
                        SliverToBoxAdapter(
                          child: state.issues.isEmpty
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const .only(top: 10),
                                  child: _IssuesBox(state: state, cubit: cubit),
                                ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      ],
                    ),
                  ),
                  _BottomBar(state: state, onConfirm: onConfirm, horizontalPadding: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// File chip, sheet selector, header-row stepper, grid and convention card.
class _MappingControls extends StatelessWidget {
  const _MappingControls({required this.cubit, required this.state, this.expandGrid = false});

  final ImportMappingCubit cubit;
  final ImportMappingState state;

  /// Wide layout: let the grid take more vertical space.
  final bool expandGrid;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FileChipRow(state: state),
      if (state.sheets.length > 1) ...[
        const SizedBox(height: 10),
        _SheetSelector(state: state, onSelect: cubit.selectSheet),
      ],
      const SizedBox(height: 12),
      _HeaderRowSelector(state: state, onChanged: cubit.setHeaderRow),
      const SizedBox(height: 10),
      _PreviewGrid(state: state, onRole: cubit.setColumnRole, onHeaderRow: cubit.setHeaderRow, tall: expandGrid),
      const SizedBox(height: 14),
      _ConventionCard(
        state: state,
        onSource: cubit.setCorrectSource,
        onKind: cubit.setKeyKind,
        onAlwaysColumn: cubit.setAlwaysCorrectColumn,
      ),
      if (state.configGap != MappingConfigGap.none) ...[const SizedBox(height: 10), _GapHint(gap: state.configGap)],
    ],
  );
}

// ═══ Pieces ══════════════════════════════════════════════════════════════════

class _FileChipRow extends StatelessWidget {
  const _FileChipRow({required this.state});

  final ImportMappingState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final rowCount = state.sheet?.rowCount ?? 0;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary.withValues(alpha: 0.18), colors.primary.withValues(alpha: 0.08)],
              begin: .topLeft,
              end: .bottomRight,
            ),
            borderRadius: .circular(12),
          ),
          child: Icon(CupertinoIcons.doc_text_fill, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                state.fileName ?? '',
                style: textStyle.sfW600s16.copyWith(color: colors.text, fontSize: 15),
                maxLines: 1,
                overflow: .ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                '${l10n.totalRowsCount(rowCount)} · ${l10n.questionsFound(state.drafts.length)}',
                style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetSelector extends StatelessWidget {
  const _SheetSelector({required this.state, required this.onSelect});

  final ImportMappingState state;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(context.x.l10n.selectSheet, style: textStyle.sfW500s14.copyWith(color: colors.bannerSecondaryText)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: .horizontal,
            itemCount: state.sheets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final selected = i == state.sheetIndex;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const .symmetric(horizontal: 16),
                  alignment: .center,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.selectionPillUnselectedBackground,
                    borderRadius: .circular(10),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    state.sheets[i].name,
                    style: textStyle.sfW500s14.copyWith(color: selected ? colors.white : colors.text),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderRowSelector extends StatelessWidget {
  const _HeaderRowSelector({required this.state, required this.onChanged});

  final ImportMappingState state;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Row(
      children: [
        Expanded(
          child: Text(context.x.l10n.headerRowLabel, style: textStyle.sfW500s16.copyWith(color: colors.text)),
        ),
        _StepperButton(icon: CupertinoIcons.minus, onTap: () => onChanged(state.headerRow - 1)),
        SizedBox(
          width: 44,
          child: Text(
            '${state.headerRow + 1}',
            textAlign: .center,
            style: textStyle.sfW600s16.copyWith(color: colors.primary),
          ),
        ),
        _StepperButton(icon: CupertinoIcons.plus, onTap: () => onChanged(state.headerRow + 1)),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: .center,
        decoration: BoxDecoration(
          color: colors.selectionPillUnselectedBackground,
          borderRadius: .circular(12),
          border: Border.all(color: colors.divider.withValues(alpha: 0.6)),
        ),
        child: Icon(icon, size: 18, color: colors.text),
      ),
    );
  }
}

class _PreviewGrid extends StatefulWidget {
  const _PreviewGrid({required this.state, required this.onRole, required this.onHeaderRow, this.tall = false});

  final ImportMappingState state;
  final void Function(int column, ColumnRole role) onRole;
  final ValueChanged<int> onHeaderRow;
  final bool tall;

  @override
  State<_PreviewGrid> createState() => _PreviewGridState();
}

class _PreviewGridState extends State<_PreviewGrid> {
  static const double _cellWidth = 140;
  static const double _cellHeight = 40;
  static const double _gutterWidth = 44;

  final ScrollController _horizontalController = ScrollController();

  ImportMappingState get state => widget.state;
  void Function(int column, ColumnRole role) get onRole => widget.onRole;
  ValueChanged<int> get onHeaderRow => widget.onHeaderRow;
  bool get tall => widget.tall;

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isDark = context.x.isDarkMode;
    final sheet = state.sheet!;
    // ALL rows are shown — the inner list is virtualized (itemExtent), so
    // thousands of rows scroll smoothly.
    final rowCount = sheet.rowCount;
    final columnCount = sheet.columnCount;

    // Answer letters follow the left-to-right order of answer columns.
    final answerOrder = <int, int>{};
    for (var i = 0; i < state.answerColumns.length; i++) {
      answerOrder[state.answerColumns[i]] = i;
    }

    final maxViewport = tall ? 460.0 : (MediaQuery.sizeOf(context).height * 0.42).clamp(260.0, 420.0);
    final gridHeight = (_cellHeight * rowCount).clamp(_cellHeight * 2, maxViewport);

    return Container(
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.white,
        borderRadius: .circular(16),
        border: Border.all(color: colors.divider),
        boxShadow: [BoxShadow(color: colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: SizedBox(
        height: gridHeight + 57,
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: .horizontal,
            child: SizedBox(
              width: _gutterWidth + _cellWidth * columnCount,
              child: Column(
                children: [
                  // Role assignment header.
                  SizedBox(
                    height: 56,
                    child: ColoredBox(
                      color: isDark ? colors.scaffoldBackground.withValues(alpha: 0.4) : colors.buttonFill,
                      child: Row(
                        children: [
                          const SizedBox(width: _gutterWidth),
                          for (var c = 0; c < columnCount; c++)
                            SizedBox(
                              width: _cellWidth,
                              child: Padding(
                                padding: const .symmetric(horizontal: 4, vertical: 8),
                                child: _RoleDropdown(
                                  role: state.roles[c] ?? ColumnRole.ignore,
                                  columnLetter: ImportMappingStep.columnLetter(c),
                                  answerLetter: answerOrder.containsKey(c)
                                      ? ImportMappingStep.columnLetter(answerOrder[c]!)
                                      : null,
                                  onSelected: (role) => onRole(c, role),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: colors.divider),
                  // ALL raw rows, virtualized.
                  Expanded(
                    child: ListView.builder(
                      itemCount: rowCount,
                      itemExtent: _cellHeight,
                      itemBuilder: (context, r) {
                        final isHeader = r == state.headerRow;
                        final row = sheet.rows[r];
                        final zebra = r.isOdd && !isHeader;
                        return ColoredBox(
                          color: isHeader
                              ? colors.primary.withValues(alpha: 0.09)
                              : zebra
                              ? colors.textFieldBackground.withValues(alpha: isDark ? 0.35 : 0.55)
                              : colors.transparent,
                          child: Row(
                            children: [
                              // Row gutter — tap to mark this row as the header.
                              GestureDetector(
                                onTap: () => onHeaderRow(r),
                                behavior: .opaque,
                                child: SizedBox(
                                  width: _gutterWidth,
                                  child: Center(
                                    child: Text(
                                      '${r + 1}',
                                      style: textStyle.sfW500s14.copyWith(
                                        color: isHeader ? colors.primary : colors.bannerSecondaryText,
                                        fontWeight: isHeader ? .w700 : .w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              for (var c = 0; c < columnCount; c++)
                                Container(
                                  width: _cellWidth,
                                  padding: const .symmetric(horizontal: 10),
                                  alignment: .centerLeft,
                                  decoration: BoxDecoration(
                                    border: Border(left: BorderSide(color: colors.divider.withValues(alpha: 0.4))),
                                  ),
                                  child: Text(
                                    c < row.length ? row[c] : '',
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    style: textStyle.sfW400s14.copyWith(
                                      color: (state.roles[c] ?? ColumnRole.ignore) == ColumnRole.ignore
                                          ? colors.bannerSecondaryText
                                          : colors.text,
                                      fontWeight: isHeader ? .w600 : .w400,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.role, required this.columnLetter, required this.onSelected, this.answerLetter});

  final ColumnRole role;

  /// The spreadsheet column letter (A, B, C…), shown for ignored columns.
  final String columnLetter;

  /// The answer slot letter when [role] is [ColumnRole.answer].
  final String? answerLetter;
  final ValueChanged<ColumnRole> onSelected;

  static String roleLabel(BuildContext context, ColumnRole role, {String? letter}) {
    final l10n = context.x.l10n;
    return switch (role) {
      ColumnRole.ignore => l10n.columnRoleIgnore,
      ColumnRole.question => l10n.columnRoleQuestion,
      ColumnRole.answer => letter == null ? l10n.columnRoleAnswer : '${l10n.columnRoleAnswer} $letter',
      ColumnRole.correct => l10n.columnRoleCorrect,
      ColumnRole.category => l10n.columnRoleCategory,
      ColumnRole.topic => l10n.columnRoleTopic,
      ColumnRole.difficulty => l10n.columnRoleDifficulty,
    };
  }

  static Color roleColor(BuildContext context, ColumnRole role) {
    final colors = context.x.colors;
    return switch (role) {
      ColumnRole.ignore => colors.bannerSecondaryText,
      ColumnRole.question => colors.primary,
      ColumnRole.answer => colors.appleGreen,
      ColumnRole.correct => colors.orange,
      _ => colors.tealBlue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isDark = context.x.isDarkMode;
    final accent = roleColor(context, role);
    final isIgnore = role == ColumnRole.ignore;

    return PopupMenuButton<ColumnRole>(
      onSelected: onSelected,
      tooltip: '',
      elevation: 10,
      color: isDark ? colors.cardBackground2 : colors.white,
      shadowColor: colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(14),
        side: BorderSide(color: colors.divider.withValues(alpha: 0.6)),
      ),
      offset: const Offset(0, 44),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      itemBuilder: (context) => [
        for (final r in ColumnRole.values)
          PopupMenuItem(
            value: r,
            height: 42,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: roleColor(context, r), shape: .circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    roleLabel(context, r),
                    style: textStyle.sfW500s14.copyWith(
                      color: r == role ? colors.primary : colors.text,
                      fontWeight: r == role ? .w700 : .w500,
                    ),
                  ),
                ),
                if (r == role) Icon(CupertinoIcons.checkmark_alt, size: 16, color: colors.primary),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        padding: const .symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isIgnore ? colors.transparent : accent.withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: .circular(10),
          border: Border.all(
            color: accent.withValues(alpha: isIgnore ? 0.35 : 0.7),
            width: isIgnore ? 1 : 1.3,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isIgnore
                    ? '$columnLetter · ${roleLabel(context, role)}'
                    : roleLabel(context, role, letter: answerLetter),
                maxLines: 1,
                overflow: .ellipsis,
                style: textStyle.sfW600s16.copyWith(
                  fontSize: 13,
                  color: isIgnore ? colors.bannerSecondaryText : accent,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 13,
              color: isIgnore ? colors.bannerSecondaryText : accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConventionCard extends StatelessWidget {
  const _ConventionCard({
    required this.state,
    required this.onSource,
    required this.onKind,
    required this.onAlwaysColumn,
  });

  final ImportMappingState state;
  final ValueChanged<CorrectSource> onSource;
  final ValueChanged<AnswerKeyKind> onKind;
  final ValueChanged<int> onAlwaysColumn;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final isDark = context.x.isDarkMode;

    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.white,
        borderRadius: .circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(l10n.correctConventionTitle, style: textStyle.sfW600s16.copyWith(color: colors.text)),
          const SizedBox(height: 12),
          _ConventionTile(
            title: l10n.conventionSeparateColumn,
            subtitle: l10n.conventionSeparateColumnDesc,
            selected: state.correctSource == CorrectSource.column,
            onTap: () => onSource(CorrectSource.column),
          ),
          if (state.correctSource == CorrectSource.column) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in AnswerKeyKind.values)
                  _KindChip(kind: kind, selected: state.keyKind == kind, onTap: () => onKind(kind)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _ConventionTile(
            title: l10n.conventionFixedColumn,
            subtitle: l10n.conventionFixedColumnDesc,
            selected: state.correctSource == CorrectSource.fixedAnswerColumn,
            onTap: () => onSource(CorrectSource.fixedAnswerColumn),
          ),
          if (state.correctSource == CorrectSource.fixedAnswerColumn && state.answerColumns.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < state.answerColumns.length; i++)
                  _LetterChip(
                    letter: ImportMappingStep.columnLetter(i),
                    selected: state.alwaysCorrectColumn == state.answerColumns[i],
                    onTap: () => onAlwaysColumn(state.answerColumns[i]),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ConventionTile extends StatelessWidget {
  const _ConventionTile({required this.title, required this.subtitle, required this.selected, required this.onTap});

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return GestureDetector(
      onTap: onTap,
      behavior: .opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const .symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.07) : colors.transparent,
          borderRadius: .circular(12),
          border: Border.all(color: selected ? colors.primary : colors.divider, width: selected ? 1.4 : 1),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                selected ? CupertinoIcons.smallcircle_fill_circle_fill : CupertinoIcons.circle,
                key: ValueKey(selected),
                size: 20,
                color: selected ? colors.primary : colors.divider,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(title, style: textStyle.sfW500s16.copyWith(color: colors.text, fontSize: 15)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: textStyle.sfW400s14.copyWith(color: colors.bannerSecondaryText, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.kind, required this.selected, required this.onTap});

  final AnswerKeyKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;
    final label = switch (kind) {
      AnswerKeyKind.auto => l10n.answerKeyKindAuto,
      AnswerKeyKind.byIndex => l10n.answerKeyKindIndex,
      AnswerKeyKind.byLabel => l10n.answerKeyKindLabel,
      AnswerKeyKind.byText => l10n.answerKeyKindText,
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 36,
        padding: const .symmetric(horizontal: 14),
        alignment: .center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.selectionPillUnselectedBackground,
          borderRadius: .circular(10),
          boxShadow: selected
              ? [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(label, style: textStyle.sfW500s14.copyWith(color: selected ? colors.white : colors.text)),
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({required this.letter, required this.selected, required this.onTap});

  final String letter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46,
        height: 42,
        alignment: .center,
        decoration: BoxDecoration(
          color: selected ? colors.orange : colors.selectionPillUnselectedBackground,
          borderRadius: .circular(12),
          boxShadow: selected
              ? [BoxShadow(color: colors.orange.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(letter, style: textStyle.sfW600s16.copyWith(color: selected ? colors.white : colors.text)),
      ),
    );
  }
}

class _GapHint extends StatelessWidget {
  const _GapHint({required this.gap});

  final MappingConfigGap gap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final text = switch (gap) {
      MappingConfigGap.question => l10n.mappingGapQuestion,
      MappingConfigGap.answers => l10n.mappingGapAnswers,
      MappingConfigGap.correct => l10n.mappingGapCorrect,
      MappingConfigGap.none => '',
    };
    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.orange.withValues(alpha: 0.08),
        borderRadius: .circular(12),
        border: Border.all(color: colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 18, color: colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: context.x.textStyle.sfW500s14.copyWith(color: colors.orange)),
          ),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.state});

  final ImportMappingState state;

  @override
  Widget build(BuildContext context) {
    if (state.drafts.isEmpty) return const SizedBox.shrink();
    return Text(
      '${context.x.l10n.livePreviewTitle} · ${state.drafts.length}',
      style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
    );
  }
}

/// ALL reconstructed questions, virtualized (SliverList.builder).
class _DraftsSliver extends StatelessWidget {
  const _DraftsSliver({required this.state, this.horizontalPadding = 16});

  final ImportMappingState state;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 0),
    sliver: SliverList.builder(
      itemCount: state.drafts.length,
      itemBuilder: (context, i) => _DraftPreviewCard(draft: state.drafts[i]),
    ),
  );
}

class _DraftPreviewCard extends StatelessWidget {
  const _DraftPreviewCard({required this.draft});

  final MappedQuestionDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final isDark = context.x.isDarkMode;

    return Container(
      margin: const .only(bottom: 8),
      padding: const .all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.cardBackground2 : colors.white,
        borderRadius: .circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text('${draft.sourceRow}. ${draft.question}', style: textStyle.sfW500s14.copyWith(color: colors.text)),
          const SizedBox(height: 8),
          for (var i = 0; i < draft.options.length; i++)
            Container(
              margin: const .only(top: 4),
              padding: const .symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: draft.correctFlags[i]
                    ? colors.appleGreen.withValues(alpha: isDark ? 0.14 : 0.09)
                    : colors.transparent,
                borderRadius: .circular(8),
              ),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Icon(
                    draft.correctFlags[i] ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                    size: 16,
                    color: draft.correctFlags[i] ? colors.appleGreen : colors.divider,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      draft.options[i],
                      style: textStyle.sfW400s14.copyWith(
                        color: draft.correctFlags[i] ? colors.text : colors.bannerSecondaryText,
                        fontWeight: draft.correctFlags[i] ? .w600 : .w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _IssuesBox extends StatelessWidget {
  const _IssuesBox({required this.state, required this.cubit});

  final ImportMappingState state;
  final ImportMappingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    String issueText(MappingIssueKind kind) => switch (kind) {
      MappingIssueKind.noQuestion => l10n.rowIssueNoQuestion,
      MappingIssueKind.tooFewOptions => l10n.rowIssueTooFewOptions,
      MappingIssueKind.noCorrect => l10n.rowIssueNoCorrect,
    };

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.06),
        borderRadius: .circular(14),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.xmark_octagon_fill, size: 16, color: colors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.invalidRowsCount(state.issues.length),
                  style: textStyle.sfW600s16.copyWith(color: colors.error, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final issue in state.issues.take(5))
            Text(
              '· ${l10n.rowErrorMessage(issue.row, issueText(issue.kind))}',
              style: textStyle.sfW400s14.copyWith(color: colors.error),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(l10n.skipInvalidRows, style: textStyle.sfW500s14.copyWith(color: colors.text)),
              ),
              CupertinoSwitch(
                value: state.skipInvalid,
                onChanged: cubit.toggleSkipInvalid,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.onConfirm, this.horizontalPadding = 16});

  final ImportMappingState state;
  final VoidCallback onConfirm;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final l10n = context.x.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider.withValues(alpha: 0.6))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      l10n.validQuestionsReady(state.drafts.length),
                      style: textStyle.sfW600s16.copyWith(color: colors.text),
                    ),
                    if (state.issues.isNotEmpty)
                      Text(
                        l10n.invalidRowsCount(state.issues.length),
                        style: textStyle.sfW400s14.copyWith(color: colors.error, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: state.canConfirm ? onConfirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: .circular(14)),
                  ),
                  child: Padding(
                    padding: const .symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(l10n.continueText, style: textStyle.sfW600s16.copyWith(color: colors.white)),
                        const SizedBox(width: 6),
                        Icon(CupertinoIcons.arrow_right, size: 16, color: colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
