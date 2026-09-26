import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/create_test_cubit.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../data/upload_repository.dart';
import '../model/import_mapping_models.dart';
import '../model/manual_test_create_model.dart';
import '../model/test_question_model.dart';
import '../screen/create_test_questions_screen.dart';

/// Review/edit surface shared by BOTH modes: the manual builder starts empty,
/// the file-import wizard hands its mapped questions over via [ImportHandoff].
abstract class CreateTestQuestionsState extends State<CreateTestQuestionsScreen> {
  late final List<QuestionModel> questions;
  int? expandedIndex;
  bool isCreating = false;

  late final CreateTestCubit createTestCubit;
  late final UploadPricingCubit pricingCubit;
  late final IUploadRepository uploadRepository;
  StreamSubscription<UploadPricingState>? _pricingSub;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();

    // Imported questions (file mode) or a single blank one (manual mode).
    final imported = ImportHandoff.take();
    questions = imported ?? [QuestionModel()];
    expandedIndex = imported == null ? 0 : null;
    if (expandedIndex != null) questions.first.isExpanded = true;

    uploadRepository = context.x.dependencies.repository.uploadRepository;
    createTestCubit = CreateTestCubit(uploadRepository: uploadRepository);
    pricingCubit = UploadPricingCubit(uploadRepository: uploadRepository)..fetchPricing();
    _pricingSub = pricingCubit.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    _pricingSub?.cancel();
    for (final q in questions) {
      q.dispose();
    }
    createTestCubit.close();
    pricingCubit.close();
    super.dispose();
  }

  // ── Guards ────────────────────────────────────────────────────────────

  /// Recommended minimum from pricing settings — advisory, never a hard block
  /// (backend contract: `min_questions` "advisory only").
  int get minQuestions => pricingCubit.state.pricing.minQuestions;

  /// Hard rule: ≥1 question and every question valid (text/image + ≥2 options
  /// + ≥1 correct). The pricing minimum only produces a warning.
  bool get canSubmit => questions.isNotEmpty && questions.every((q) => q.isValid);

  bool get reachedRecommendedMin => questions.length >= minQuestions;

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

  // ── Images (spec §6: question and each option can carry one image) ────

  final ImagePicker _imagePicker = ImagePicker();

  /// Picks an image for a question ([answerIndex] == null) or one of its
  /// options, uploads it via `POST /api/files`, and stores path + URL on the
  /// field. Never fakes success — a failed upload leaves the field unchanged.
  Future<void> pickImage(int questionIndex, {int? answerIndex}) async {
    final q = questions[questionIndex];
    final DualInputField target = answerIndex == null ? q : q.answers[answerIndex];
    if (target.imageUploading) return;

    final XFile? file;
    try {
      file = await _imagePicker.pickImage(source: .gallery, maxWidth: 1600, imageQuality: 85);
    } on Object catch (e) {
      debugPrint('pickImage error: $e');
      return;
    }
    if (file == null || !mounted) return;

    setState(() => target.imageUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final uploaded = await uploadRepository.uploadImage(bytes: bytes, fileName: file.name);
      if (!mounted) return;
      setState(() {
        target
          ..imagePath = uploaded.path
          ..imageUrl = uploaded.url;
      });
    } on Object catch (e) {
      debugPrint('uploadImage error: $e');
      if (mounted) context.x.showNotification(message: context.x.l10n.imageUploadFailed, isError: true);
    } finally {
      if (mounted) setState(() => target.imageUploading = false);
    }
  }

  void removeImage(int questionIndex, {int? answerIndex}) {
    final q = questions[questionIndex];
    final DualInputField target = answerIndex == null ? q : q.answers[answerIndex];
    setState(() {
      target
        ..imagePath = null
        ..imageUrl = null;
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
          optionDtos.add(
            ManualOptionDto(
              text: a.text,
              position: j + 1,
              isCorrect: a.isCorrect,
              answerFormat: a.answerFormat,
              photo: a.imagePath,
            ),
          );
        }
        questionDtos.add(
          ManualQuestionDto(
            text: q.text,
            position: i + 1,
            options: optionDtos,
            answerFormat: q.answerFormat,
            photo: q.imagePath,
          ),
        );
      }

      final price = widget.price;
      final request = ManualTestCreateRequest(
        name: widget.testName,
        description: widget.description,
        price: price,
        isFree: price == null || price == 0,
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
