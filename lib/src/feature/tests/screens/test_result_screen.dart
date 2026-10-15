import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/logger.dart' as log_util;
import '../model/test_route_arguments.dart';

/// Shared result screen for every mode (test, university, flashcard, random):
/// cup animation, score + XP, this session's stats and the previous attempt.
class TestResultScreen extends StatefulWidget {
  const TestResultScreen({required this.arguments, super.key});

  final TestResultArguments arguments;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  TestResultArguments get _args => widget.arguments;

  /// "Qayta ishlash" — reopen the flow that produced this result.
  void onRetryPressed() {
    switch (_args.mode) {
      case TestResultMode.flashcard:
        context.octopus.pushReplacement(Routes.testFlashcardMode, arguments: {'id': _args.testId});
      case TestResultMode.random:
        // Random sessions aren't tied to one test — restart from Home.
        context.octopus.navigate(Routes.home.name);
      case TestResultMode.test || TestResultMode.university:
        context.octopus.pushReplacement(Routes.testMode, arguments: {'id': _args.testId});
    }
  }

  void onExitPressed() => context.octopus.navigate(Routes.home.name);

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton(onRetryPressed);
    log_util.info('TestResultScreen loaded: attemptId=${_args.attemptId}, testId=${_args.testId}, mode=${_args.mode}');
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onRetryPressed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.x.l10n;
    final colors = context.x.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final cupSize = (MediaQuery.sizeOf(context).width * 0.55).clamp(160.0, 240.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onRetryPressed();
      },
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: l10n.resultTitle,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        ),
        body: DecoratedBox(
          decoration: _glowDecoration(context),
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 100 + bottomInset),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CupHeader(size: cupSize),
                      const SizedBox(height: 8),
                      _ResultTitle(args: _args),
                      const SizedBox(height: 16),
                      _ScoreRow(args: _args),
                      const SizedBox(height: 20),
                      _CurrentStats(args: _args),
                      const SizedBox(height: 24),
                      _LastAttempt(args: _args),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const .fromLTRB(20, 8, 20, 16),
                child: CustomButton2(
                  onLeftPressed: onExitPressed,
                  leftText: l10n.exit,
                  leftButtonType: .active,
                  onRightPressed: onRetryPressed,
                  rightText: l10n.retryTest,
                  rightButtonType: .active,
                  width: context.x.width,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _glowDecoration(BuildContext context) {
    final bg = context.x.colors.scaffoldBackground;
    final colors = [
      context.x.colors.resultGlowInner,
      context.x.colors.resultGlowOuter,
      bg.withValues(alpha: context.x.isDarkMode ? 0.05 : 0.2),
      bg,
    ];
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.1,
        colors: colors,
        stops: const [0, 0.45, 0.85, 1],
      ),
    );
  }
}

String _formatDuration(BuildContext context, int timeInSeconds) {
  if (timeInSeconds < 60) return context.x.l10n.secondsText(timeInSeconds.toString());
  final minutes = timeInSeconds ~/ 60;
  final seconds = timeInSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _CupHeader extends StatelessWidget {
  const _CupHeader({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: size + 32,
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Isolate the continuously animating layers from the static content.
        const Positioned.fill(child: RepaintBoundary(child: _FloatingStarsEffect())),
        RepaintBoundary(child: QuizLottieIcon(QuizLottie.cup, size: size)),
      ],
    ),
  );
}

class _ResultTitle extends StatelessWidget {
  const _ResultTitle({required this.args});
  final TestResultArguments args;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    final testName = args.testName ?? '';
    final academicYear = args.academicYear;
    final subtitle = <String>[
      if (args.description case final description? when description.isNotEmpty) description,
      if (academicYear != null && academicYear.isNotEmpty) context.x.l10n.academicYearCourse(academicYear),
      if (args.semester != null) context.x.l10n.semesterNumber(args.semester!),
    ].join(', ');
    final subtitleStyle = textStyle.sfW400s16.copyWith(color: colors.gray);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          if (testName.isNotEmpty)
            Text(
              testName,
              textAlign: TextAlign.center,
              style: textStyle.sfW500s22.copyWith(color: colors.text, height: 1.2, fontWeight: FontWeight.bold),
            ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: subtitleStyle),
          ],
          const SizedBox(height: 6),
          Text(
            context.x.l10n.solvedQuestionsSummary(
              (args.correct + args.wrong).toString(),
              (args.questionCount ?? args.total).toString(),
            ),
            textAlign: TextAlign.center,
            style: subtitleStyle,
          ),
        ],
      ),
    );
  }
}

