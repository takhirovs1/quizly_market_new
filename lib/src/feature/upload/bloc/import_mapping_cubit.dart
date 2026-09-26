import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../model/import_mapping_models.dart';
import '../util/spreadsheet_codec.dart';

part 'import_mapping_state.dart';

/// Client-side column-mapping wizard for imported spreadsheets.
///
/// The user uploads ANY xlsx/csv; nothing is sent to the backend here. The
/// cubit parses the file, guesses a mapping, lets the user adjust it, and
/// rebuilds the parsed-question preview after every change
/// (docs/upload_backend_integration.md §2).
class ImportMappingCubit extends Cubit<ImportMappingState> {
  ImportMappingCubit() : super(const ImportMappingState());

  /// Hard cap on processed data rows — keeps recompute instant on huge files.
  static const int maxRows = 5000;

  // ─── Parsing ──────────────────────────────────────────────────────────────

  Future<void> parseFile({required List<int> bytes, required String fileName}) async {
    emit(const ImportMappingState(parseStatus: StateStatus.loading));
    try {
      // Yield one frame so the shimmer shows before the synchronous decode.
      await Future<void>.delayed(Duration.zero);
      final sheets = SpreadsheetCodec.decode(bytes, fileName);
      emit(ImportMappingState(parseStatus: StateStatus.success, fileName: fileName, sheets: sheets));
      selectSheet(0);
    } on Object catch (e, s) {
      info('IMPORT PARSE ERROR: $e $s');
      emit(const ImportMappingState(parseStatus: StateStatus.error));
    }
  }

  void reset() => emit(const ImportMappingState());

  // ─── Wizard mutations ─────────────────────────────────────────────────────

  void selectSheet(int index) {
    final sheet = state.sheets.elementAtOrNull(index);
    if (sheet == null) return;
    final headerRow = _guessHeaderRow(sheet);
    final roles = _guessRoles(sheet, headerRow);
    _recompute(state.copyWith(sheetIndex: index, headerRow: headerRow, roles: roles, resetCorrectConfig: true));
  }

  void setHeaderRow(int row) {
    final sheet = state.sheet;
    if (sheet == null || row < 0 || row >= sheet.rowCount) return;
    _recompute(state.copyWith(headerRow: row));
  }

  void setColumnRole(int column, ColumnRole role) {
    final roles = Map<int, ColumnRole>.from(state.roles);
    // Question and correct are single-column roles: reassigning moves them.
    if (role == ColumnRole.question || role == ColumnRole.correct) {
      roles.removeWhere((_, r) => r == role);
    }
    roles[column] = role;
    var next = state.copyWith(roles: roles);
    // Assigning a key column implies the separate-column convention.
    if (role == ColumnRole.correct) next = next.copyWith(correctSource: CorrectSource.column);
    // The always-correct pick must stay a valid answer column.
    if (state.alwaysCorrectColumn == column && role != ColumnRole.answer) {
      next = next.copyWith(resetCorrectConfig: true, correctSource: next.correctSource);
    }
    _recompute(next);
  }

  void setCorrectSource(CorrectSource source) => _recompute(state.copyWith(correctSource: source));

  void setKeyKind(AnswerKeyKind kind) => _recompute(state.copyWith(keyKind: kind));

  void setAlwaysCorrectColumn(int column) {
    if (state.roles[column] != ColumnRole.answer) return;
    _recompute(state.copyWith(alwaysCorrectColumn: column, correctSource: CorrectSource.fixedAnswerColumn));
  }

  void toggleSkipInvalid(bool value) => _recompute(state.copyWith(skipInvalid: value));

  // ─── Auto-guessing ────────────────────────────────────────────────────────

  int _guessHeaderRow(SheetData sheet) {
    final limit = sheet.rowCount < 5 ? sheet.rowCount : 5;
    for (var r = 0; r < limit; r++) {
      final row = sheet.rows[r];
      final filled = row.where((c) => c.isNotEmpty).length;
      if (filled < 2) continue;
      if (row.any((c) => _roleFromHeader(c) != null)) return r;
    }
    for (var r = 0; r < limit; r++) {
      if (sheet.rows[r].where((c) => c.isNotEmpty).length >= 2) return r;
    }
    return 0;
  }

