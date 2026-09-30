import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

/// Backend value format tags (see docs/upload_backend_integration.md §3.1).
const String kAnswerFormatText = 'text';
const String kAnswerFormatLatex = 'latex';

/// A field that can be edited either with the native keyboard (plain text)
/// or the in-app math keyboard (TeX). Both controllers are kept alive so the
/// user can swap between modes; the active mode decides the value + format.
///
/// See docs/math_native_keyboard_flow.md §4 for the state model.
mixin DualInputField {
  /// Native (plain text) controller.
  TextEditingController get nativeController;

  /// Math (TeX) controller.
  MathFieldEditingController get mathController;

  /// Which mode is active: `false` = text, `true` = formula.
  ValueNotifier<bool> get isMathMode;

  /// Uploaded image URL for display (from `POST /api/files` → `url`), if any.
  String? imageUrl;

  /// Uploaded image path to send on create (from `POST /api/files` → `path`).
  String? imagePath;

  /// Transient UI flag: an image upload for this field is in flight.
  bool imageUploading = false;

  /// The current value: plain text in text mode, TeX in formula mode.
  String get text => isMathMode.value
      ? mathController.currentEditingValue(placeholderWhenEmpty: false).trim()
      : nativeController.text.trim();

  /// Backend format tag for the current value.
  String get answerFormat => isMathMode.value ? kAnswerFormatLatex : kAnswerFormatText;

  bool get hasText => text.isNotEmpty;
  bool get hasImage => (imageUrl != null && imageUrl!.isNotEmpty) || (imagePath != null && imagePath!.isNotEmpty);

  /// A field is "filled" if it has text or an image.
  bool get hasContent => hasText || hasImage;

  void _disposeDual() {
    nativeController.dispose();
    mathController.dispose();
    isMathMode.dispose();
  }

  /// Resets both controllers back to empty text mode.
  void resetDual() {
    nativeController.clear();
    mathController.clear();
    isMathMode.value = false;
  }
}

/// A single answer option for a question.
class AnswerModel with DualInputField {
  AnswerModel({this.isCorrect = false, this.serverId})
    : nativeController = TextEditingController(),
      mathController = MathFieldEditingController(),
      isMathMode = ValueNotifier<bool>(false);

  /// Rehydrates an option loaded from the backend (draft edit flow), keeping its
  /// server id + a snapshot of the persisted values for change detection.
  factory AnswerModel.existing({
    required String? serverId,
    required String text,
    required bool isCorrect,
    int? position,
    String? photoPath,
    String? photoUrl,
  }) {
    final model = AnswerModel(isCorrect: isCorrect, serverId: serverId)
      ..imagePath = photoPath
      ..imageUrl = photoUrl
      ..originalText = text
      ..originalPhoto = photoPath
      ..originalCorrect = isCorrect
      ..originalPosition = position;
    model.nativeController.text = text;
    return model;
  }

  @override
  final TextEditingController nativeController;
  @override
  final MathFieldEditingController mathController;
  @override
  final ValueNotifier<bool> isMathMode;

  /// Backend option id. `null` for options added in this session.
  final String? serverId;

  bool isCorrect;

  // ── Server snapshot (edit flow) — null/defaults for freshly added options.
  String? originalText;
  String? originalPhoto;
  bool originalCorrect = false;
  int? originalPosition;

  /// Never persisted yet.
  bool get isNew => serverId == null;

  /// True when text, image or correctness differs from the loaded value.
  bool get isDirty =>
      text != (originalText ?? '') || (imagePath ?? '') != (originalPhoto ?? '') || isCorrect != originalCorrect;

  void dispose() => _disposeDual();
}

/// A single question with its answer options.
class QuestionModel with DualInputField {
  QuestionModel({List<AnswerModel>? answers, this.isExpanded = true, this.serverId})
    : nativeController = TextEditingController(),
      mathController = MathFieldEditingController(),
      isMathMode = ValueNotifier<bool>(false),
      answers = answers ?? [AnswerModel(), AnswerModel()];

  /// Rehydrates a question loaded from the backend (draft edit flow).
  factory QuestionModel.existing({
    required String? serverId,
    required String text,
    required List<AnswerModel> answers,
    int? position,
    String? photoPath,
    String? photoUrl,
    bool isExpanded = false,
  }) {
    final model = QuestionModel(answers: answers, isExpanded: isExpanded, serverId: serverId)
      ..imagePath = photoPath
      ..imageUrl = photoUrl
      ..originalText = text
      ..originalPhoto = photoPath
      ..originalPosition = position;
    model.nativeController.text = text;
    return model;
  }

  @override
  final TextEditingController nativeController;
  @override
  final MathFieldEditingController mathController;
  @override
  final ValueNotifier<bool> isMathMode;

  /// Backend question id. `null` for questions added in this session.
  final String? serverId;

  List<AnswerModel> answers;
  bool isExpanded;

  // ── Server snapshot (edit flow) — null for freshly added questions.
  String? originalText;
  String? originalPhoto;
  int? originalPosition;

  bool get isNew => serverId == null;

  /// True when the question text or image differs from the loaded value.
  bool get isDirty => text != (originalText ?? '') || (imagePath ?? '') != (originalPhoto ?? '');

  bool get hasCorrectAnswer => answers.any((a) => a.isCorrect);
  bool get allAnswersHaveContent => answers.every((a) => a.hasContent);

  /// Full validity: question filled + ≥2 filled answers + ≥1 correct.
  bool get isValid => hasContent && answers.length >= 2 && allAnswersHaveContent && hasCorrectAnswer;

  void dispose() {
    _disposeDual();
    for (final a in answers) {
      a.dispose();
    }
  }
}