/// Score percent + XP earned (XP hidden for self-graded flashcards).
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.args});
  final TestResultArguments args;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        QuizPill(
          text: l10n.homeResultPercent(args.scorePercent),
          background: hc.primaryTint,
          foreground: hc.primary,
          fontSize: 14,
        ),
        if (args.mode.givesXp)
          QuizPill(
            leading: const QuizLottieIcon(QuizLottie.fire, size: 16),
            text: l10n.resultXpEarned(args.earnedXp),
            background: hc.streakBg,
            foreground: hc.orangeAccent,
            fontSize: 14,
          ),
      ],
    );
  }
}

// ─── Stats ───────────────────────────────────────────────────────────────────

class _CurrentStats extends StatelessWidget {
  const _CurrentStats({required this.args});
  final TestResultArguments args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.x.l10n;
    final images = Assets.lib.images;
    return Column(
      children: [
        _StatRow(
          icon: images.correctIcon,
          label: l10n.correctLabel.replaceAll(':', ''),
          value: l10n.donaText(args.correct.toString()),
        ),
        _StatRow(
          icon: images.wrongIcon,
          label: l10n.wrongLabel.replaceAll(':', ''),
          value: l10n.donaText(args.wrong.toString()),
        ),
        // Flashcards have no "skipped": every card is known or unknown.
        if (args.mode != TestResultMode.flashcard)
          _StatRow(
            icon: images.timerIcon,
            label: l10n.skippedLabel.replaceAll(':', ''),
            value: l10n.donaText(args.skipped.toString()),
          ),
        _StatRow(
          icon: images.timer2Icon,
          label: l10n.timeLabel.replaceAll(':', ''),
          value: _formatDuration(context, args.time),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label, required this.value});
  final AssetGenImage icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          icon.image(package: 'ui', width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: textStyle.sfW500s16.copyWith(color: colors.text, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: textStyle.sfW600s16.copyWith(color: colors.text, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LastAttempt extends StatelessWidget {
  const _LastAttempt({required this.args});
  final TestResultArguments args;

  @override
  Widget build(BuildContext context) {
    final lastCorrect = args.lastAttemptCorrect;
    final lastTotal = args.lastAttemptTotal;
    final lastTime = args.lastAttemptTime;
    final parsedDate = DateTime.tryParse(args.lastAttemptDate ?? '')?.toLocal();
    if (lastCorrect == null || lastTotal == null || lastTime == null || parsedDate == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.x.l10n;
    final colors = context.x.colors;
    final images = Assets.lib.images;
    final boldStyle = context.x.textStyle.sfW600s16.copyWith(color: colors.text, fontWeight: FontWeight.bold);
    final lastSkip = args.lastAttemptSkip ?? 0;
    final attemptWrong = (lastTotal - lastCorrect - lastSkip).clamp(0, lastTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(l10n.lastTime, style: boldStyle),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colors.textFieldBackground, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('HH:mm').format(parsedDate), style: boldStyle),
                  Text(DateFormat('dd.MM.yyyy').format(parsedDate), style: boldStyle),
                ],
              ),
              const SizedBox(height: 12),
              _HistoryRow(icon: images.correctIcon, label: l10n.correctLabel, value: l10n.countTaText('$lastCorrect')),
              _HistoryRow(icon: images.wrongIcon, label: l10n.wrongLabel, value: l10n.countTaText('$attemptWrong')),
              _HistoryRow(icon: images.timerIcon, label: l10n.skippedLabel, value: l10n.countTaText('$lastSkip')),
              _HistoryRow(icon: images.timer2Icon, label: l10n.timeLabel, value: _formatDuration(context, lastTime)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.icon, required this.label, required this.value});
  final AssetGenImage icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Padding(
      padding: const .only(bottom: 8),
      child: Row(
        children: [
          icon.image(package: 'ui', width: 14, height: 14),
          const SizedBox(width: 8),
          Text(label, style: textStyle.sfW400s14.copyWith(color: colors.text)),
          _DottedLine(color: colors.gray.withValues(alpha: 0.3)),
          Text(
            value,
            style: textStyle.sfW500s14.copyWith(color: colors.text, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Dotted Line ─────────────────────────────────────────────────────────────

class _DottedLine extends StatelessWidget {
  const _DottedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          if (boxWidth <= 0) return const SizedBox.shrink();
          const dashWidth = 3.0;
          const dashSpace = 3.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(decoration: BoxDecoration(color: color)),
              ),
            ),
          );
        },
      ),
    ),
  );
}

// ─── Floating Stars Animation ────────────────────────────────────────────────

enum _SparkleType { sparkle4, dot }

class _FloatingStarsEffect extends StatelessWidget {
  const _FloatingStarsEffect();

  @override
  Widget build(BuildContext context) {
    final particleColor = context.x.colors.resultParticle;
    final darkSparkleColor = context.x.colors.resultSparkle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        return Stack(
          children: [
            _AnimatedStar(
              left: centerX - 100,
              top: centerY - 15,
              size: 16,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 0,
              durationMs: 2200,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX - 140,
              top: centerY - 80,
              size: 10,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 400,
              durationMs: 2600,
            ),
            _AnimatedStar(
              left: centerX - 110,
              top: centerY + 65,
              size: 14,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 800,
              durationMs: 2400,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX - 120,
              top: centerY + 25,
              size: 4,
              type: _SparkleType.dot,
              color: particleColor,
              delayMs: 200,
              durationMs: 1800,
            ),
            _AnimatedStar(
              left: centerX + 95,
              top: centerY - 25,
              size: 14,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 300,
              durationMs: 2300,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX + 135,
              top: centerY - 80,
              size: 8,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 600,
              durationMs: 2500,
            ),
            _AnimatedStar(
              left: centerX + 110,
              top: centerY + 55,
              size: 18,
              type: _SparkleType.sparkle4,
              color: context.x.colors.resultStar,
              delayMs: 100,
              durationMs: 2100,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX - 35,
              top: centerY + 95,
              size: 8,
              type: _SparkleType.sparkle4,
              color: darkSparkleColor,
              delayMs: 900,
              durationMs: 2000,
            ),
            _AnimatedStar(
              left: centerX + 25,
              top: centerY + 100,
              size: 5,
              type: _SparkleType.dot,
              color: particleColor,
              delayMs: 500,
              durationMs: 2200,
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  const _AnimatedStar({
    required this.left,
    required this.top,
    required this.size,
    required this.type,
    required this.color,
    required this.delayMs,
    required this.durationMs,
    this.rotate = false,
  });

  final double left;
  final double top;
  final double size;
  final _SparkleType type;
  final Color color;
  final int delayMs;
  final int durationMs;
  final bool rotate;

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatY;
  late final Animation<double> _floatX;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    _floatY = Tween<double>(begin: 4, end: -4).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _floatX = Tween<double>(begin: -2, end: 2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.2), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.6), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotation = Tween<double>(
      begin: 0,
      end: widget.rotate ? 2 * 3.1415926535 : 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: widget.left,
    top: widget.top,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget starWidget;
        if (widget.type == _SparkleType.sparkle4) {
          starWidget = CustomPaint(size: Size(widget.size, widget.size), painter: _SparklePainter(widget.color));
        } else {
          starWidget = Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          );
        }

        return Transform.translate(
          offset: Offset(_floatX.value, _floatY.value),
          child: Transform.rotate(
            angle: _rotation.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Opacity(opacity: _opacity.value, child: starWidget),
            ),
          ),
        );
      },
    ),
  );
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final rx = w / 2;
    final ry = h / 2;
    final path = Path()
      ..moveTo(cx, cy - ry)
      ..quadraticBezierTo(cx, cy, cx + rx, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + ry)
      ..quadraticBezierTo(cx, cy, cx - rx, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - ry);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}
