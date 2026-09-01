import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

/// Represents a single answer option for a question using MathField.
class AnswerModel {
  AnswerModel({this.isCorrect = false})
      : controller = MathFieldEditingController(),
        focusNode = FocusNode();

  final MathFieldEditingController controller;
  final FocusNode focusNode;
  bool isCorrect;

  String get text => controller.currentEditingValue(placeholderWhenEmpty: false).trim();
  bool get hasText => text.isNotEmpty;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

/// Represents a single question with its answer options using MathField.
class QuestionModel {
  QuestionModel()
      : controller = MathFieldEditingController(),
        focusNode = FocusNode(),
        answers = [AnswerModel(), AnswerModel()],
        isExpanded = true;

  final MathFieldEditingController controller;
  final FocusNode focusNode;
  List<AnswerModel> answers;
  bool isExpanded;

  String get text => controller.currentEditingValue(placeholderWhenEmpty: false).trim();
  bool get hasText => text.isNotEmpty;

  bool get hasCorrectAnswer => answers.any((a) => a.isCorrect);
  bool get allAnswersHaveText => answers.every((a) => a.hasText);

  /// Full validity: question text + ≥2 answers with text + 1 correct
  bool get isValid => hasText && answers.length >= 2 && allAnswersHaveText && hasCorrectAnswer;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
    for (final a in answers) {
      a.dispose();
    }
  }
}
