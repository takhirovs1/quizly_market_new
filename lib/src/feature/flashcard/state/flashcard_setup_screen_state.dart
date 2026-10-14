import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../tests/bloc/test_view.dart';
import '../model/flashcard_config.dart';
import '../screens/flashcard_setup_screen.dart';

abstract class FlashcardSetupScreenState extends State<FlashcardSetupScreen> {
  late final TestView cubit;
  late final ValueNotifier<RangeValues> cardRange;
  late final ValueNotifier<bool> shuffle;
  late final ValueNotifier<FlashcardDirection> direction;

  int minCards = 0;
  int totalCards = 100;
  String testName = '';
  static const int rangeStep = 5;

  @override
  void initState() {
    super.initState();
    cubit = context.read<TestView>();
    // Seed the bounds from the already-loaded detail (if any) so the slider
    // starts on the correct full range instead of a stale 0–100.
    final detail = cubit.state.detail;
    totalCards = (detail?.questionCount ?? 0) > 0 ? detail!.questionCount! : 100;
    minCards = 0;
    if (detail?.name != null && detail!.name!.isNotEmpty) testName = detail.name!;
    cardRange = ValueNotifier<RangeValues>(RangeValues(minCards.toDouble(), totalCards.toDouble()));
    shuffle = ValueNotifier<bool>(false);
    direction = ValueNotifier<FlashcardDirection>(FlashcardDirection.questionFirst);
    _loadSavedConfig();
    context.setupTelegramBackButton(onBackPressed);
  }

  void onPressLike() {
    final detail = cubit.state.detail;
    if (detail == null) return;
    final testId = detail.id;
    if (testId == null) return;
    context.telegramWebApp.hapticImpact(.light);
    cubit.toggleLike(testId);
  }

  void onPressShare() {
    final detail = cubit.state.detail;
    if (detail == null) return;
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      detail.name ?? '',
      (detail.universityName?.isNotEmpty == true ? detail.universityName : 'QuizlyMarket') ?? 'QuizlyMarket',
      detail.description ?? '',
      detail.price?.toString() ?? '0',
      detail.questionCount?.toString() ?? '0',
      code: detail.code,
    );
  }

  Future<void> onPressArchive() async {
    final detail = cubit.state.detail;
    if (detail == null) return;
    final testId = detail.id;
    if (testId == null) return;

    final wasArchived = detail.isArchived ?? false;
    context.telegramWebApp.hapticImpact(.light);
    try {
      await cubit.toggleArchive(testId);
      if (mounted) {
        final message = wasArchived
            ? context.x.l10n.testUnarchivedSuccessfully
            : context.x.l10n.testArchivedSuccessfully;
        context.x.showNotification(
          message: message,
          isError: false,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    } on Object catch (_) {
      if (mounted) {
        context.x.showNotification(
          message: context.x.l10n.errorOccurred,
          isError: true,
          top: switch (context.telegramWebApp.isSupported) {
            true => context.telegramWebApp.safeAreaInset.top.toDouble() + 56,
            false => MediaQuery.paddingOf(context).top + 56,
          },
        );
      }
    }
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton(onBackPressed);
    cardRange.dispose();
    shuffle.dispose();
    direction.dispose();
    super.dispose();
  }

  /// Adjust the slider bounds once the test detail (question count) is known.
  /// Resets to the full deck range, mirroring the custom-mode screen.
  void onDetailLoaded(int count, {String? name}) {
    if (name != null && name.isNotEmpty) testName = name;
    if (count > 0 && count != totalCards) {
      totalCards = count;
      minCards = 0;
      cardRange.value = RangeValues(0, count.toDouble());
    }
  }

  RangeValues snapRange(RangeValues values) {
    final min = minCards.toDouble();
    final max = totalCards.toDouble();
    if (max - min < rangeStep) {
      return RangeValues(min, max);
    }

    var start = values.start.roundToDouble();
    var end = values.end.roundToDouble();

    if (end - start < rangeStep) {
      if (values.start != cardRange.value.start) {
        start = (end - rangeStep).clamp(min, max);
      } else {
        end = (start + rangeStep).clamp(min, max);
      }
    }

    return RangeValues(start.clamp(min, max), end.clamp(min, max));
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final config = FlashcardConfig.fromPrefsMap({
      'fc_rangeStart': prefs.getString('fc_rangeStart'),
      'fc_rangeEnd': prefs.getString('fc_rangeEnd'),
      'fc_shuffle': prefs.getString('fc_shuffle'),
      'fc_direction': prefs.getString('fc_direction'),
    });
    if (!mounted) return;
    // Only restore order/direction preferences. The range is test-specific
    // (depends on this test's question count), so it is always derived from
    // the loaded detail rather than a previous session's saved value.
    shuffle.value = config.shuffle;
    direction.value = config.direction;
  }

  Future<void> _saveConfig(FlashcardConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final map = config.toPrefsMap();
    for (final entry in map.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  void onBackPressed() {
    context.telegramWebApp.hapticImpact(.light);
    if (!mounted) return;
    context.octopus.pop();
  }

  FlashcardConfig _buildConfig() => FlashcardConfig(
    rangeStart: cardRange.value.start.toInt(),
    rangeEnd: cardRange.value.end.toInt(),
    shuffle: shuffle.value,
    direction: direction.value,
  );

  void onPressStart() {
    context.telegramWebApp.hapticImpact(.light);
    final config = _buildConfig();
    // Persist silently; navigation does not need to wait for prefs.
    _saveConfig(config);
    context.octopus.push(
      Routes.flashcardSession,
      arguments: <String, String>{
        'testId': widget.testId,
        if (testName.isNotEmpty) 'testName': testName,
        ...config.toArguments(),
      },
    );
  }
}
