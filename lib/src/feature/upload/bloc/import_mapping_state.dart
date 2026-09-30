part of 'import_mapping_cubit.dart';

class ImportMappingState extends Equatable {
  const ImportMappingState({
    this.parseStatus = StateStatus.idle,
    this.fileName,
    this.sheets = const [],
    this.sheetIndex = 0,
    this.headerRow = 0,
    this.roles = const {},
    this.correctSource = CorrectSource.column,
    this.keyKind = AnswerKeyKind.auto,
    this.alwaysCorrectColumn,
    this.skipInvalid = true,
    this.drafts = const [],
    this.issues = const [],
  });

  final StateStatus parseStatus;
  final String? fileName;
  final List<SheetData> sheets;
  final int sheetIndex;

  /// Which row is the header ("Sarlavha qatori"), 0-based.
  final int headerRow;

  /// Column index → assigned role. Unassigned columns are ignored.
  final Map<int, ColumnRole> roles;

  final CorrectSource correctSource;
  final AnswerKeyKind keyKind;

  /// For [CorrectSource.fixedAnswerColumn]: the always-correct answer column.
  final int? alwaysCorrectColumn;

  /// Whether invalid rows are silently skipped ("Xato qatorlarni o'tkazib yuborish").
  final bool skipInvalid;

  /// Live-reconstructed questions under the current mapping.
  final List<MappedQuestionDraft> drafts;

  /// Rows the current mapping cannot turn into a valid question.
  final List<MappingRowIssue> issues;

  SheetData? get sheet => sheets.elementAtOrNull(sheetIndex);
  bool get hasFile => parseStatus.isSuccess && sheet != null;

  int? get questionColumn => roles.entries.where((e) => e.value == ColumnRole.question).map((e) => e.key).firstOrNull;

  /// Answer columns in left-to-right order (A, B, C… by position).
  List<int> get answerColumns => (roles.entries.where((e) => e.value.isAnswer).map((e) => e.key).toList()..sort());

  int? get correctColumn => roles.entries.where((e) => e.value == ColumnRole.correct).map((e) => e.key).firstOrNull;

  /// Which config piece is still missing, if any (drives the inline hint).
  MappingConfigGap get configGap {
    if (questionColumn == null) return MappingConfigGap.question;
    if (answerColumns.length < 2) return MappingConfigGap.answers;
    if (correctSource == CorrectSource.fixedAnswerColumn) {
      if (alwaysCorrectColumn == null) return MappingConfigGap.correct;
    } else if (correctColumn == null) {
      return MappingConfigGap.correct;
    }
    return MappingConfigGap.none;
  }

  bool get canConfirm =>
      hasFile && configGap == MappingConfigGap.none && drafts.isNotEmpty && (issues.isEmpty || skipInvalid);

  ImportMappingState copyWith({
    StateStatus? parseStatus,
    String? fileName,
    List<SheetData>? sheets,
    int? sheetIndex,
    int? headerRow,
    Map<int, ColumnRole>? roles,
    CorrectSource? correctSource,
    AnswerKeyKind? keyKind,
    int? alwaysCorrectColumn,
    bool? skipInvalid,
    List<MappedQuestionDraft>? drafts,
    List<MappingRowIssue>? issues,
    bool resetCorrectConfig = false,
  }) => ImportMappingState(
    parseStatus: parseStatus ?? this.parseStatus,
    fileName: fileName ?? this.fileName,
    sheets: sheets ?? this.sheets,
    sheetIndex: sheetIndex ?? this.sheetIndex,
    headerRow: headerRow ?? this.headerRow,
    roles: roles ?? this.roles,
    correctSource: correctSource ?? this.correctSource,
    keyKind: keyKind ?? this.keyKind,
    alwaysCorrectColumn: resetCorrectConfig ? null : (alwaysCorrectColumn ?? this.alwaysCorrectColumn),
    skipInvalid: skipInvalid ?? this.skipInvalid,
    drafts: drafts ?? this.drafts,
    issues: issues ?? this.issues,
  );

  @override
  List<Object?> get props => [
    parseStatus,
    fileName,
    sheets,
    sheetIndex,
    headerRow,
    roles,
    correctSource,
    keyKind,
    alwaysCorrectColumn,
    skipInvalid,
    drafts,
    issues,
  ];
}

/// The missing piece blocking confirmation, for inline guidance.
enum MappingConfigGap { none, question, answers, correct }
