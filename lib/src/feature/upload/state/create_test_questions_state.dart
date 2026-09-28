import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/config.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../../my_tests/models/demo_test_model.dart';
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

  /// True while an existing draft's questions are being fetched (edit flow).
  bool isLoading = false;

  /// True when the initial draft load failed, so the retry affordance shows.
  bool loadFailed = false;

  late final CreateTestCubit createTestCubit;
  late final UploadPricingCubit pricingCubit;
  late final IUploadRepository uploadRepository;
  StreamSubscription<UploadPricingState>? _pricingSub;

  /// Snapshot of the server ids present when the draft was loaded, used to
  /// detect deletions on save. Empty in create mode.
  final Set<String> _originalQuestionIds = {};
  final Map<String, List<String>> _originalOptionIds = {};

  /// Editing an existing draft vs. creating a new test.
  bool get isEditMode => widget.testId != null && widget.testId!.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();

    uploadRepository = context.x.dependencies.repository.uploadRepository;
    createTestCubit = CreateTestCubit(uploadRepository: uploadRepository);
    pricingCubit = UploadPricingCubit(uploadRepository: uploadRepository)..fetchPricing();
    _pricingSub = pricingCubit.stream.listen((_) {
      if (mounted) setState(() {});
    });

    if (isEditMode) {
      // Editing: start empty and pull the draft's saved questions.
      questions = [];
      expandedIndex = null;
      isLoading = true;
      _loadDraft();
    } else {
      // Imported questions (file mode) or a single blank one (manual mode).
      final imported = ImportHandoff.take();
      questions = imported ?? [QuestionModel()];
      expandedIndex = imported == null ? 0 : null;
      if (expandedIndex != null) questions.first.isExpanded = true;
    }
  }

  // ── Draft loading (edit flow) ─────────────────────────────────────────

  /// Resolves a stored `photo_url` (bare filename or absolute URL) to a URL the
  /// image widgets can render. Mirrors `QuestionImageWidget`'s resolution.
  String? _resolveImageUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http')) return value;
    final base = Config.apiBaseUrl.endsWith('/')
        ? Config.apiBaseUrl.substring(0, Config.apiBaseUrl.length - 1)
        : Config.apiBaseUrl;
    if (base.isEmpty) return value;
    if (value.startsWith('/')) return '$base$value';
    if (value.startsWith('uploads/')) return '$base/$value';
    return '$base/uploads/$value';
  }

  Future<void> _loadDraft() async {
    setState(() {
      isLoading = true;
      loadFailed = false;
    });
    try {
      final loaded = await uploadRepository.getTestQuestionsForEdit(widget.testId!);
      final sorted = [...loaded]..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

      final models = <QuestionModel>[];
      _originalQuestionIds.clear();
      _originalOptionIds.clear();

      for (final dq in sorted) {
        final options = [...(dq.options ?? <DemoOption>[])]
          ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

        final answers = options
            .map(
              (o) => AnswerModel.existing(
                serverId: o.id,
                text: o.text ?? '',
                isCorrect: o.isCorrect ?? false,
                position: o.position,
                photoPath: o.image,
                photoUrl: _resolveImageUrl(o.image),
              ),
            )
            .toList();
        // A question must always offer at least two option rows in the editor.
        while (answers.length < 2) {
          answers.add(AnswerModel());
        }

        models.add(
          QuestionModel.existing(
            serverId: dq.id,
            text: dq.text ?? '',
            answers: answers,
            position: dq.position,
            photoPath: dq.image,
            photoUrl: _resolveImageUrl(dq.image),
          ),
        );

        if (dq.id != null) {
          _originalQuestionIds.add(dq.id!);
          _originalOptionIds[dq.id!] = options.where((o) => o.id != null).map((o) => o.id!).toList();
        }
      }

      if (!mounted) return;
      setState(() {
        for (final q in questions) {
          q.dispose();
        }
        questions
          ..clear()
          ..addAll(models.isEmpty ? [QuestionModel()] : models);
        expandedIndex = 0;
        questions.first.isExpanded = true;
        isLoading = false;
      });
    } on Object catch (e) {
      debugPrint('LOAD DRAFT FOR EDIT ERROR: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadFailed = true;
      });
      context.x.showNotification(message: ErrorUtil.localizeError(context, 'somethingWentWrong'), isError: true);
    }
  }

  void retryLoad() => _loadDraft();

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
    context.telegramWebApp.hapticImpact(.soft);
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
    context.telegramWebApp.hapticImpact(.light);
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
    context.telegramWebApp.hapticImpact(.medium);
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
    context.telegramWebApp.hapticImpact(.light);
    setState(() => questions[questionIndex].answers.add(AnswerModel()));
  }

  void removeAnswer(int questionIndex, int answerIndex) {
    final q = questions[questionIndex];
    if (q.answers.length <= 2) return;
    context.telegramWebApp.hapticImpact(.light);
    setState(() {
      q.answers[answerIndex].dispose();
      q.answers.removeAt(answerIndex);
    });
  }

  void toggleCorrect(int questionIndex, int answerIndex) {
    context.telegramWebApp.hapticImpact(.soft);
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
    context.telegramWebApp.hapticImpact(.light);

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
    context.telegramWebApp.hapticImpact(.light);
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
    context.telegramWebApp.hapticImpact(.medium);

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
        locale: Localizations.localeOf(context).languageCode,
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
        context.x.showNotification(
          message: ErrorUtil.localizeError(context, createTestCubit.state.errorMessage),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCreating = false);
      }
    }
  }

  // ── Save Edits (edit flow) ─────────────────────────────────────────────

  /// Persists edits to an existing draft via the question/option CRUD endpoints
  /// (docs/customer-test-upload.md §5). Only changed items are sent. On success
  /// pops back to the caller. Any failure aborts and surfaces the error.
  Future<void> onSaveEdits() async {
    if (!canSubmit || isCreating) return;
    final testId = widget.testId!;
    context.telegramWebApp.hapticImpact(.medium);
    setState(() => isCreating = true);

    final locale = Localizations.localeOf(context).languageCode;

    try {
      // 1. Questions removed in this session.
      final currentQuestionIds = questions.where((q) => !q.isNew).map((q) => q.serverId!).toSet();
      for (final id in _originalQuestionIds) {
        if (!currentQuestionIds.contains(id)) {
          await uploadRepository.deleteQuestion(testId, id);
        }
      }

      // 2. Create new questions / update changed ones (in display order).
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        final position = i + 1;

        if (q.isNew) {
          await uploadRepository.createQuestion(testId, _questionCreateBody(q, position, locale));
          continue;
        }

        // Existing question — sync its fields only when something changed.
        if (q.isDirty || q.originalPosition != position) {
          await uploadRepository.updateQuestion(testId, q.serverId!, _questionUpdateBody(q, position, locale));
        }

        // Options removed from this question.
        final originalOptionIds = _originalOptionIds[q.serverId!] ?? const <String>[];
        final currentOptionIds = q.answers.where((a) => !a.isNew).map((a) => a.serverId!).toSet();
        for (final oid in originalOptionIds) {
          if (!currentOptionIds.contains(oid)) {
            await uploadRepository.deleteOption(testId, q.serverId!, oid);
          }
        }

        // Create/update options.
        for (var j = 0; j < q.answers.length; j++) {
          final a = q.answers[j];
          final optionPosition = j + 1;
          if (a.isNew) {
            await uploadRepository.createOption(testId, q.serverId!, _optionBody(a, optionPosition, locale));
          } else if (a.isDirty || a.originalPosition != optionPosition) {
            await uploadRepository.updateOption(
              testId,
              q.serverId!,
              a.serverId!,
              _optionBody(a, optionPosition, locale),
            );
          }
        }
      }

      if (mounted) context.octopus.pop();
    } on Object catch (e) {
      debugPrint('SAVE EDITS ERROR: $e');
      if (mounted) {
        context.x.showNotification(
          message: ErrorUtil.localizeError(context, ErrorUtil.toUserFriendlyMessage(e)),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  /// `POST /tests/:id/questions` body — includes its options inline.
  Map<String, Object?> _questionCreateBody(QuestionModel q, int position, String locale) => {
    'text': i18nText(q.text, locale),
    'position': position,
    'score': 1,
    'answer_format': q.answerFormat,
    'photo_url': q.imagePath ?? '',
    'options': [for (var j = 0; j < q.answers.length; j++) _optionBody(q.answers[j], j + 1, locale)],
  };

  /// `PUT /tests/:id/questions/:qid` body — question fields only (no options).
  Map<String, Object?> _questionUpdateBody(QuestionModel q, int position, String locale) => {
    'text': i18nText(q.text, locale),
    'position': position,
    'score': 1,
    'answer_format': q.answerFormat,
    'photo_url': q.imagePath ?? '',
  };

  /// Shared option body for both create and update.
  Map<String, Object?> _optionBody(AnswerModel a, int position, String locale) => {
    'text': i18nText(a.text, locale),
    'position': position,
    'is_correct': a.isCorrect,
    'answer_format': a.answerFormat,
    'photo_url': a.imagePath ?? '',
  };
}
