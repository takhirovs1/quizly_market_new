import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/app_enum.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/test_init_enum.dart' hide TestMode;
import '../bloc/test_view.dart';
import '../model/test_request_response_models.dart';
import '../screens/test_solving_screen.dart';

abstract class TestSolvingScreenState extends State<TestSolvingScreen> {
  late final TestView cubit;

  List<DemoQuestion> questions = [];
  final Map<String, String> selectedAnswers = {};
  ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);

  int get totalToSolve {
    final apiStart = widget.startRange == 0 ? 1 : widget.startRange;
    final apiEnd = widget.endRange == 0 ? 1 : widget.endRange;
    final rangeCount = apiEnd - apiStart + 1;
    final actualTotal = cubit.state.detail?.questionCount;
    if (actualTotal != null) {
      final maxAvailable = actualTotal - apiStart + 1;
      return rangeCount.clamp(0, maxAvailable);
    }
    return rangeCount;
  }

  final ValueNotifier<bool> isFetching = ValueNotifier(false);

  Timer? _timer;
  ValueNotifier<int> remainingSeconds = ValueNotifier(0);
  int questionTimeSeconds = 0;

  Timer? _postAnswerTimer;
  final ValueNotifier<int> postAnswerRemainingSeconds = ValueNotifier(0);

  ValueNotifier<DemoOption?> selectedOption = ValueNotifier(null);
  ValueNotifier<bool> isAnswerChecked = ValueNotifier(false);

  int correctAnswers = 0;
  int wrongAnswers = 0;

  final SoundService _sound = .instance;

  static const _correctSound = 'lib/audio/correct.mp3';

  late final DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    cubit = context.read<TestView>();

    // Preload sounds so they play instantly.
    _sound.preload(_correctSound);

    if (widget.arguments.mode == TestMode.university) {
      final minutes = int.tryParse(widget.arguments.timeOptionName) ?? 30;
      remainingSeconds.value = minutes * 60;
      questionTimeSeconds = 0;
      _startGlobalTimer();
    } else {
      questionTimeSeconds = _parseTimeOption(widget.timeOptionName);
    }
    currentQuestionIndex.addListener(_onQuestionIndexChanged);
    initializeQuestions();
    context.setupTelegramBackButton(onBackPressed);
  }

  int _lastFetchedIndex = 0;

  void _onQuestionIndexChanged() {
    final index = currentQuestionIndex.value;
    final apiStart = widget.startRange == 0 ? 1 : widget.startRange;
    final apiEnd = widget.endRange == 0 ? 1 : widget.endRange;
    final totalToSolve = apiEnd - apiStart + 1;

    if (questions.length < totalToSolve) {
      final triggerIndex = questions.length - 4; // 17th question of current 20-chunk (20 - 4 = 16)
      if (index >= triggerIndex && _lastFetchedIndex < questions.length) {
        _lastFetchedIndex = questions.length;
        _fetchNextChunk();
      }
    }
  }

  Future<void> _fetchNextChunk() async {
    final apiStart = widget.startRange == 0 ? 1 : widget.startRange;
    final apiEnd = widget.endRange == 0 ? 1 : widget.endRange;

    // Calculate the next range chunk based on how many questions are already loaded locally
    final nextStart = apiStart + questions.length;
    final nextEnd = (nextStart + 19).clamp(nextStart, apiEnd);
    final rangeStr = '$nextStart-$nextEnd';

    await cubit.loadNextQuestionsChunk(
      widget.testId,
      TestDetailRequest(range: rangeStr, shuffle: widget.shuffleOptionName),
    );
  }

  Future<void> fetchQuestionsUpTo(int targetIndex) async {
    if (targetIndex < questions.length) return;

    final apiStart = widget.startRange == 0 ? 1 : widget.startRange;
    final apiEnd = widget.endRange == 0 ? 1 : widget.endRange;

    final nextStart = apiStart + questions.length;
    var nextEnd = nextStart + 19;
    final requiredEnd = apiStart + targetIndex;
    if (nextEnd < requiredEnd) {
      nextEnd = requiredEnd;
    }
    nextEnd = nextEnd.clamp(nextStart, apiEnd);

    final rangeStr = '$nextStart-$nextEnd';

    isFetching.value = true;
    try {
      await cubit.loadNextQuestionsChunk(
        widget.testId,
        TestDetailRequest(range: rangeStr, shuffle: widget.shuffleOptionName),
      );
    } finally {
      isFetching.value = false;
    }
  }

  void initializeQuestions() {
    final detail = cubit.state.detail;
    if (detail == null || detail.questions == null) return;
    if (questions.isNotEmpty) return;

    var allQuestions = List<DemoQuestion>.from(detail.questions!);
    questions = allQuestions;

    questions = questions.map((q) {
      if (q.options != null &&
          (widget.shuffleOptionName == ShuffleOption.all.name ||
              widget.shuffleOptionName == ShuffleOption.answersOnly.name)) {
        final newOptions = List<DemoOption>.from(q.options!)..shuffle();
        return DemoQuestion(
          id: q.id,
          testId: q.testId,
          text: q.text,
          position: q.position,
          score: q.score,
          options: newOptions,
          createdAt: q.createdAt,
          image: q.image,
        );
      }
      return q;
    }).toList();

    if (questions.isNotEmpty) {
      startQuestion();
    }
  }

  int _parseTimeOption(String timeName) {
    switch (timeName) {
      case 'seconds15':
        return 15;
      case 'seconds30':
        return 30;
      case 'seconds45':
        return 45;
      case 'minute1':
        return 60;
      case 'minutes2':
        return 120;
      case 'minutes3':
        return 180;
      default:
        return 0;
    }
  }

  void startQuestion() {
    selectedOption.value = null;
    isAnswerChecked.value = false;
    _postAnswerTimer?.cancel();
    postAnswerRemainingSeconds.value = 0;

    final currentQuestion = questions[currentQuestionIndex.value];
    final selectedOptionId = selectedAnswers[currentQuestion.id];
    if (selectedOptionId != null) {
      final previouslySelected = currentQuestion.options?.firstWhereOrNull((o) => o.id == selectedOptionId);
      selectedOption.value = previouslySelected;
      isAnswerChecked.value = true;
    } else {
      if (widget.arguments.mode == TestMode.university) {
        // Global timer is running in university mode, no per-question timer.
      } else {
        if (questionTimeSeconds > 0) {
          remainingSeconds.value = questionTimeSeconds;
          _timer?.cancel();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (remainingSeconds.value > 0) {
              remainingSeconds.value--;
            } else {
              _timer?.cancel();
              _onTimeUp();
            }
          });
        }
      }
    }
  }

  void _onTimeUp() {
    if (!mounted) return;
    context.telegramWebApp.hapticNotification(TelegramHapticNotification.error);
    isAnswerChecked.value = true;
    wrongAnswers++;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextQuestion();
    });
  }

  void onOptionSelected(DemoOption option) {
    if (isAnswerChecked.value) return;

    selectedOption.value = option;
    isAnswerChecked.value = true;

    if (widget.arguments.mode != .university) {
      _timer?.cancel();
    }

    final currentQuestion = questions[currentQuestionIndex.value];
    if (currentQuestion.id != null && option.id != null) {
      selectedAnswers[currentQuestion.id!] = option.id!;
    }

    if (option.isCorrect ?? false) {
      correctAnswers++;
      context.telegramWebApp.hapticNotification(.success);
      _sound.play(_correctSound);
    } else {
      wrongAnswers++;
      context.telegramWebApp.hapticNotification(.error);
    }

    _startPostAnswerTimer();
  }

  void _startPostAnswerTimer() {
    if (widget.arguments.mode == TestMode.university) {
      postAnswerRemainingSeconds.value = 5;
      _postAnswerTimer?.cancel();
      _postAnswerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (postAnswerRemainingSeconds.value > 0) {
          postAnswerRemainingSeconds.value--;
        } else {
          _postAnswerTimer?.cancel();
          _nextQuestion();
        }
      });
    } else {
      remainingSeconds.value = 5;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          _timer?.cancel();
          _nextQuestion();
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      startQuestion();
    } else {
      if (widget.arguments.mode == TestMode.university) {
        final firstUnansweredIndex = questions.indexWhere((q) => !selectedAnswers.containsKey(q.id));
        if (firstUnansweredIndex != -1) {
          currentQuestionIndex.value = firstUnansweredIndex;
          startQuestion();
        } else {
          onFinish();
        }
      } else {
        onFinish();
      }
    }
  }

  void onNextPressed() {
    context.telegramWebApp.hapticImpact(.light);
    _postAnswerTimer?.cancel();
    _nextQuestion();
  }

  void onPreviousPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (currentQuestionIndex.value > 0) {
      _postAnswerTimer?.cancel();
      currentQuestionIndex.value--;
      startQuestion();
    }
  }

  void _startGlobalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        onFinish();
      }
    });
  }

  Future<void> onFinish() async {
    _timer?.cancel();
    final timeSpentSec = DateTime.now().difference(startTime).inSeconds;
    final skipCount = (questions.length - selectedAnswers.length).clamp(0, questions.length);

    final answersList = selectedAnswers.entries.map((e) => {'question_id': e.key, 'option_id': e.value}).toList();

    if (widget.attemptId.isNotEmpty) {
      await cubit.finishAttempt(
        widget.testId,
        widget.attemptId,
        FinishAttemptRequest(answers: answersList, timeSpentSec: timeSpentSec, skipCount: skipCount),
      );
    }

    if (mounted) {
      final detail = cubit.state.detail;
      context.octopus.pushReplacement(
        Routes.testResult,
        arguments: {
          'id': widget.testId,
          'correct': correctAnswers.toString(),
          'wrong': wrongAnswers.toString(),
          'total': totalToSolve.toString(),
          'time': timeSpentSec.toString(),
          if (detail?.name != null) 'name': detail!.name!,
          if (detail?.description != null) 'description': detail!.description!,
          if (detail?.academicYear != null) 'academic_year': detail!.academicYear!,
          if (detail?.semester != null) 'semester': detail!.semester!.toString(),
          if (detail?.questionCount != null) 'question_count': detail!.questionCount!.toString(),
          if (widget.lastAttemptCorrect != null) 'last_attempt_correct': widget.lastAttemptCorrect!.toString(),
          if (widget.lastAttemptTotal != null) 'last_attempt_total': widget.lastAttemptTotal!.toString(),
          if (widget.lastAttemptTime != null) 'last_attempt_time': widget.lastAttemptTime!.toString(),
          if (widget.lastAttemptDate != null) 'last_attempt_date': widget.lastAttemptDate!,
        },
      );
    }
  }

  void onBackPressed() {
    // Disable exiting the screen via back button
    context.telegramWebApp.hapticNotification(.warning);
  }

  void onClose() {
    _timer?.cancel();
    context.octopus.pop();
  }

  @override
  void dispose() {
    currentQuestionIndex.removeListener(_onQuestionIndexChanged);
    context.teardownTelegramBackButton(onBackPressed);
    _timer?.cancel();
    _postAnswerTimer?.cancel();
    selectedOption.dispose();
    isAnswerChecked.dispose();
    currentQuestionIndex.dispose();
    remainingSeconds.dispose();
    postAnswerRemainingSeconds.dispose();
    isFetching.dispose();
    super.dispose();
  }
}
