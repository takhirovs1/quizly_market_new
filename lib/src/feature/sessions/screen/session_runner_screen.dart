import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/session_cubit.dart';
import '../model/session_models.dart';

/// Figma "D · Random test flow" / "E · Mistakes flow": the shared session runner
/// — question card, answer options with per-answer feedback, and the result view.
class SessionRunnerScreen extends StatefulWidget {
  const SessionRunnerScreen({super.key});

  @override
  State<SessionRunnerScreen> createState() => _SessionRunnerScreenState();
}

class _SessionRunnerScreenState extends State<SessionRunnerScreen> {
  Timer? _ticker;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _timer {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Scaffold(
      backgroundColor: hc.bg,
      appBar: QuizAppBar(
        title: l10n.homeActionRandom,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            if (state.result != null) return _ResultView(result: state.result!);
            if (state.status.isLoading) return const Center(child: CircularProgressIndicator.adaptive());
            if (state.status.isError || state.question == null) return _error(context);
            return _runner(context, state);
          },
        ),
      ),
    );
  }

  Widget _error(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.errorOccurred, textAlign: TextAlign.center, style: quizText(14, wMedium, hc.text3)),
            const SizedBox(height: 12),
            QuizButton(label: l10n.cancel, size: QuizButtonSize.s, onTap: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }

  Widget _runner(BuildContext context, SessionState state) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    final q = state.question!;
    final progress = state.total == 0 ? 0.0 : (state.index + 1) / state.total;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              // Progress: counter + timer + bar.
              Row(
                children: [
                  Text('${state.index + 1} / ${state.total}', style: quizText(15, wBold, hc.text)),
                  const Spacer(),
                  Text('⏱ $_timer', style: quizText(13, wMedium, hc.text3)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: hc.track,
                  valueColor: AlwaysStoppedAnimation<Color>(hc.primary),
                ),
              ),
              const SizedBox(height: 16),
              // Question card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: hc.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [hc.softShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.text, style: quizText(20, wSemibold, hc.text, height: 1.3)),
                    if ((q.sourceTestName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('📘', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.sessionSource(q.sourceTestName!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: quizText(13, wMedium, hc.text3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Options.
              for (var i = 0; i < q.options.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  option: q.options[i],
                  selectedId: state.selectedOptionId,
                  correctId: state.feedback?.correctOptionId,
                  checked: state.isChecked,
                  onTap: () => context.read<SessionCubit>().check(q.options[i].id),
                ),
              ],
              if (state.isChecked) ...[
                const SizedBox(height: 16),
                _FeedbackBanner(state: state),
              ],
            ],
          ),
        ),
        // Footer "Keyingi".
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: QuizButton(
            label: state.isLast ? l10n.sessionFinish : l10n.sessionNext,
            size: QuizButtonSize.l,
            expand: true,
            onTap: state.isChecked && !state.finishing ? context.read<SessionCubit>().next : null,
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.option,
    required this.selectedId,
    required this.correctId,
    required this.checked,
    required this.onTap,
  });

  final String letter;
  final SessionOption option;
  final String? selectedId;
  final String? correctId;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final isSelected = selectedId == option.id;
    final isCorrect = correctId == option.id;

    var bg = hc.surface;
    var border = hc.border;
    var letterBg = hc.bg;
    var letterFg = hc.text2;

    if (checked) {
      if (isCorrect) {
        bg = colors.optionCorrectBackground;
        border = colors.answerCorrect;
        letterBg = colors.answerCorrect;
        letterFg = colors.pureWhite;
      } else if (isSelected) {
        bg = colors.optionWrongBackground;
        border = colors.answerWrong;
        letterBg = colors.answerWrong;
        letterFg = colors.pureWhite;
      }
    } else if (isSelected) {
      bg = hc.primaryTint;
      border = hc.primary;
      letterBg = hc.primary;
      letterFg = colors.pureWhite;
    }

    return GestureDetector(
      onTap: checked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: letterBg, shape: BoxShape.circle),
              child: Text(letter, style: quizText(14, wSemibold, letterFg)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(option.text, style: quizText(15, wMedium, hc.text))),
          ],
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final correct = state.feedback?.isCorrect ?? false;
    // The correct option's letter + text, for the "wrong" hint.
    final q = state.question!;
    final correctIndex = q.options.indexWhere((o) => o.id == state.feedback?.correctOptionId);
    final correctLabel = correctIndex >= 0
        ? '${String.fromCharCode(65 + correctIndex)} — ${q.options[correctIndex].text}'
        : '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? colors.optionCorrectBackground : colors.optionWrongBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(correct ? '✅' : '❌', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? l10n.sessionCorrect : l10n.sessionWrong,
                  style: quizText(15, wSemibold, correct ? colors.answerCorrect : colors.answerWrong),
                ),
                if (!correct && correctLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(l10n.sessionCorrectAnswer(correctLabel), style: quizText(13, wMedium, hc.text2, height: 1.3)),
                ],
              ],
            ),
          ),
          if (correct && (state.feedback?.xpGained ?? 0) > 0) ...[
            const SizedBox(width: 8),
            QuizPill(
              text: l10n.resultXp(state.feedback!.xpGained),
              background: colors.answerCorrect.withValues(alpha: 0.15),
              foreground: colors.answerCorrect,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final SessionResult result;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final colors = context.x.colors;
    final l10n = context.x.l10n;
    final title = result.scorePercent >= 80
        ? l10n.resultTitleExcellent
        : result.scorePercent >= 50
        ? l10n.resultTitleGood
        : l10n.resultTitleKeepGoing;
    final isMistakes = result.mode == SessionRunMode.mistakes;
    final subtitle = isMistakes
        ? l10n.resultMistakesSubtitle(result.total)
        : l10n.resultRandomSubtitle(result.total);
    final ringColor = result.scorePercent >= 50 ? colors.answerCorrect : hc.warning;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            children: [
              Center(
                child: _ScoreRing(
                  percent: result.scorePercent,
                  answered: result.correct,
                  total: result.total,
                  color: ringColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: quizText(22, wBold, hc.text)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center, style: quizText(13, wRegular, hc.text3)),
              if (result.xpTotal > 0) ...[
                const SizedBox(height: 12),
                Center(
                  child: QuizPill(
                    text: l10n.resultXp(result.xpTotal),
                    background: colors.answerCorrect.withValues(alpha: 0.15),
                    foreground: colors.answerCorrect,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${result.correct}',
                      label: l10n.resultCorrectLabel,
                      color: colors.answerCorrect,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: '${result.wrong}',
                      label: isMistakes && result.mistakesResolvedCount > 0
                          ? l10n.resultMistakesResolved(result.mistakesResolvedCount)
                          : l10n.resultWrongLabel,
                      color: colors.answerWrong,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              QuizButton(
                label: l10n.retryTest,
                type: QuizButtonType.tonal,
                size: QuizButtonSize.l,
                expand: true,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 10),
              QuizButton(
                label: l10n.sessionFinish,
                size: QuizButtonSize.l,
                expand: true,
                onTap: () => context.octopus.push(Routes.home),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: hc.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: hc.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: quizText(22, wBold, color)),
          const SizedBox(height: 4),
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: quizText(12, wRegular, hc.text3)),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.percent, required this.answered, required this.total, required this.color});

  final int percent;
  final int answered;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return SizedBox(
      width: 168,
      height: 168,
      child: CustomPaint(
        painter: _RingPainter(percent / 100, color, hc.track),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$percent%', style: quizText(40, wHeavy, hc.text)),
              Text('$answered / $total', style: quizText(14, wMedium, hc.text3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color, this.track);

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color || old.track != track;
}
