import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../model/flashcard_config.dart';
import '../screens/flashcard_result_screen.dart';

abstract class FlashcardResultScreenState extends State<FlashcardResultScreen> {
  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton(onBackPressed);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    super.dispose();
  }

  void onBackPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.pop();
  }

  /// Share of cards marked "known" (0..1).
  double get accuracy => widget.total > 0 ? widget.knownCount / widget.total : 0.0;

  /// Session length formatted as `MM:SS`.
  String get durationFormatted {
    final minutes = widget.durationSec ~/ 60;
    final seconds = widget.durationSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void onFinish() {
    HapticFeedback.selectionClick();
    context.octopus.pop();
  }

  void onRetryUnknown() {
    HapticFeedback.selectionClick();
    final config = FlashcardConfig(
      rangeStart: 0,
      rangeEnd: widget.unknownCount,
      shuffle: true,
      direction: FlashcardDirection.questionFirst,
      mode: FlashcardMode.values.byName(widget.mode),
    );
    context.octopus
      ..pop()
      ..push(Routes.flashcardSession, arguments: config.toArguments()..['testId'] = widget.testId);
  }
}
