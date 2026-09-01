import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

import '../../../common/router/pages.dart';
import '../model/test_question_model.dart';
import '../screen/create_test_questions_screen.dart';

abstract class CreateTestQuestionsState extends State<CreateTestQuestionsScreen> {
  static const int minQuestionCount = 10;

  late final List<QuestionModel> questions;
  int? expandedIndex;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    questions = [QuestionModel()];
    expandedIndex = 0;
  }

  @override
  void dispose() {
    for (final q in questions) {
      q.dispose();
    }
    super.dispose();
  }

  // ── Guards ────────────────────────────────────────────────────────────

  /// All questions valid AND total count ≥ 10.
  bool get canSubmit =>
      questions.length >= minQuestionCount && questions.every((q) => q.isValid);

  /// Can only add a new question when the last one is fully complete.
  bool get canAddQuestion {
    if (questions.isEmpty) return true;
    return questions.last.isValid;
  }

  // ── Accordion ─────────────────────────────────────────────────────────

  void onToggleExpand(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null;
        questions[index].isExpanded = false;
      } else {
        if (expandedIndex != null) {
          questions[expandedIndex!].isExpanded = false;
        }
        expandedIndex = index;
        questions[index].isExpanded = true;
      }
    });
  }

  // ── Question actions ──────────────────────────────────────────────────

  void addQuestion() {
    if (!canAddQuestion) return;
    setState(() {
      if (expandedIndex != null) {
        questions[expandedIndex!].isExpanded = false;
      }
      final newQ = QuestionModel();
      questions.add(newQ);
      expandedIndex = questions.length - 1;
      newQ.isExpanded = true;
    });
  }

  void removeQuestion(int index) {
    if (questions.length <= 1) return;
    setState(() {
      questions[index].dispose();
      questions.removeAt(index);
      if (expandedIndex != null) {
        if (expandedIndex == index) {
          expandedIndex = index > 0 ? index - 1 : 0;
          questions[expandedIndex!].isExpanded = true;
        } else if (expandedIndex! > index) {
          expandedIndex = expandedIndex! - 1;
        }
      }
    });
  }

  // ── Answer actions ────────────────────────────────────────────────────

  void addAnswer(int questionIndex) {
    setState(() => questions[questionIndex].answers.add(AnswerModel()));
  }

  void removeAnswer(int questionIndex, int answerIndex) {
    final q = questions[questionIndex];
    if (q.answers.length <= 2) return;
    setState(() {
      q.answers[answerIndex].dispose();
      q.answers.removeAt(answerIndex);
    });
  }

  void toggleCorrect(int questionIndex, int answerIndex) {
    setState(() {
      final q = questions[questionIndex];
      for (var i = 0; i < q.answers.length; i++) {
        q.answers[i].isCorrect = (i == answerIndex);
      }
    });
  }

  // ── Rebuild trigger ───────────────────────────────────────────────────

  void onTextChanged(String _) => setState(() {});

  // ── Submit ────────────────────────────────────────────────────────────

  void onUploadTest() {
    if (!canSubmit) return;

    context.octopus.push(
      Routes.uploadConfirm,
      arguments: {
        'testName': widget.testName,
        'university': widget.university,
        if (widget.description?.isNotEmpty == true) 'description': widget.description!,
        'questionCount': questions.length.toString(),
      },
    );
  }
}
