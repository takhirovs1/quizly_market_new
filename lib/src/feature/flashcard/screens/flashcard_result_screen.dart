import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/flashcard_cubit.dart';
import '../state/flashcard_result_screen_state.dart';
import '../widgets/flashcard_accuracy_ring.dart';
import '../widgets/flashcard_stat_row.dart';

class FlashcardResultScreen extends StatefulWidget {
  const FlashcardResultScreen({
    required this.testId,
    required this.knownCount,
    required this.unknownCount,
    required this.total,
    required this.durationSec,
    required this.mode,
    super.key,
  });

  final String testId;
  final int knownCount;
  final int unknownCount;
  final int total;
  final int durationSec;
  final String mode;

  @override
  State<FlashcardResultScreen> createState() => _FlashcardResultScreenState();
}

class _FlashcardResultScreenState extends FlashcardResultScreenState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final l10n = context.x.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackPressed();
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        body: SafeArea(
          // Keep the result column phone-width and centered on tablet/desktop.
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: context.telegramWebApp.safeAreaInset.top.toDouble() + 16,
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.flashcardResultTitle,
                            style: context.x.textStyle.sfW500s22,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          FlashcardAccuracyRing(accuracy: accuracy),
                          const SizedBox(height: 32),
                          FlashcardStatRow(
                            icon: Icons.check_circle_rounded,
                            iconColor: colors.appleGreen,
                            label: l10n.flashcardKnownCount,
                            value: widget.knownCount.toString(),
                          ),
                          const SizedBox(height: 12),
                          FlashcardStatRow(
                            icon: Icons.cancel_rounded,
                            iconColor: colors.error,
                            label: l10n.flashcardUnknownCount,
                            value: widget.unknownCount.toString(),
                          ),
                          const SizedBox(height: 12),
                          FlashcardStatRow(
                            icon: Icons.timer_rounded,
                            iconColor: colors.primary,
                            label: l10n.flashcardDuration,
                            value: durationFormatted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        if (widget.unknownCount > 0) ...[
                          BlocBuilder<FlashcardCubit, FlashcardState>(
                            builder: (context, state) => CustomButton(
                              onTap: onRetryUnknown,
                              title: l10n.flashcardRetryUnknown,
                              borderRadius: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        CustomButton(
                          onTap: onFinish,
                          title: l10n.flashcardFinish,
                          borderRadius: 14,
                          color: colors.textFieldBackground,
                          textColor: colors.text,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
