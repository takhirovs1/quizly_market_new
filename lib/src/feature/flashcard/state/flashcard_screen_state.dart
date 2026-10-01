import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/flashcard_cubit.dart';
import '../model/flashcard_response_model.dart';
import '../screens/flashcard_screen.dart';
import '../widgets/flashcard_card_widget.dart';

abstract class FlashcardScreenState extends State<FlashcardScreen> {
  late final FlashcardCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<FlashcardCubit>();
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

  void onRetryLoad() => cubit.loadCards(cubit.state.testId, cubit.state.config);

  void onMarkKnown() {
    HapticFeedback.selectionClick();
    cubit.markKnown();
  }

  void onMarkUnknown() {
    HapticFeedback.selectionClick();
    cubit.markUnknown();
  }

  void onHorizontalDrag(DragEndDetails details) {
    const threshold = 100.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -threshold) {
      onMarkUnknown();
    } else if (velocity > threshold) {
      onMarkKnown();
    }
  }

  void onSessionFinished(BuildContext context, FlashcardState state) {
    final startedAt = state.startedAt;
    final durationSec = startedAt != null
        ? DateTime.now().difference(startedAt).inSeconds
        : 0;
    context.octopus.push(
      Routes.flashcardResult,
      arguments: {
        'testId': state.testId,
        'knownCount': state.knownIds.length.toString(),
        'unknownCount': state.unknownIds.length.toString(),
        'total': state.cards.length.toString(),
        'durationSec': durationSec.toString(),
        'mode': state.config.mode.name,
      },
    );
  }

  Widget buildStudyCard(BuildContext context, FlashcardState state, FlashcardCardModel card) =>
      FlashcardCardWidget(
        card: card,
        isFlipped: state.isFlipped,
        onTap: () => cubit.flipCurrent(),
      );

  Widget buildTestCard(BuildContext context, FlashcardState state, FlashcardCardModel card) {
    final colors = context.x.colors;
    final options = card.options ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.cardBackground2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              card.front,
              textAlign: TextAlign.center,
              style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) => _buildOptionTile(context, state, card, opt)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    FlashcardState state,
    FlashcardCardModel card,
    FlashcardOptionModel opt,
  ) {
    final colors = context.x.colors;
    final isChecked = state.isOptionChecked;
    final isSelected = state.selectedOptionId == opt.id;
    final isCorrect = card.correctOptionId == opt.id;

    Color bgColor = colors.textFieldBackground;
    Color borderColor = colors.divider;

    if (isChecked) {
      if (isCorrect) {
        bgColor = colors.appleGreen.withValues(alpha: 0.12);
        borderColor = colors.appleGreen;
      } else if (isSelected) {
        bgColor = colors.error.withValues(alpha: 0.10);
        borderColor = colors.error;
      }
    }

    return GestureDetector(
      onTap: isChecked
          ? null
          : () {
              HapticFeedback.selectionClick();
              if (card.correctOptionId == opt.id) {
                cubit.selectOption(opt.id);
              } else {
                cubit.selectOption(opt.id);
                Future.delayed(const Duration(milliseconds: 900), () {
                  if (mounted) cubit.advanceAfterOptionCheck();
                });
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(opt.text, style: context.x.textStyle.sfW400s16.copyWith(fontSize: 15)),
            ),
            if (isChecked && isCorrect)
              Icon(Icons.check_circle_rounded, color: colors.appleGreen, size: 20)
            else if (isChecked && isSelected && !isCorrect)
              Icon(Icons.cancel_rounded, color: colors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
