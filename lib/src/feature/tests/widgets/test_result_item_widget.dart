import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../model/test_result_response_model.dart';

class TestAttemptWidget extends StatefulWidget {
  const TestAttemptWidget({required this.result, super.key});
  final TestResultResponseModel? result;

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
    final a = widget.result;

    final correct = a?.correctCount ?? 0;
    final total = a?.totalQuestions ?? 0;
    final skipped = a?.skipCount ?? 0;
    final wrong = (total - correct - skipped).clamp(0, total);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: .circular(16), color: context.x.colors.cardBackground),
      child: Padding(
        padding: const .all(12),
        child: Column(
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  a?.startedAt != null ? DateFormat('HH:mm').format(a!.startedAt!.toLocal()) : '',
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: .w700),
                ),
                Text(
                  a?.startedAt != null ? DateFormat('dd.MM.yyyy').format(a!.startedAt!.toLocal()) : '',
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: .w700),
                ),
              ],
            ),
            _ResultInfoWidget(
              leadingIcon: Lottie.asset(Assets.lib.lotties.correct.lottie, width: 24, height: 24, repeat: false),
              leadingTitle: 'context.l10n.correct',
              trailingTitle: context.x.l10n.intToCount(correct).toString(),
              fontSized: 16,
              fontWeight: .w400,
            ),
            _ResultInfoWidget(
              leadingIcon: Lottie.asset(Assets.lottie.incorrect, width: 24, height: 24, repeat: false),
              leadingTitle: context.l10n.wrong,
              trailingTitle: context.l10n.intToCount(wrong).toString(),
              fontSized: 16,
              fontWeight: .w400,
            ),
            _ResultInfoWidget(
              leadingIcon: Lottie.asset(Assets.lottie.hourglass, width: 24, height: 24, repeat: false),
              leadingTitle: 'context.l10n.skipped',
              trailingTitle: context.l10n.intToCount(skipped).toString(),
              fontSized: 16,
              fontWeight: .w400,
            ),
            _ResultInfoWidget(
              leadingIcon: Lottie.asset(Assets.lottie.clock, width: 24, height: 24, repeat: false),
              leadingTitle: 'context.l10n.time',
              trailingTitle: format(Duration(seconds: a?.timeSpentSec ?? 0)),
              fontSized: 16,
              fontWeight: .w400,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultInfoWidget extends StatelessWidget {
  const _ResultInfoWidget({
    required this.leadingIcon,
    required this.leadingTitle,
    required this.trailingTitle,
    this.fontSized = 18,
    this.fontWeight = .w700,
  });
  final String leadingTitle;
  final String trailingTitle;
  final Widget leadingIcon;

  final double? fontSized;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: .end,
    children: [
      Row(
        spacing: 12,
        children: [
          leadingIcon,
          Text(
            leadingTitle,
            style: context.x.textStyle.sfW500s16.copyWith(
              color: context.x.colors.black,
              fontWeight: fontWeight,
              fontSize: fontSized ?? 18,
            ),
          ),
        ],
      ),
      Expanded(child: DottedDivider(color: context.x.colors.gray)),
      Text(
        trailingTitle,
        style: context.x.textStyle.sfW500s16.copyWith(
          color: context.x.colors.black,
          fontWeight: fontWeight,
          fontSize: fontSized ?? 18,
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
