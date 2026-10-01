import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../flashcard/model/flashcard_config.dart';
import '../../flashcard/widgets/flashcard_setup_sheet.dart';

class TestFlashcardMode extends StatefulWidget {
  const TestFlashcardMode({super.key, required this.testId});

  final String testId;

  @override
  State<TestFlashcardMode> createState() => _TestFlashcardModeState();
}

class _TestFlashcardModeState extends State<TestFlashcardMode> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showSetup();
    });
  }

  void _showSetup() {
    FlashcardSetupSheet.show(
      context,
      onStart: (config) => _startSession(config),
    ).then((_) {
      if (!mounted) return;
      context.octopus.pop();
    });
  }

  void _startSession(FlashcardConfig config) {
    context.octopus.push(
      Routes.flashcardSession,
      arguments: <String, String>{
        'testId': widget.testId,
        ...config.toArguments(),
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
  );
}
