import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/state_status.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../bloc/test_attempt_cubit.dart';
import '../model/test_attempt_model.dart';
import '../state/test_mode_screen_state.dart';
import '../widgets/test_mode_item_widget.dart';
import '../widgets/test_result_item_widget.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({required this.testId, super.key});

  final String testId;

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends TestModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Rejim',
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
        const SizedBox(height: 16),
        Text('Rejimni tanlang:', style: context.x.textStyle.sfW500s22),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: testModes.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) => TestModeItemWidget(
            title: testModes[index].title,
            description: testModes[index].description,
            image: testModes[index].image.svg(
              package: 'ui',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
            ),
            onPressed: () => onPressTestMode(testModes[index]),
          ),
        ),
        const SizedBox(height: 24),
        Text('Urinishlar tarixi:', style: context.x.textStyle.sfW500s22),
        const SizedBox(height: 12),
        BlocBuilder<TestAttemptCubit, TestAttemptState>(
          builder: (context, state) {
            switch (state.status) {
              case StateStatus.idle:
              case StateStatus.loading:
              case StateStatus.loadingMore:
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              case StateStatus.noInternetConnection:
              case StateStatus.error:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? 'Xatolik yuz berdi',
                          style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => context.read<TestAttemptCubit>().getAttempts(widget.testId),
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  ),
                );
              case StateStatus.success:
                if (state.attempts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Hozircha urinishlar mavjud emas',
                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.attempts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final attempt = state.attempts[index];
                    return _TestAttemptItemWidget(attempt: attempt);
                  },
                );
            }
          },
        ),
      ],
    ),
  );
}

class _TestAttemptItemWidget extends StatelessWidget {
  const _TestAttemptItemWidget({required this.attempt});
  final TestAttempt attempt;

  String format(Duration duration) {
    final totalMinutes = duration.inMinutes;
    final normalizedMinutes = totalMinutes < 0 ? 0 : totalMinutes;
    final normalizedSeconds = duration.inSeconds.remainder(60).abs();
    return '${normalizedMinutes.toString().padLeft(1, '0')}:${normalizedSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final correct = attempt.correctAnswers;
    final total = attempt.totalQuestions;
    final wrong = (total - correct).clamp(0, total);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: context.x.colors.bannerBackground),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 4,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Urinish #${attempt.id}',
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${attempt.createdAt.day.toString().padLeft(2, '0')}.${attempt.createdAt.month.toString().padLeft(2, '0')}.${attempt.createdAt.year}',
                  style: context.x.textStyle.sfW400s16.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.vectors.correct.svg(package: 'ui'),
              leadingTitle: 'To‘g‘ri javoblar',
              trailingTitle: correct.toString(),
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.vectors.wrong.svg(package: 'ui'),
              leadingTitle: 'Noto‘g‘ri javoblar',
              trailingTitle: wrong.toString(),
            ),
            _ResultInfoWidget(
              leadingIcon: Assets.lib.vectors.timer2.svg(package: 'ui'),
              leadingTitle: 'Sarf etilgan vaqt',
              trailingTitle: format(Duration(seconds: attempt.timeSpent)),
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
              color: context.x.colors.black,
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
          color: context.x.colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    ],
  );
}
