import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/test_init_enum.dart';
import '../bloc/test_view.dart';
import '../screens/test_solving_screen.dart';

abstract class TestSolvingScreenState extends State<TestSolvingScreen> {
  late final TestView cubit;

  List<DemoQuestion> questions = [];
  ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);

  Timer? _timer;
  ValueNotifier<int> remainingSeconds = ValueNotifier(0);
  int questionTimeSeconds = 0;

  ValueNotifier<DemoOption?> selectedOption = ValueNotifier(null);
  ValueNotifier<bool> isAnswerChecked = ValueNotifier(false);

  int correctAnswers = 0;
  int wrongAnswers = 0;

  final SoundService _sound = .instance;

  static const _correctSound = 'lib/audio/correct.mp3';

  @override
  void initState() {
    super.initState();
    cubit = context.read<TestView>();

    // Preload sounds so they play instantly.
    _sound.preload(_correctSound);

    questionTimeSeconds = _parseTimeOption(widget.timeOptionName);
    initializeQuestions();
    context.setupTelegramBackButton(onBackPressed);
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

  void initializeQuestions() {
    final detail = cubit.state.detail;
    if (detail == null || detail.questions == null) return;
    if (questions.isNotEmpty) return;

    var start = widget.startRange;
    var end = widget.endRange;
    var allQuestions = List<DemoQuestion>.from(detail.questions!);

    if (allQuestions.length >= end) {
      questions = allQuestions.sublist(start > 0 ? start - 1 : 0, end);
    } else {
      questions = allQuestions;
    }

    if (widget.shuffleOptionName == ShuffleOption.all.name ||
        widget.shuffleOptionName == ShuffleOption.questionsOnly.name) {
      questions.shuffle();
    }

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
      _startQuestion();
    }
  }

  void _startQuestion() {
    selectedOption.value = null;
    isAnswerChecked.value = false;

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
    _timer?.cancel();

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

  void _nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _startQuestion();
    } else {
      onFinish();
    }
  }

  void onNextPressed() {
    if (isAnswerChecked.value) {
      _nextQuestion();
    }
  }

  void onFinish() {
    _timer?.cancel();
    // Usually we would submit attempts, but currently we just go to result
    context.octopus.navigate(Routes.testResult.name);
  }

  void onBackPressed() {
    // Disable exiting the screen via back button
    context.telegramWebApp.hapticNotification(TelegramHapticNotification.warning);
  }

  void onClose() {
    _timer?.cancel();
    context.octopus.pop();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    _timer?.cancel();
    selectedOption.dispose();
    isAnswerChecked.dispose();
    currentQuestionIndex.dispose();
    remainingSeconds.dispose();
    super.dispose();
  }
}
