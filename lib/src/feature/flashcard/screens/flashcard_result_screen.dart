import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/flashcard_cubit.dart';
import '../state/flashcard_result_screen_state.dart';

class FlashcardResultScreen extends StatefulWidget {
  const FlashcardResultScreen({
    super.key,
    required this.testId,
    required this.knownCount,
    required this.unknownCount,
    required this.total,
    required this.durationSec,
    required this.mode,
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
    final accuracy = widget.total > 0 ? widget.knownCount / widget.total : 0.0;
    final durationFormatted = _formatDuration(widget.durationSec);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) onBackPressed(); },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        body: SafeArea(
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
                      _AccuracyRing(accuracy: accuracy),
                      const SizedBox(height: 32),
                      _StatRow(
                        icon: Icons.check_circle_rounded,
                        iconColor: colors.appleGreen,
                        label: l10n.flashcardKnownCount,
                        value: widget.knownCount.toString(),
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        icon: Icons.cancel_rounded,
                        iconColor: colors.error,
                        label: l10n.flashcardUnknownCount,
                        value: widget.unknownCount.toString(),
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
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
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _AccuracyRing extends StatelessWidget {
  const _AccuracyRing({required this.accuracy});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final percent = (accuracy * 100).round();
    final color = percent >= 80 ? colors.appleGreen : percent >= 50 ? colors.primary : colors.error;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _RingPainter(
              progress: accuracy,
              color: color,
              backgroundColor: colors.divider,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: context.x.textStyle.sfW700s28.copyWith(color: color, fontSize: 36),
              ),
              Text(
                context.x.l10n.flashcardResultTitle,
                style: context.x.textStyle.sfW400s12.copyWith(color: colors.gray, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color, required this.backgroundColor});

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.iconColor, required this.label, required this.value});

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.cardBackground2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: context.x.textStyle.sfW400s16.copyWith(fontSize: 15))),
          Text(
            value,
            style: context.x.textStyle.sfW600s16.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
