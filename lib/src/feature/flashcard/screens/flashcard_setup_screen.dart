import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../my_tests/models/test_model.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../../tests/bloc/test_view.dart';
import '../model/flashcard_config.dart';
import '../state/flashcard_setup_screen_state.dart';
import '../widgets/flashcard_segmented_control.dart';
import '../widgets/flashcard_web_info_card.dart';

class FlashcardSetupScreen extends StatefulWidget {
  const FlashcardSetupScreen({required this.testId, super.key});

  final String testId;

  @override
  State<FlashcardSetupScreen> createState() => _FlashcardSetupScreenState();
}

class _FlashcardSetupScreenState extends FlashcardSetupScreenState {
  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final isMobile = context.x.isMobile || context.x.isTablet;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackPressed();
      },
      child: BlocBuilder<TestView, TestViewState>(
        builder: (context, state) {
          final detail = state.detail;

          if (detail == null) {
            return Scaffold(
              backgroundColor: colors.scaffoldBackground,
              appBar: _appBar(context),
              bottomNavigationBar: isMobile ? _buildShimmerButton(context) : null,
              body: _buildShimmer(context),
            );
          }

          final testModel = TestModel(
            id: detail.id,
            categoryId: detail.categoryId,
            name: detail.name ?? '',
            description: detail.description ?? '',
            price: detail.price,
            isPurchased: detail.isPurchased,
            isLiked: detail.isLiked,
            questionCount: detail.questionCount,
            createdAt: detail.createdAt,
            academicYear: detail.academicYear,
            semester: detail.semester,
            code: detail.code,
            isArchived: detail.isArchived,
            createdBy: detail.createdAt != null
                ? '${context.x.l10n.uploadedAt}: ${DateFormat('dd.MM.yyyy').format(detail.createdAt!.toLocal())}'
                : null,
          );

          // Adjust the slider bounds once the question count is known.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) onDetailLoaded(detail.questionCount ?? 0, name: detail.name);
          });

          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: _appBar(context),
            bottomNavigationBar: isMobile ? _buildStartButtonBar(context) : null,
            body: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 800
                  ? _buildWebLayout(context, testModel)
                  : _buildMobileLayout(context, testModel),
            ),
          );
        },
      ),
    );
  }

  QuizAppBar _appBar(BuildContext context) => QuizAppBar(
    telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    title: context.x.l10n.flashcardModeTitle,
  );

  Widget _buildStartButtonBar(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: CustomButton(onTap: onPressStart, title: context.x.l10n.flashcardStartButton, borderRadius: 10),
    ),
  );

  // ─── MOBILE LAYOUT ──────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, TestModel testModel) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TestDescriptionWidget(
        test: testModel,
        onPressLike: onPressLike,
        onPressShare: onPressShare,
        onPressArchive: onPressArchive,
      ),
      const SizedBox(height: 24),
      Text(context.x.l10n.flashcardSetupTitle, style: context.x.textStyle.sfW500s22),
      const SizedBox(height: 16),
      ..._setupControls(context),
    ],
  );

  // ─── WEB LAYOUT ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context, TestModel testModel) {
    final colors = context.x.colors;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: test info card.
                  Expanded(
                    flex: 5,
                    child: FlashcardWebInfoCard(
                      testModel: testModel,
                      onPressLike: onPressLike,
                      onPressShare: onPressShare,
                      onPressArchive: onPressArchive,
                    ),
                  ),
                  const SizedBox(width: 28),
                  // Right: setup configuration card with the inline start button.
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.cardBackground2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colors.black.withValues(alpha: 0.06), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(context.x.l10n.flashcardSetupTitle, style: context.x.textStyle.sfW500s22),
                          const SizedBox(height: 24),
                          ..._setupControls(context),
                          const SizedBox(height: 36),
                          CustomButton(
                            onTap: onPressStart,
                            title: context.x.l10n.flashcardStartButton,
                            borderRadius: 12,
                          ),
                        ],
                      ),
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

  // ─── SHARED CONTROLS ──────────────────────────────────────────────────────────
  List<Widget> _setupControls(BuildContext context) => [
    // Card count (range).
    Text(context.x.l10n.flashcardCardCountPrompt, style: _promptStyle(context)),
    const SizedBox(height: 8),
    _buildRange(context),
    const SizedBox(height: 24),

    // Order (shuffle vs original).
    Text(context.x.l10n.flashcardShufflePrompt, style: _promptStyle(context)),
    const SizedBox(height: 8),
    ValueListenableBuilder<bool>(
      valueListenable: shuffle,
      builder: (context, isShuffle, _) => FlashcardSegmentedControl(
        options: [context.x.l10n.flashcardShuffle, context.x.l10n.flashcardOriginalOrder],
        selectedIndex: isShuffle ? 0 : 1,
        onChanged: (index) => shuffle.value = index == 0,
      ),
    ),
    const SizedBox(height: 24),

    // Direction.
    Text(context.x.l10n.flashcardDirectionPrompt, style: _promptStyle(context)),
    const SizedBox(height: 8),
    ValueListenableBuilder<FlashcardDirection>(
      valueListenable: direction,
      builder: (context, value, _) => FlashcardSegmentedControl(
        options: [context.x.l10n.flashcardQuestionFirst, context.x.l10n.flashcardAnswerFirst],
        selectedIndex: value == FlashcardDirection.questionFirst ? 0 : 1,
        onChanged: (index) =>
            direction.value = index == 0 ? FlashcardDirection.questionFirst : FlashcardDirection.answerFirst,
      ),
    ),
  ];

  Widget _buildRange(BuildContext context) => ValueListenableBuilder<RangeValues>(
    valueListenable: cardRange,
    builder: (context, range, _) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _rangeValueLabel(context, range.start.toInt()),
        Flexible(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: context.x.colors.primary,
              inactiveTrackColor: context.x.colors.gray.withValues(alpha: 0.25),
              thumbColor: context.x.colors.white,
              overlayColor: context.x.colors.primary.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: RangeSlider(
              values: range,
              min: minCards.toDouble(),
              max: totalCards.toDouble(),
              onChanged: (value) {
                final snapped = snapRange(value);
                if (snapped != cardRange.value) {
                  context.telegramWebApp.hapticImpact(.light);
                  cardRange.value = snapped;
                }
              },
            ),
          ),
        ),
        _rangeValueLabel(context, range.end.toInt()),
      ],
    ),
  );

  Widget _rangeValueLabel(BuildContext context, int value) => Text(
    '$value',
    style: context.x.textStyle.sfW500s16.copyWith(
      color: context.x.colors.gray,
      fontWeight: FontWeight.w700,
      fontSize: 17,
    ),
  );

  TextStyle _promptStyle(BuildContext context) => context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray);

  Widget _buildShimmerButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          highlightColor: isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9),
          child: const ShimmerBox(width: double.infinity, height: 48, radius: 10),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 180, height: 26, radius: 8),
            const SizedBox(height: 10),
            const ShimmerBox(width: 240, height: 16, radius: 8),
            const SizedBox(height: 32),
            for (var i = 0; i < 3; i++) ...[
              const ShimmerBox(width: 120, height: 16, radius: 8),
              const SizedBox(height: 12),
              const ShimmerBox(width: double.infinity, height: 48, radius: 12),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}