  Map<int, ColumnRole> _guessRoles(SheetData sheet, int headerRow) {
    final headers = sheet.rows[headerRow];
    final roles = <int, ColumnRole>{};
    var hasQuestion = false;
    var hasCorrect = false;
    for (var c = 0; c < headers.length; c++) {
      final role = _roleFromHeader(headers[c]);
      if (role == null) continue;
      if (role == ColumnRole.question) {
        if (hasQuestion) continue;
        hasQuestion = true;
      }
      if (role == ColumnRole.correct) {
        if (hasCorrect) continue;
        hasCorrect = true;
      }
      roles[c] = role;
    }

    // Positional fallback for headerless/unnamed files: Q, A…, [correct].
    final answers = roles.values.where((r) => r.isAnswer).length;
    if (!hasQuestion && answers < 2 && headers.length >= 3) {
      roles.clear();
      roles[0] = ColumnRole.question;
      final lastColumn = headers.length - 1;
      final answerEnd = headers.length >= 4 ? lastColumn - 1 : lastColumn;
      for (var c = 1; c <= answerEnd; c++) {
        roles[c] = ColumnRole.answer;
      }
      if (answerEnd < lastColumn) roles[lastColumn] = ColumnRole.correct;
    }
    return roles;
  }

  ColumnRole? _roleFromHeader(String raw) {
    final h = raw.trim().toLowerCase().replaceAll(RegExp("[’'`ʻ]"), '');
    if (h.isEmpty) return null;
    if (RegExp(r'^[a-h]$').hasMatch(h)) return ColumnRole.answer;
    if (RegExp(r'^(javob|variant|answer|option|ответ|вариант)[\s_\-]*[0-9a-h]*$').hasMatch(h)) return ColumnRole.answer;
    if (RegExp('savol|question|вопрос').hasMatch(h)) return ColumnRole.question;
    if (RegExp('correct|togri|тогри|правильн|key|kalit').hasMatch(h)) return ColumnRole.correct;
    if (RegExp('kategor|category|категор|fan|subject').hasMatch(h)) return ColumnRole.category;
    if (RegExp('mavzu|topic|тема').hasMatch(h)) return ColumnRole.topic;
    if (RegExp('qiyin|difficult|сложн|daraja|level').hasMatch(h)) return ColumnRole.difficulty;
    return null;
  }

  // ─── Question reconstruction ──────────────────────────────────────────────

