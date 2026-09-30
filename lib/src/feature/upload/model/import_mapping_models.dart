import 'test_question_model.dart';

/// Role the user assigns to a spreadsheet column in the mapping wizard.
enum ColumnRole {
  ignore,
  question,
  answer,
  correct,
  category,
  topic,
  difficulty;

  bool get isAnswer => this == ColumnRole.answer;
}

/// How the file marks the correct answer ("To'g'ri javob qanday belgilangan?").
enum CorrectSource {
  /// A separate column holds the key (index / label / exact answer text).
  column,

  /// One answer column is always the correct one; the rest are wrong.
  fixedAnswerColumn,
}

/// Interpretation of the values inside the correct-answer column.
enum AnswerKeyKind {
  /// Pick the best interpretation per row from samples.
  auto,

  /// Numeric or letter index: `1`/`A` → first answer column.
  byIndex,

  /// A label such as "Variant 2" / "Javob B" / "Option C".
  byLabel,

  /// The exact text of the correct answer.
  byText,
}

/// A problem with one source row, keyed for localization.
class MappingRowIssue {
  const MappingRowIssue({required this.row, required this.kind});

  /// 1-based row number as shown in the preview grid.
  final int row;
  final MappingIssueKind kind;
}

enum MappingIssueKind { noQuestion, tooFewOptions, noCorrect }

/// One successfully reconstructed question from the mapped file.
class MappedQuestionDraft {
  const MappedQuestionDraft({
    required this.sourceRow,
    required this.question,
    required this.options,
    required this.correctFlags,
  });

  /// 1-based source row (for tracing back to the grid).
  final int sourceRow;
  final String question;
  final List<String> options;
  final List<bool> correctFlags;

  /// Converts the draft into the editable model used by the review screen.
  QuestionModel toQuestionModel() {
    final model = QuestionModel(
      answers: [
        for (var i = 0; i < options.length; i++)
          AnswerModel(isCorrect: correctFlags[i])..nativeController.text = options[i],
      ],
      isExpanded: false,
    );
    model.nativeController.text = question;
    return model;
  }
}

/// In-memory handoff of imported questions into the review/edit screen.
///
/// Octopus route arguments are `Map<String, String>` — a question list cannot
/// travel through them, so the wizard parks the built models here and the
/// review screen takes (and clears) them in `initState`.
abstract final class ImportHandoff {
  static List<QuestionModel>? _questions;

  static void put(List<QuestionModel> questions) => _questions = questions;

  /// Returns the pending questions once, clearing the slot.
  static List<QuestionModel>? take() {
    final q = _questions;
    _questions = null;
    return q;
  }
}
