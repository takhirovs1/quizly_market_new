import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../../../common/util/helpers.dart';
import '../../home/screen/home_screen.dart';
import '../../sessions/data/session_repository.dart';
import '../../sessions/widget/mistakes_picker_sheet.dart';
import '../../sessions/widget/random_test_sheet.dart';
import '../bloc/my_test_cubit.dart';
import '../models/home/ads_model.dart';
import '../models/home/home_continue_model.dart';
import '../models/home/home_enums.dart';
import '../models/home/my_tests_preview_model.dart';
import '../models/home/recommendations_model.dart';
import '../models/test_model.dart';
import '../screen/my_tests_screen.dart';
import '../widgets/home/flashcard_picker_sheet.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
  /// The free example test (reused from the existing demo flow).
  static const String exampleTestId = 'a1d49775-0a29-435a-b145-93824979ab9f';

  static bool isSessionThunderEnabled = false;

  late final MyTestCubit myTestCubit;
  late final ScrollController scrollController;

  /// Selected status for the "Mening testlarim" chips. `null` = "Barchasi".
  /// Local, view-only filter over the loaded preview — tapping a chip never
  /// navigates (the full list is reached via the "Barchasi ›" header link).
  final ValueNotifier<MyTestStatus?> myTestsFilterNotifier = ValueNotifier<MyTestStatus?>(null);

  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    myTestCubit = context.read<MyTestCubit>()
      ..loadHome()
      ..getExampleTest(exampleTestId);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    scrollController.dispose();
    myTestsFilterNotifier.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await myTestCubit.loadHome();
    await myTestCubit.getExampleTest(exampleTestId);
  }

  void onRetrySection(String sectionKey) => myTestCubit.retrySection(sectionKey);

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _openPurchasedTest(String id) => context.octopus.push(Routes.testMode, arguments: <String, String>{'id': id});

  void _openMarketTest(String id) => context.octopus.push(Routes.purchaseTest, arguments: <String, String>{'id': id});

  void onContinue(ContinueCardData card) {
    context.telegramWebApp.hapticImpact(.light);
    // The Continue hero is a test/exam/flashcard attempt (random/mistakes
    // sessions are never surfaced here), so resuming re-opens the test's mode.
    _openPurchasedTest(card.testId);
  }

  void onOpenPreviewTest(MyTestPreviewItem item) => _openPurchasedTest(item.testId);

  void onExampleStart() {
    context.telegramWebApp.hapticImpact(.light);
    _openPurchasedTest(exampleTestId);
  }

  void onGoToMarket() {
    // Switch the bottom-nav to the Market tab (RecommendationScreen = index 1).
    final home = HomeScreen.maybeOf(context);
    if (home != null) {
      home.onTap(1);
    } else {
      context.octopus.push(Routes.moreRecommendation, arguments: <String, String>{'type': 'topTests'});
    }
  }

  void onSeeAllMyTests() => context.octopus.push(Routes.allTests);

  /// Select a "Mening testlarim" status chip. Toggling the active chip clears
  /// back to "Barchasi". Local filter only — no navigation.
  void onMyTestsFilter(MyTestStatus? status) {
    context.telegramWebApp.hapticImpact(.light);
    myTestsFilterNotifier.value = myTestsFilterNotifier.value == status ? null : status;
  }

  // ── Actions row ────────────────────────────────────────────────────────────
  /// Figma "D · Random test flow": pick 10/20/30 questions in a sheet, then run
  /// a `random` session over all purchased tests. Locked state leads to market.
  void onRandomTest() {
    context.telegramWebApp.hapticImpact(.light);
    showRandomTestSheet(
      context,
      hasPurchased: myTestCubit.state.homeActions?.hasPurchasedTests ?? false,
      onStart: (count) =>
          context.octopus.push(Routes.sessionRun, arguments: <String, String>{'mode': 'random', 'count': '$count'}),
      onGoToMarket: onGoToMarket,
    );
  }

  /// Figma "E · Mistakes flow": pick all mistakes or one test's in a sheet, then
  /// run a `mistakes` session. Empty state when there is nothing to practise.
  void onMistakes() {
    context.telegramWebApp.hapticImpact(.light);
    showMistakesPickerSheet(
      context,
      repository: SessionRepositoryImpl(apiClient: context.x.dependencies.apiClient),
      onStart: (testId) =>
          context.octopus.push(Routes.sessionRun, arguments: <String, String>{'mode': 'mistakes', 'testId': ?testId}),
      onGoToMarket: onGoToMarket,
    );
  }

  /// Figma "F · Flashcard action": pick one of the user's tests in a sheet,
  /// then continue into the existing flashcard setup for it. With no tests the
  /// sheet shows an empty state that leads to the market.
  void onFlashcard() {
    context.telegramWebApp.hapticImpact(.light);
    FlashcardPickerSheet.show(
      context,
      loadTests: _loadFlashcardTests,
      onPick: (test) {
        context.telegramWebApp.hapticImpact(.light);
        context.octopus.push(Routes.testFlashcardMode, arguments: <String, String>{'id': test.id ?? ''});
      },
      onGoToMarket: onGoToMarket,
    );
  }

  Future<List<TestModel>> _loadFlashcardTests() async {
    final result = await myTestCubit.myTestRepository.getMyTests(TestModelRequest(limit: 50, offset: 0));
    return result.items.where((t) => (t.id ?? '').isNotEmpty).toList();
  }

  // ── Friends ──────────────────────────────────────────────────────────────────
  /// The friends card's invite CTA opens the Friends screen, where the user
  /// manages requests, search, leaderboard and groups.
  void onOpenFriends() {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(
      Routes.friends,
      arguments: <String, String>{'code': myTestCubit.state.referralSummary?.inviteCode ?? ''},
    );
  }

  /// The friends card's "Reyting ›" opens the full weekly XP leaderboard
  /// (Figma "G5 · Leaderboard", Do‘stlar / Umumiy tabs).
  void onOpenLeaderboard() {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(Routes.leaderboard);
  }

  // ── Referral ─────────────────────────────────────────────────────────────────
  /// Tapping the referral card body opens the full referral screen.
  void onOpenReferral() {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(Routes.referral);
  }

  /// The referral card's "Ulashish" button shares the referral deep link.
  void onShareReferral() {
    context.telegramWebApp.hapticImpact(.light);
    final code = myTestCubit.state.referralSummary?.inviteCode ?? '';
    context.shareReferral(code);
  }

  /// Claim one referred friend's bonus; shows the server toast on success.
  Future<void> onClaimReferral(String friendId) async {
    context.telegramWebApp.hapticImpact(.light);
    final rewardText = await myTestCubit.claimReferralFriend(friendId);
    if (!mounted) return;
    if (rewardText != null && rewardText.isNotEmpty) {
      ErrorUtil.showSnackBar(context, rewardText);
    }
  }

  // ── Ads ────────────────────────────────────────────────────────────────────
  void onAdTap(AdItem ad) {
    myTestCubit.trackAdClick(ad.id);
    if (ad.ctaUrl.isNotEmpty) Helpers.launchUrl(ad.ctaUrl);
  }

  void onAdDismiss(AdItem ad) {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.dismissAd(ad.id);
  }

  void onAdImpression(AdItem ad) => myTestCubit.trackAdImpression(ad.id);

  // ── Recommendations ────────────────────────────────────────────────────────
  void onRecommendationTap(RecommendationItem item) => _openMarketTest(item.testId);

  void onToggleFavorite(RecommendationItem item) {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.toggleRecommendationFavorite(item.testId);
  }

  void onOpenRating(String testId, {String name = '', String organizationName = ''}) {
    context.telegramWebApp.hapticImpact(.light);
    context.octopus.push(
      Routes.testRating,
      arguments: <String, String>{'id': testId, 'name': name, 'org': organizationName},
    );
  }

  // ── Debug: title interactions ──────────────────────────────────────────────
  // Holding the title for 5s opens the engineer password dialog.
  void onTitlePointerDown(PointerDownEvent event) {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showPasswordDialog();
    });
  }

  void onTitlePointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void onTitlePointerCancel(PointerCancelEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _showPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: context.x.colors.dialogBackground,
        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(16))),
        child: Padding(
          padding: const .all(20),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(
                context.x.l10n.password,
                textAlign: .center,
                style: context.x.textStyle.sfW700s28.copyWith(fontSize: 20, color: context.x.colors.dialogText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                keyboardType: .number,
                cursorColor: context.x.colors.primary,
                style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.dialogText),
                decoration: InputDecoration(
                  hintText: context.x.l10n.enterPassword,
                  hintStyle: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.bannerSecondaryText),
                  filled: true,
                  fillColor: context.x.colors.textFieldBackground,
                  contentPadding: const .symmetric(horizontal: 16, vertical: 14),
                  border: const OutlineInputBorder(borderRadius: .all(.circular(12)), borderSide: .none),
                  enabledBorder: const OutlineInputBorder(borderRadius: .all(.circular(12)), borderSide: .none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const .all(.circular(12)),
                    borderSide: BorderSide(color: context.x.colors.primary, width: 1.5),
                  ),
                ),
                onSubmitted: (_) => _submitPassword(dialogContext, passwordController.text),
              ),
              const SizedBox(height: 20),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: context.x.colors.transparent,
                        surfaceTintColor: context.x.colors.transparent,
                        backgroundColor: context.x.colors.dialogCancelButton,
                        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
                        padding: const .symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        context.x.l10n.cancel,
                        style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.bannerPriceText),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: context.x.colors.transparent,
                        surfaceTintColor: context.x.colors.transparent,
                        backgroundColor: context.x.colors.primary,
                        shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
                        padding: const .symmetric(vertical: 14),
                      ),
                      onPressed: () => _submitPassword(dialogContext, passwordController.text),
                      child: Text(
                        context.x.l10n.ok,
                        style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPassword(BuildContext dialogContext, String rawPassword) {
    final password = rawPassword.trim();
    Navigator.of(dialogContext).pop();
    if (password == '0510') {
      isSessionThunderEnabled = true;
      context.x.dependencies.appDebugSettings.value = context.x.dependencies.appDebugSettings.value.copyWith(
        debuggerEnabled: true,
        thunderEnabled: true,
      );
    } else {
      isSessionThunderEnabled = false;
      context.x.dependencies.appDebugSettings.value = context.x.dependencies.appDebugSettings.value.copyWith(
        debuggerEnabled: false,
        thunderEnabled: false,
      );
      ErrorUtil.showSnackBar(context, context.x.l10n.wrongPassword);
    }
  }
}
