import 'package:intl/intl.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../model/test_attempt_model.dart';

class TestAttemptWidget extends StatefulWidget {
  const TestAttemptWidget({required this.attempt, this.backgroundColor, this.isResultScreen = false, super.key});
  final TestAttempt attempt;
  final Color? backgroundColor;
  final bool isResultScreen;
  @override
  State<TestAttemptWidget> createState() => _TestAttemptWidgetState();
}

class _TestAttemptWidgetState extends State<TestAttemptWidget> {
  String format(Duration duration) {
    final totalMinutes = duration.inMinutes;
    final normalizedMinutes = totalMinutes < 0 ? 0 : totalMinutes;
    final normalizedSeconds = duration.inSeconds.remainder(60).abs();
    return '${normalizedMinutes.toString().padLeft(1, '0')}:${normalizedSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.attempt;

    final correct = a.correctAnswers;
    final total = a.totalQuestions;
    final skipped = a.skipCount;
    final wrong = (total - correct - skipped).clamp(0, total);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.isResultScreen
            ? context.x.colors.transparent
            : (widget.backgroundColor ?? context.x.colors.bannerBackground),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 4,
          children: [
            if (!widget.isResultScreen)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(a.createdAt.toLocal()),
                    style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy').format(a.createdAt.toLocal()),
                    style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.icon.correct.svg(package: 'ui'),
              leadingTitle: context.x.l10n.correctLabel,
              trailingTitle: context.x.l10n.countTaText(correct),
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.icon.wrong.svg(package: 'ui'),
              leadingTitle: context.x.l10n.wrongLabel,
              trailingTitle: context.x.l10n.countTaText(wrong),
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.icon.timer.svg(package: 'ui'),
              leadingTitle: context.x.l10n.skippedLabel,
              trailingTitle: context.x.l10n.countTaText(skipped),
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.icon.timer2.svg(package: 'ui'),
              leadingTitle: context.x.l10n.timeLabel,
              trailingTitle: format(Duration(seconds: a.timeSpent)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultInfoWidget extends StatelessWidget {
  const _ResultInfoWidget({required this.leadingIcon, required this.leadingTitle, required this.trailingTitle});
  final String leadingTitle;
  final String trailingTitle;
  final Widget leadingIcon;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        spacing: 12,
        children: [
          leadingIcon,
          Text(
            leadingTitle,
            style: context.x.textStyle.sfW500s16.copyWith(
              color: context.x.colors.text,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      Expanded(child: DottedDivider(color: context.x.colors.gray)),
      Text(
        trailingTitle,
        style: context.x.textStyle.sfW500s16.copyWith(
          color: context.x.colors.text,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class DottedDivider extends StatelessWidget {
  const DottedDivider({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .symmetric(horizontal: 8),
    child: SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          const dashSpace = 4.0;
          final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          if (dashCount <= 0) return const SizedBox.shrink();

          return Row(
            mainAxisAlignment: .spaceBetween,
            children: .generate(
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
