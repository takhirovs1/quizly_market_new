import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/my_test_cubit.dart';
import '../models/test_model.dart';
import '../screen/my_tests_screen.dart';

abstract class MyTestsScreenState extends State<MyTestsScreen> {
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
    myTestCubit = context.read<MyTestCubit>()..initialize();
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

  void onBuyTestPressed(TestModel test) =>
      context.octopus.push(Routes.purchaseTest, arguments: <String, String>{'id': test.id?.toString() ?? ''});
  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await myTestCubit.initialize(search: searchController.text);
  }

  void onShareTestPressed() {
    context.telegramWebApp.hapticImpact(.light);
    context.shareTest(
      'Example test',
      'QuizlyMarket',
      'Example test description, Example test description, Example test description',
      '100000',
      '100',
    );
  }

  void onLikeTestPressed(TestModel test) {
    context.telegramWebApp.hapticImpact(.light);
    myTestCubit.toggleLikeTest(test);
  }
}
