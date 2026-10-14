import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/flashcard_cubit.dart';
import '../model/flashcard_response_model.dart';
import '../screens/flashcard_screen.dart';
import '../widgets/flashcard_deck_view.dart';

abstract class FlashcardScreenState extends State<FlashcardScreen> {
  late final FlashcardCubit cubit;
  final GlobalKey<FlashcardDeckViewState> deckKey = GlobalKey<FlashcardDeckViewState>();

  /// Signed swipe progress (-1 = fully toward "Bilmayman", +1 = "Bilaman").
  /// Drives the footer button fill during a swipe-commit.
  final ValueNotifier<double> swipeProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    cubit = context.read<FlashcardCubit>();
    context.setupTelegramBackButton(onBackPressed);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    swipeProgress.dispose();
    super.dispose();
  }

  void onBackPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.pop();
  }

  void onRetryLoad() {
    context.telegramWebApp.hapticImpact(.light);
    cubit.loadCards(cubit.state.testId, cubit.state.config);
  }

  void onFlip() {
    context.telegramWebApp.hapticImpact(.light);
    cubit.flipCurrent();
  }

  void onUndo() {
    context.telegramWebApp.hapticImpact(.light);
    cubit.undo();
  }

  /// Footer buttons → trigger the same fly-off animation as a swipe.
  void onPressKnownButton() => deckKey.currentState?.flyOff(known: true);

  void onPressUnknownButton() => deckKey.currentState?.flyOff(known: false);

  /// Deck fly-off completion callbacks → advance the session.
  void onMarkKnown() {
    HapticFeedback.selectionClick();
    cubit.markKnown();
  }

  void onMarkUnknown() {
    HapticFeedback.selectionClick();
    cubit.markUnknown();
  }

  /// Test sub-mode: an option tile was tapped. Correct → mark known & advance;
  /// wrong → reveal the correct answer, then advance after a short beat.
  void onSelectOption(FlashcardCardModel card, FlashcardOptionModel option) {
    HapticFeedback.selectionClick();
    cubit.selectOption(option.id);
    if (card.correctOptionId != option.id) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) cubit.advanceAfterOptionCheck();
      });
    }
  }

  void onSessionFinished(BuildContext context, FlashcardState state) {
    final startedAt = state.startedAt;
    final durationSec = startedAt != null ? DateTime.now().difference(startedAt).inSeconds : 0;
    final total = state.cards.length;

    // Submit result to backend via POST /api/flashcards/{testId}/result (fire and forget)
    cubit.submitResult();

    context.octopus.pushReplacement(
      Routes.flashcardResult,
      arguments: <String, String>{
        'testId': state.testId,
        'knownCount': state.knownIds.length.toString(),
        'unknownCount': state.unknownIds.length.toString(),
        'total': total.toString(),
        'durationSec': durationSec.toString(),
        'mode': state.config.mode.name,
      },
    );
  }
}
