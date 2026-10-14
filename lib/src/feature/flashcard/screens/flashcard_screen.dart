import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/flashcard_cubit.dart';
import '../state/flashcard_screen_state.dart';
import '../widgets/flashcard_deck_view.dart';
import '../widgets/flashcard_edge_glow.dart';
import '../widgets/flashcard_footer.dart';
import '../widgets/flashcard_progress_bar.dart';
import '../widgets/flashcard_test_card.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends FlashcardScreenState {
  @override
  Widget build(BuildContext context) => BlocConsumer<FlashcardCubit, FlashcardState>(
    listenWhen: (prev, curr) => prev.isSessionFinished != curr.isSessionFinished,
    listener: (context, state) {
      if (state.isSessionFinished) onSessionFinished(context, state);
    },
    builder: (context, state) {
      final colors = context.x.colors;
      final status = state.statusOf('cards');

      if (status.isLoading) {
        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          body: const Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round)),
        );
      }

      if (status.isError) {
        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: QuizAppBar(
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            title: context.x.l10n.flashcardModeTitle,
            showBackButton: true,
            onBackPressed: onBackPressed,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.x.l10n.errorOccurred, style: context.x.textStyle.sfW400s16, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                CustomButton(onTap: onRetryLoad, title: context.x.l10n.retry, borderRadius: 12),
              ],
            ),
          ),
        );
      }

      final card = state.currentCard;
      if (card == null) {
        // Empty deck after a successful load, or the initial (idle) state
        // before loadCards has emitted its loading status.
        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: QuizAppBar(
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            title: context.x.l10n.flashcardModeTitle,
            showBackButton: true,
            onBackPressed: onBackPressed,
          ),
          body: status.isSuccess
              ? Center(child: Text(context.x.l10n.noTestsFound, style: context.x.textStyle.sfW400s16))
              : const Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round)),
        );
      }

      final isTestMode = state.config.mode.name == 'test' && (card.options?.isNotEmpty ?? false);

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBackPressed();
        },
        child: Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: QuizAppBar(
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            title: context.x.l10n.flashcardModeTitle,
            showBackButton: true,
            onBackPressed: onBackPressed,
          ),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                // Full-bleed swipe glow — spans the whole screen width, behind
                // the width-capped card column. Driven by the shared swipe
                // progress; stays 0 (hidden) in test mode.
                if (!isTestMode)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ValueListenableBuilder<double>(
                        valueListenable: swipeProgress,
                        builder: (context, progress, _) {
                          final opacity = progress.abs().clamp(0.0, 1.0);
                          if (opacity <= 0.01) return const SizedBox.shrink();
                          return FlashcardEdgeGlow(known: progress >= 0, opacity: opacity * 0.9);
                        },
                      ),
                    ),
                  ),
                // Keep the study column phone-width and centered on tablet/desktop
                // (matches the setup screen's 560 cap). On a phone 560 > width, so
                // it fills the screen as before.
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        FlashcardProgressBar(
                          current: state.currentIndex + 1,
                          total: state.cards.length,
                          canUndo: state.currentIndex > 0,
                          onUndo: onUndo,
                        ),
                        Expanded(
                          child: isTestMode
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: FlashcardTestCard(
                                    card: card,
                                    selectedOptionId: state.selectedOptionId,
                                    isChecked: state.isOptionChecked,
                                    onSelect: (option) => onSelectOption(card, option),
                                  ),
                                )
                              : FlashcardDeckView(
                                  key: deckKey,
                                  card: card,
                                  isFlipped: state.isFlipped,
                                  hasNext: state.currentIndex < state.cards.length - 1,
                                  onFlip: onFlip,
                                  onKnown: onMarkKnown,
                                  onUnknown: onMarkUnknown,
                                  swipeProgress: swipeProgress,
                                ),
                        ),
                        if (!isTestMode)
                          FlashcardFooter(
                            knownCount: state.knownIds.length,
                            unknownCount: state.unknownIds.length,
                            onKnown: onPressKnownButton,
                            onUnknown: onPressUnknownButton,
                            swipeProgress: swipeProgress,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
