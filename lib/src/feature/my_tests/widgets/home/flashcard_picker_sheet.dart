import 'package:ui/ui.dart';

import '../../../../common/extension/context_extension.dart';
import '../../models/test_model.dart';

/// Figma "F · Flashcard action" — the bottom sheet opened by the Flashcard
/// quick action. Lists the user's tests (F1 · pick test) or, when there are
/// none, an empty state pointing to the market (F2 · empty).
class FlashcardPickerSheet extends StatefulWidget {
  const FlashcardPickerSheet({required this.loadTests, required this.onPick, required this.onGoToMarket, super.key});

  final Future<List<TestModel>> Function() loadTests;
  final ValueChanged<TestModel> onPick;
  final VoidCallback onGoToMarket;

  /// Opens the sheet; resolves once it is dismissed. The sheet closes itself
  /// before invoking [onPick] / [onGoToMarket].
  static Future<void> show(
    BuildContext context, {
    required Future<List<TestModel>> Function() loadTests,
    required ValueChanged<TestModel> onPick,
    required VoidCallback onGoToMarket,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.x.colors.transparent,
    elevation: 0,
    builder: (_) => FlashcardPickerSheet(loadTests: loadTests, onPick: onPick, onGoToMarket: onGoToMarket),
  );

  @override
  State<FlashcardPickerSheet> createState() => _FlashcardPickerSheetState();
}

class _FlashcardPickerSheetState extends State<FlashcardPickerSheet> {
  late Future<List<TestModel>> _tests;

  @override
  void initState() {
    super.initState();
    _tests = widget.loadTests();
  }

  void _retry() => setState(() => _tests = widget.loadTests());

  /// Dismiss the sheet first so the follow-up navigation lands on the screen.
  VoidCallback _closeThen(VoidCallback action) => () {
    Navigator.of(context).pop();
    action();
  };

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: Container(
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: context.x.colors.pureBlack.withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(title: l10n.homeActionFlashcard),
              const SizedBox(height: 16),
              Flexible(
                child: FutureBuilder<List<TestModel>>(
                  future: _tests,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) return const _PickerSkeleton();
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: QuizInlineError(
                          title: l10n.homeInlineErrorTitle,
                          message: l10n.homeInlineErrorBody,
                          retryLabel: l10n.homeRetry,
                          onRetry: _retry,
                        ),
                      );
                    }
                    final tests = snapshot.data ?? const <TestModel>[];
                    if (tests.isEmpty) return _EmptyContent(onGoToMarket: _closeThen(widget.onGoToMarket));
                    return _PickerList(tests: tests, onPick: (test) => _closeThen(() => widget.onPick(test))());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma "Sheet Header" — grabber + title + ghost close button.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(color: context.x.colors.sheetHandle, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(20, wBold, hc.text)),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: hc.bg, shape: BoxShape.circle),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: Padding(
                      // Figma: the glyph sits at 17.71% inset inside the 16px icon frame.
                      padding: const EdgeInsets.all(2.83),
                      child: Assets.lib.icon.closeSheet.svg(
                        package: 'ui',
                        colorFilter: ColorFilter.mode(hc.text, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickerList extends StatelessWidget {
  const _PickerList({required this.tests, required this.onPick});

  final List<TestModel> tests;
  final ValueChanged<TestModel> onPick;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tests.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(context.x.l10n.homeFlashcardPickHint, style: quizText(13, wRegular, hc.text3));
        }
        final test = tests[index - 1];
        return _PickerRow(test: test, paletteIndex: index - 1, onTap: () => onPick(test));
      },
    );
  }
}

/// Figma "Picker Row" — avatar · name/organization · card-count pill · chevron.
class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.test, required this.paletteIndex, required this.onTap});

  final TestModel test;
  final int paletteIndex;
  final VoidCallback onTap;

  static String _initials(String name) {
    final words = name
        .split(RegExp(r'[\s:,.\-–—]+'))
        .map((w) => w.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), ''))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final first = words.first.characters.first;
    final second = words.length > 1 ? words[1].characters.first : '';
    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final palette = <(Color, Color)>[
      (hc.success, hc.successTint),
      (hc.warning, hc.warningTint),
      (hc.purple, hc.purpleTint),
      (hc.teal, hc.tealTint),
    ];
    final (accent, tint) = palette[paletteIndex % palette.length];
    final name = test.name ?? '';
    final subtitle = test.universityName ?? test.categoryName ?? '';
    final count = test.questionCount ?? 0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hc.border),
        ),
        child: Row(
          children: [
            QuizInitialAvatar(
              initial: _initials(name),
              color: accent,
              background: tint,
              size: 40,
              borderWidth: 0,
              fontSize: 15,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: quizText(15, wSemibold, hc.text)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: quizText(13, wRegular, hc.text3),
                    ),
                  ],
                ],
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 12),
              QuizPill(
                text: context.x.l10n.homeFlashcardCards(count),
                background: hc.primaryTint,
                foreground: hc.primary,
              ),
            ],
            const SizedBox(width: 12),
            Text('›', style: quizText(20, wSemibold, hc.text3)),
          ],
        ),
      ),
    );
  }
}

/// Figma "F2 · Flashcard — empty" sheet content.
class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.onGoToMarket});

  final VoidCallback onGoToMarket;

  @override
  Widget build(BuildContext context) {
    final hc = context.x.homeColors;
    final l10n = context.x.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: QuizEmptyState(
        card: false,
        emoji: '🃏',
        illustrationBackground: hc.purpleTint,
        illustrationDecorations: [
          Positioned(left: 78, top: 6, child: Assets.lib.icon.flashcardDeco1.svg(package: 'ui')),
          Positioned(left: 4, top: 22, child: Assets.lib.icon.flashcardDeco2.svg(package: 'ui')),
          Positioned(left: 12, top: 78, child: Assets.lib.icon.flashcardDeco3.svg(package: 'ui')),
        ],
        title: l10n.homeFlashcardEmptyTitle,
        description: l10n.homeFlashcardEmptyDescription,
        buttonLabel: l10n.homeFlashcardGoToMarket,
        onPressed: onGoToMarket,
      ),
    );
  }
}

class _PickerSkeleton extends StatelessWidget {
  const _PickerSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: QuizShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 14, width: 240),
          for (var i = 0; i < 3; i++) ...[const SizedBox(height: 8), const ShimmerBox(height: 66, radius: 16)],
        ],
      ),
    ),
  );
}
