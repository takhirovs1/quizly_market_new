import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/create_test_cubit.dart';
import '../model/manual_test_create_model.dart';
import '../model/test_question_model.dart';
import '../screen/create_test_questions_screen.dart';

abstract class CreateTestQuestionsState extends State<CreateTestQuestionsScreen> {
  static const int minQuestionCount = 10;

  late final List<QuestionModel> questions;
  int? expandedIndex;
  bool isCreating = false;

  late final CreateTestCubit createTestCubit;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    questions = [QuestionModel()];
    expandedIndex = 0;
    createTestCubit = CreateTestCubit(uploadRepository: context.x.dependencies.repository.uploadRepository);
  }

  @override
  void dispose() {
    for (final q in questions) {
      q.dispose();
    }
    createTestCubit.close();
    super.dispose();
  }

  // ── Guards ────────────────────────────────────────────────────────────

  /// All questions valid AND total count ≥ 10.
  bool get canSubmit => questions.length >= minQuestionCount && questions.every((q) => q.isValid);

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

  // ── Submit Manual Test ────────────────────────────────────────────────

  Future<void> onUploadTest() async {
    if (!canSubmit || isCreating) return;

    setState(() => isCreating = true);

    try {
      final questionDtos = <ManualQuestionDto>[];
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final optionDtos = <ManualOptionDto>[];
        for (var j = 0; j < q.answers.length; j++) {
          final a = q.answers[j];
          optionDtos.add(ManualOptionDto(text: a.text, position: j + 1, isCorrect: a.isCorrect));
        }
        questionDtos.add(ManualQuestionDto(text: q.text, position: i + 1, options: optionDtos));
      }

      final request = ManualTestCreateRequest(
        name: widget.testName,
        description: widget.description,
        questions: questionDtos,
      );

      await createTestCubit.submitManualTest(request);
      final created = createTestCubit.state.createdTest;

      if (created != null && mounted) {
        context.octopus.push(
          Routes.uploadConfirm,
          arguments: {
            'testId': created.id,
            'testName': widget.testName,
            'university': widget.university,
            if (widget.description?.isNotEmpty == true) 'description': widget.description!,
            'questionCount': questions.length.toString(),
            if (created.price != null) 'price': created.price.toString(),
          },
        );
      } else if (createTestCubit.state.errorMessage != null && mounted) {
        context.x.showNotification(message: createTestCubit.state.errorMessage!, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => isCreating = false);
      }
    }
  }
}
