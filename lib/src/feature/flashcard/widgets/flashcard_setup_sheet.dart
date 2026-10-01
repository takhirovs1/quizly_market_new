import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../feature/tests/widgets/test_title_box_widget.dart';
import '../model/flashcard_config.dart';

class FlashcardSetupSheet extends StatefulWidget {
  const FlashcardSetupSheet({required this.onStart, super.key});

  final void Function(FlashcardConfig config) onStart;

  static Future<void> show(
    BuildContext context, {
    required void Function(FlashcardConfig) onStart,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FlashcardSetupSheet(onStart: onStart),
  );

  @override
  State<FlashcardSetupSheet> createState() => _FlashcardSetupSheetState();
}

class _FlashcardSetupSheetState extends State<FlashcardSetupSheet> {
  int? _selectedCount;
  bool _shuffle = false;
  FlashcardDirection _direction = FlashcardDirection.questionFirst;
  FlashcardMode _mode = FlashcardMode.study;

  static const _countOptions = [10, 20, 50];

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final config = FlashcardConfig.fromPrefsMap({
      'fc_cardCount': prefs.getString('fc_cardCount'),
      'fc_shuffle': prefs.getString('fc_shuffle'),
      'fc_direction': prefs.getString('fc_direction'),
      'fc_mode': prefs.getString('fc_mode'),
    });
    if (mounted) {
      setState(() {
        _selectedCount = config.cardCount;
        _shuffle = config.shuffle;
        _direction = config.direction;
        _mode = config.mode;
      });
    }
  }

  Future<void> _saveConfig(FlashcardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final map = config.toPrefsMap();
    for (final entry in map.entries) {
      await prefs.setString(entry.key, entry.value);
    }
    if (config.cardCount == null) {
      await prefs.remove('fc_cardCount');
    }
  }

  void _onStart() {
    final config = FlashcardConfig(
      cardCount: _selectedCount,
      shuffle: _shuffle,
      direction: _direction,
      mode: _mode,
    );
    _saveConfig(config);
    context.bottomSheetPop();
    widget.onStart(config);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyles = context.x.textStyle;
    final bottomPad = MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.bottomSheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.gray.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.x.l10n.flashcardSetupTitle,
            style: textStyles.sfW500s22,
          ),
          const SizedBox(height: 24),

          // Card count
          Text(
            context.x.l10n.flashcardCardCountPrompt,
            style: textStyles.sfW400s14.copyWith(color: colors.gray),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final count in _countOptions)
                TestTitleBoxWidget(
                  title: '$count ta',
                  isSelected: _selectedCount == count,
                  onPressed: () => setState(() => _selectedCount = count),
                ),
              TestTitleBoxWidget(
                title: context.x.l10n.flashcardAllCards,
                isSelected: _selectedCount == null,
                onPressed: () => setState(() => _selectedCount = null),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Shuffle
          Text(
            context.x.l10n.flashcardShufflePrompt,
            style: textStyles.sfW400s14.copyWith(color: colors.gray),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TestTitleBoxWidget(
                title: context.x.l10n.flashcardShuffle,
                isSelected: _shuffle,
                onPressed: () => setState(() => _shuffle = true),
              ),
              TestTitleBoxWidget(
                title: context.x.l10n.flashcardOriginalOrder,
                isSelected: !_shuffle,
                onPressed: () => setState(() => _shuffle = false),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Direction
          Text(
            context.x.l10n.flashcardDirectionPrompt,
            style: textStyles.sfW400s14.copyWith(color: colors.gray),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TestTitleBoxWidget(
                title: context.x.l10n.flashcardQuestionFirst,
                isSelected: _direction == .questionFirst,
                onPressed: () => setState(() => _direction = .questionFirst),
              ),
              TestTitleBoxWidget(
                title: context.x.l10n.flashcardAnswerFirst,
                isSelected: _direction == .answerFirst,
                onPressed: () => setState(() => _direction = .answerFirst),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mode
          Text(
            context.x.l10n.flashcardModePrompt,
            style: textStyles.sfW400s14.copyWith(color: colors.gray),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: context.x.l10n.flashcardStudyMode,
                  isSelected: _mode == .study,
                  onTap: () => setState(() => _mode = .study),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeButton(
                  label: context.x.l10n.flashcardTestMode,
                  isSelected: _mode == .test,
                  onTap: () => setState(() => _mode = .test),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          CustomButton(
            onTap: _onStart,
            title: context.x.l10n.flashcardStartButton,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.textFieldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.x.textStyle.sfW500s14.copyWith(
            color: isSelected ? Colors.white : colors.text,
          ),
        ),
      ),
    );
  }
}