  void _recompute(ImportMappingState base) {
    final sheet = base.sheets.elementAtOrNull(base.sheetIndex);
    if (sheet == null) {
      emit(base.copyWith(drafts: const [], issues: const []));
      return;
    }

    final questionColumn = base.questionColumn;
    final answerColumns = base.answerColumns;
    final correctColumn = base.correctColumn;

    final drafts = <MappedQuestionDraft>[];
    final issues = <MappingRowIssue>[];

    if (questionColumn != null && answerColumns.length >= 2) {
      final start = base.headerRow + 1;
      final end = sheet.rowCount < start + maxRows ? sheet.rowCount : start + maxRows;
      for (var r = start; r < end; r++) {
        final row = sheet.rows[r];
        if (row.every((c) => c.isEmpty)) continue; // blank separator rows
        final rowNumber = r + 1;

        String cell(int c) => c < row.length ? row[c].trim() : '';

        final question = cell(questionColumn);
        if (question.isEmpty) {
          issues.add(MappingRowIssue(row: rowNumber, kind: MappingIssueKind.noQuestion));
          continue;
        }

        // Options in answer-column order; remember each slot's original index.
        final optionTexts = <String>[];
        final slotOfOption = <int>[];
        for (var slot = 0; slot < answerColumns.length; slot++) {
          final text = cell(answerColumns[slot]);
          if (text.isEmpty) continue;
          optionTexts.add(text);
          slotOfOption.add(slot);
        }
        if (optionTexts.length < 2) {
          issues.add(MappingRowIssue(row: rowNumber, kind: MappingIssueKind.tooFewOptions));
          continue;
        }

        // Resolve correct slots per the selected convention.
        final correctSlots = <int>{};
        if (base.correctSource == CorrectSource.fixedAnswerColumn) {
          final fixed = base.alwaysCorrectColumn;
          final slot = fixed == null ? -1 : answerColumns.indexOf(fixed);
          if (slot >= 0) correctSlots.add(slot);
        } else if (correctColumn != null) {
          correctSlots.addAll(_resolveKey(cell(correctColumn), optionTexts, slotOfOption, base.keyKind));
        }

        final correctFlags = List<bool>.filled(optionTexts.length, false);
        var anyCorrect = false;
        for (final slot in correctSlots) {
          final optionIndex = slotOfOption.indexOf(slot);
          if (optionIndex >= 0) {
            correctFlags[optionIndex] = true;
            anyCorrect = true;
          }
        }
        if (!anyCorrect) {
          issues.add(MappingRowIssue(row: rowNumber, kind: MappingIssueKind.noCorrect));
          continue;
        }

        drafts.add(
          MappedQuestionDraft(
            sourceRow: rowNumber,
            question: question,
            options: optionTexts,
            correctFlags: correctFlags,
          ),
        );
      }
    }

    emit(base.copyWith(drafts: drafts, issues: issues));
  }

  /// Resolves a correct-answer key cell into answer slots (0-based, in
  /// answer-column order). Supports multi-keys like "1,3" or "A;C".
  Set<int> _resolveKey(String rawKey, List<String> optionTexts, List<int> slotOfOption, AnswerKeyKind kind) {
    final slots = <int>{};
    final parts = rawKey.split(RegExp('[,;/]')).map((p) => p.trim()).where((p) => p.isNotEmpty);
    for (final part in parts) {
      final slot = switch (kind) {
        AnswerKeyKind.byIndex => _keyAsIndex(part),
        AnswerKeyKind.byLabel => _keyAsLabel(part),
        AnswerKeyKind.byText => _keyAsText(part, optionTexts, slotOfOption),
        AnswerKeyKind.auto => _keyAsText(part, optionTexts, slotOfOption) ?? _keyAsIndex(part) ?? _keyAsLabel(part),
      };
      if (slot != null) slots.add(slot);
    }
    return slots;
  }

  /// `1` → slot 0, `A`/`a)` → slot 0. 1-based numerics.
  int? _keyAsIndex(String part) {
    final cleaned = part.toLowerCase().replaceAll(RegExp(r'[).\s]'), '');
    final number = int.tryParse(cleaned);
    if (number != null && number >= 1) return number - 1;
    if (RegExp(r'^[a-h]$').hasMatch(cleaned)) return cleaned.codeUnitAt(0) - 0x61;
    return null;
  }

  /// "Variant 2" / "Javob B" / "2-variant" → embedded index or letter.
  int? _keyAsLabel(String part) {
    final lower = part.toLowerCase();
    final number = RegExp(r'\d+').firstMatch(lower);
    if (number != null) {
      final n = int.parse(number.group(0)!);
      if (n >= 1) return n - 1;
    }
    final letter = RegExp(r'(?:^|\s)([a-h])(?:\s|$|\))').firstMatch(lower);
    if (letter != null) return letter.group(1)!.codeUnitAt(0) - 0x61;
    return null;
  }

  /// Exact (normalized) match against the row's option texts → original slot.
  int? _keyAsText(String part, List<String> optionTexts, List<int> slotOfOption) {
    String norm(String s) => s.trim().toLowerCase();
    final target = norm(part);
    if (target.isEmpty) return null;
    for (var i = 0; i < optionTexts.length; i++) {
      if (norm(optionTexts[i]) == target) return slotOfOption[i];
    }
    return null;
  }
}
