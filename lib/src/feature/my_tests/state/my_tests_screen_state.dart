import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/my_test_cubit.dart';
import '../screen/my_tests_screen.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
  late final MyTestCubit myTestCubit;
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    myTestCubit = context.read<MyTestCubit>()..initialize(limit: 5);
    searchController = TextEditingController()..addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final query = searchController.text.trim();
    if (query.isNotEmpty && query.length <= 3) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      myTestCubit.initialize(search: query, limit: 5);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  void onBuyTestPressed() => context.octopus.push(Routes.purchaseTest);
  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(TelegramHapticImpact.light);
    await myTestCubit.initialize(search: searchController.text, limit: 5);
  }

  void onShareTestPressed() {
    context.telegramWebApp.hapticImpact(TelegramHapticImpact.light);
    context.shareTest(
      'Example test',
      'QuizlyMarket',
      'Example test description, Example test description, Example test description',
      '100000',
      '100',
    );
  }
}
