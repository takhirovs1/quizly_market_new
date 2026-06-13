import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/test_view.dart';
import '../model/test_request_response_models.dart';
import '../model/test_route_arguments.dart';

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({required this.arguments, super.key});

  final TestResultArguments arguments;

  String get testId => arguments.testId;
  int get correct => arguments.correct;
  int get wrong => arguments.wrong;
  int get total => arguments.total;
  int get time => arguments.time;
  String? get attemptId => arguments.attemptId;
  String? get testName => arguments.testName;
  String? get description => arguments.description;
  String? get academicYear => arguments.academicYear;
  int? get semester => arguments.semester;
  int? get questionCount => arguments.questionCount;
  int? get lastAttemptCorrect => arguments.lastAttemptCorrect;
  int? get lastAttemptTotal => arguments.lastAttemptTotal;
  int? get lastAttemptTime => arguments.lastAttemptTime;
  String? get lastAttemptDate => arguments.lastAttemptDate;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  void onBackPressed() {
    context.octopus.pushReplacement(Routes.testMode, arguments: {'id': widget.testId});
  }

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton(onBackPressed);
    final attemptId = widget.attemptId;
    if (attemptId != null && attemptId.isNotEmpty) {
      context.read<TestView>().finishAttempt(
        widget.testId,
        attemptId,
        FinishAttemptRequest(
          answers: const [],
          timeSpentSec: widget.time,
          skipCount: (widget.total - widget.correct - widget.wrong).clamp(0, widget.total),
        ),
      );
    }
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skipped = (widget.total - widget.correct - widget.wrong).clamp(0, widget.total);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cupSize = (screenWidth * 0.55).clamp(160.0, 240.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onBackPressed();
      },
      child: Scaffold(
        backgroundColor: context.x.colors.scaffoldBackground,
        appBar: QuizAppBar(
          title: context.x.l10n.resultTitle,
          telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildGlowDecoration(context),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 100 + MediaQuery.of(context).padding.bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Cup & Stars ──
                    SizedBox(
                      height: cupSize + 32,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(child: const _FloatingStarsEffect()),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Assets.lib.images.cupResult.image(
                              package: 'ui',
                              width: cupSize,
                              height: cupSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Test Name & Description ──
                    Builder(
                      builder: (context) {
                        final testName = widget.testName ?? '';
                        final description = widget.description ?? '';
                        final academicYear = widget.academicYear;
                        final semester = widget.semester;
                        final totalQuestionsCount = widget.questionCount ?? widget.total;

                        final parts = <String>[
                          if (description.isNotEmpty) description,
                          if (academicYear != null && academicYear.isNotEmpty) '$academicYear-kurs',
                          if (semester != null) '$semester-semestr',
                        ];
                        final subtitleText = parts.join(', ');
                        final solvedCount = widget.correct + widget.wrong;

                        return Column(
                          children: [
                            if (testName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  testName,
                                  style: context.x.textStyle.sfW500s22.copyWith(
                                    color: context.x.colors.text,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (subtitleText.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  subtitleText,
                                  style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.gray),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              context.x.l10n.solvedQuestionsSummary(
                                solvedCount.toString(),
                                totalQuestionsCount.toString(),
                              ),
                              style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.gray),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Current Session Stats ──
                    _buildStatRow(
                      context,
                      Assets.lib.images.correctIcon.image(package: 'ui'),
                      context.x.l10n.correctLabel.replaceAll(':', ''),
                      context.x.l10n.donaText(widget.correct.toString()),
                    ),
                    _buildStatRow(
                      context,
                      Assets.lib.images.wrongIcon.image(package: 'ui'),
                      context.x.l10n.wrongLabel.replaceAll(':', ''),
                      context.x.l10n.donaText(widget.wrong.toString()),
                    ),
                    _buildStatRow(
                      context,
                      Assets.lib.images.timerIcon.image(package: 'ui'),
                      context.x.l10n.skippedLabel.replaceAll(':', ''),
                      context.x.l10n.donaText(skipped.toString()),
                    ),
                    _buildStatRow(
                      context,
                      Assets.lib.images.timer2Icon.image(package: 'ui'),
                      context.x.l10n.timeLabel.replaceAll(':', ''),
                      _formatCurrentTime(widget.time),
                    ),

                    const SizedBox(height: 24),

                    // ── History Attempts ──
                    Builder(
                      builder: (context) {
                        final lastCorrect = widget.lastAttemptCorrect;
                        final lastTotal = widget.lastAttemptTotal;
                        final lastTime = widget.lastAttemptTime;
                        final lastDateStr = widget.lastAttemptDate;

                        if (lastCorrect == null || lastTotal == null || lastTime == null || lastDateStr == null) {
                          return const SizedBox.shrink();
                        }

                        final parsedDate = DateTime.tryParse(lastDateStr)?.toLocal();
                        if (parsedDate == null) return const SizedBox.shrink();

                        final attemptWrong = (lastTotal - lastCorrect).clamp(0, lastTotal);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                              child: Text(
                                context.x.l10n.lastTime,
                                style: context.x.textStyle.sfW600s16.copyWith(
                                  color: context.x.colors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.x.colors.textFieldBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm').format(parsedDate),
                                        style: context.x.textStyle.sfW600s16.copyWith(
                                          color: context.x.colors.text,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd.MM.yyyy').format(parsedDate),
                                        style: context.x.textStyle.sfW600s16.copyWith(
                                          color: context.x.colors.text,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildHistoryRow(
                                    context,
                                    Assets.lib.images.correctIcon.image(package: 'ui'),
                                    context.x.l10n.correctLabel,
                                    context.x.l10n.countTaText(lastCorrect.toString()),
                                  ),
                                  _buildHistoryRow(
                                    context,
                                    Assets.lib.images.wrongIcon.image(package: 'ui'),
                                    context.x.l10n.wrongLabel,
                                    context.x.l10n.countTaText(attemptWrong.toString()),
                                  ),
                                  _buildHistoryRow(
                                    context,
                                    Assets.lib.images.timerIcon.image(package: 'ui'),
                                    context.x.l10n.skippedLabel,
                                    context.x.l10n.countTaText('0'),
                                  ),
                                  _buildHistoryRow(
                                    context,
                                    Assets.lib.images.timer2Icon.image(package: 'ui'),
                                    context.x.l10n.timeLabel,
                                    _formatAttemptTime(lastTime),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: onBackPressed,
                        title: context.x.l10n.retryTest,
                        color: context.x.colors.primary,
                        borderRadius: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          context.octopus.navigate(Routes.home.name);
                        },
                        title: context.x.l10n.exit,
                        color: context.x.colors.dialogCancelButton,
                        textColor: context.x.colors.primary,
                        borderRadius: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrentTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return context.x.l10n.secondsText(timeInSeconds.toString());
    } else {
      final minutes = timeInSeconds ~/ 60;
      final seconds = timeInSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatAttemptTime(int timeInSeconds) {
    if (timeInSeconds < 60) {
      return context.x.l10n.secondsText(timeInSeconds.toString());
    } else {
      final minutes = timeInSeconds ~/ 60;
      final seconds = timeInSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  BoxDecoration _buildGlowDecoration(BuildContext context) {
    final bg = context.x.colors.scaffoldBackground;
    final isDark = context.x.isDarkMode;
    final colors = isDark
        ? [
            const Color(0xFFFFD13B).withValues(alpha: 0.25),
            const Color(0xFFFFB800).withValues(alpha: 0.12),
            bg.withValues(alpha: 0.05),
            bg,
          ]
        : [
            const Color(0xFFFFF2D0).withValues(alpha: 0.95),
            const Color(0xFFFFF9E6).withValues(alpha: 0.5),
            bg.withValues(alpha: 0.2),
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

  Widget _buildStatRow(BuildContext context, Widget leadingIcon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: 18, height: 18, child: leadingIcon),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          value,
          style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget _buildHistoryRow(BuildContext context, Widget leadingIcon, String label, String value) => Padding(
    padding: const .only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 14, height: 14, child: leadingIcon),
        const SizedBox(width: 8),
        Text(label, style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text)),
        _DottedLine(color: context.x.colors.gray.withValues(alpha: 0.3)),
        Text(
          value,
          style: context.x.textStyle.sfW500s14.copyWith(color: context.x.colors.text, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
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
    final isDark = context.x.isDarkMode;
    final particleColor = isDark ? const Color(0x40FFFFFF) : const Color(0x60333333);
    final darkSparkleColor = isDark ? const Color(0x60FFFFFF) : const Color(0x80333333);

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
              color: const Color(0xFFFFD13B),
              delayMs: 0,
              durationMs: 2200,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX - 140,
              top: centerY - 80,
              size: 10,
              type: _SparkleType.sparkle4,
              color: const Color(0xFFFFD13B),
              delayMs: 400,
              durationMs: 2600,
            ),
            _AnimatedStar(
              left: centerX - 110,
              top: centerY + 65,
              size: 14,
              type: _SparkleType.sparkle4,
              color: const Color(0xFFFFD13B),
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
              color: const Color(0xFFFFD13B),
              delayMs: 300,
              durationMs: 2300,
              rotate: true,
            ),
            _AnimatedStar(
              left: centerX + 135,
              top: centerY - 80,
              size: 8,
              type: _SparkleType.sparkle4,
              color: const Color(0xFFFFD13B),
              delayMs: 600,
              durationMs: 2500,
            ),
            _AnimatedStar(
              left: centerX + 110,
              top: centerY + 55,
              size: 18,
              type: _SparkleType.sparkle4,
              color: const Color(0xFFFFD13B),
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
