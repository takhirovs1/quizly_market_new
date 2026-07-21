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
  int _titleTapCount = 0;
  DateTime? _lastTitleTapTime;

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
    if (!isSessionThunderEnabled) {
      final appDebugSettings = context.x.dependencies.appDebugSettings;
      appDebugSettings.value = appDebugSettings.value.copyWith(debuggerEnabled: true);
    }

    final now = DateTime.now();
    if (_lastTitleTapTime != null && now.difference(_lastTitleTapTime!) < const Duration(milliseconds: 500)) {
      _titleTapCount++;
    } else {
      _titleTapCount = 1;
    }
    _lastTitleTapTime = now;

    if (_titleTapCount >= 10) {
      _titleTapCount = 0;
      _showPasswordDialog();
    }
  }

  void onTitlePointerUp(PointerUpEvent event) {
    if (!isSessionThunderEnabled) {
      final appDebugSettings = context.x.dependencies.appDebugSettings;
      appDebugSettings.value = appDebugSettings.value.copyWith(debuggerEnabled: false);
    }
  }

  void onTitlePointerCancel(PointerCancelEvent event) {
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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.x.colors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Password',
          style: context.x.textStyle.nunitoW600s24.copyWith(color: context.x.colors.white, fontSize: 20),
        ),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: context.x.textStyle.w500s16.copyWith(color: context.x.colors.white),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: context.x.textStyle.w500s16.copyWith(color: context.x.colors.secondary),
            filled: true,
            fillColor: context.x.colors.textFieldBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onSubmitted: (_) => _submitPassword(dialogContext, passwordController.text),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text(context.x.l10n.cancel, style: TextStyle(color: context.x.colors.secondary)),
          ),
          ElevatedButton(
            onPressed: () => _submitPassword(dialogContext, passwordController.text),
            child: const Text('OK'),
          ),
        ],
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
