import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/error_util.dart';
import '../bloc/my_test_cubit.dart';
import '../models/test_model.dart';
import '../screen/my_tests_screen.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
  static bool isSessionThunderEnabled = false;
  Timer? _holdTimer;

  late final MyTestCubit myTestCubit;
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  Timer? _debounceTimer;
  var _isLoadingMore = false;

  /// Max card width for list view mode (in logical pixels).
  static const double maxCardWidth = 360;

  /// Horizontal padding (left + right) applied to the grid/list.
  static const double horizontalPadding = 32; // 16 * 2

  /// Computes the adaptive layout for the list view mode.
  ({int crossAxisCount, double mainAxisExtent}) computeListLayout(double screenWidth) {
    final availableWidth = screenWidth - horizontalPadding;
    final crossAxisCount = (availableWidth / maxCardWidth).floor().clamp(1, 10);
    const mainAxisExtent = 185.0;
    return (crossAxisCount: crossAxisCount, mainAxisExtent: mainAxisExtent);
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
    myTestCubit = context.read<MyTestCubit>()
      ..initialize()
      ..getExampleTest('a1d49775-0a29-435a-b145-93824979ab9f');
    searchController = TextEditingController()..addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final query = searchController.text.trim();
    if (query.isNotEmpty && query.length <= 3) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      myTestCubit.initialize(search: query);
    });
  }

  void _onScroll() {
    if (_isLoadingMore || !scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _isLoadingMore = true;
      myTestCubit.getTopTests(loadMore: true).whenComplete(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    searchController.dispose();
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void onBuyTestPressed(TestModel test) {
    if (test.id == 'a1d49775-0a29-435a-b145-93824979ab9f' || test.isPurchased == true) {
      context.octopus.push(Routes.testMode, arguments: <String, String>{'id': test.id?.toString() ?? ''});
    } else {
      context.octopus.push(Routes.purchaseTest, arguments: <String, String>{'id': test.id?.toString() ?? ''});
    }
  }

  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await myTestCubit.initialize(search: searchController.text);
  }

  void onShareTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      test.name ?? '',
      test.categoryName ?? '',
      test.description ?? '',
      test.price?.toString() ?? '0',
      test.questionCount?.toString() ?? '0',
      code: test.code,
    );
  }

  void onLikeTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.toggleLikeTest(test);
  }

  void onTitlePointerDown(PointerDownEvent event) {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (!isSessionThunderEnabled) {
        final appDebugSettings = context.x.dependencies.appDebugSettings;
        appDebugSettings.value = appDebugSettings.value.copyWith(debuggerEnabled: true);
      }
      _showPasswordDialog();
    });
  }

  void onTitlePointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (!isSessionThunderEnabled) {
      final appDebugSettings = context.x.dependencies.appDebugSettings;
      appDebugSettings.value = appDebugSettings.value.copyWith(debuggerEnabled: false);
    }
  }

  void onTitlePointerCancel(PointerCancelEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (!isSessionThunderEnabled) {
      final appDebugSettings = context.x.dependencies.appDebugSettings;
      appDebugSettings.value = appDebugSettings.value.copyWith(debuggerEnabled: false);
    }
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
                'Password',
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
                  hintText: 'Enter password',
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
                      child: Text('OK', style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white)),
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
      );
    } else {
      isSessionThunderEnabled = false;
      context.x.dependencies.appDebugSettings.value = context.x.dependencies.appDebugSettings.value.copyWith(
        debuggerEnabled: false,
      );
      ErrorUtil.showSnackBar(context, 'Xato parol!');
    }
  }
}
