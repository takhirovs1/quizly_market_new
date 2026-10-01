import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/flashcard_cubit.dart';
import '../state/flashcard_screen_state.dart';

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
      if (state.isSessionFinished) {
        onSessionFinished(context, state);
      }
    },
    builder: (context, state) {
      final status = state.statusOf('cards');

      if (status.isLoading) {
        return Scaffold(
          backgroundColor: context.x.colors.scaffoldBackground,
          body: const Center(child: CircularProgressIndicator(strokeCap: StrokeCap.round)),
        );
      }

      if (status.isError) {
        return Scaffold(
          backgroundColor: context.x.colors.scaffoldBackground,
          appBar: QuizAppBar(
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            title: context.x.l10n.flashcardModeTitle,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.x.l10n.errorOccurred,
                  style: context.x.textStyle.sfW400s16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onTap: onRetryLoad,
                  title: context.x.l10n.retry,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        );
      }

      if (state.cards.isEmpty && status.isSuccess) {
        return Scaffold(
          backgroundColor: context.x.colors.scaffoldBackground,
          appBar: QuizAppBar(
            telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
            title: context.x.l10n.flashcardModeTitle,
          ),
          body: Center(child: Text(context.x.l10n.noTestsFound, style: context.x.textStyle.sfW400s16)),
        );
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) { if (!didPop) onBackPressed(); },
        child: Scaffold(
          backgroundColor: context.x.colors.scaffoldBackground,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(child: _buildCardArea(context, state)),
                if (state.config.mode.name == 'study') _buildStudyActions(context, state),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _buildHeader(BuildContext context, FlashcardState state) {
    final colors = context.x.colors;
    final total = state.cards.length;
    final current = state.currentIndex + 1;
    final progress = total > 0 ? current / total : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        top: context.telegramWebApp.safeAreaInset.top.toDouble() + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBackPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.textFieldBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close_rounded, color: colors.text, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$current / $total',
                style: context.x.textStyle.sfW500s14.copyWith(color: colors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardArea(BuildContext context, FlashcardState state) {
    final card = state.currentCard;
    if (card == null) return const SizedBox.shrink();

    return GestureDetector(
      onHorizontalDragEnd: onHorizontalDrag,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: state.config.mode.name == 'test' && card.options != null && card.options!.isNotEmpty
            ? buildTestCard(context, state, card)
            : buildStudyCard(context, state, card),
      ),
    );
  }

  Widget _buildStudyActions(BuildContext context, FlashcardState state) {
    if (state.cards.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: context.x.l10n.flashcardUnknown,
              color: context.x.colors.error,
              icon: Icons.close_rounded,
              onTap: onMarkUnknown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: context.x.l10n.flashcardKnown,
              color: context.x.colors.appleGreen,
              icon: Icons.check_rounded,
              onTap: onMarkKnown,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.color, required this.icon, required this.onTap});

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.x.textStyle.sfW500s16.copyWith(color: color, fontSize: 15),
          ),
        ],
      ),
    ),
  );
}
