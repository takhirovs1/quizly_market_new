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

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
    myTestCubit = context.read<MyTestCubit>()..initialize();
  }

  var _isLoadingMore = false;

  void _onScroll() {
    if (_isLoadingMore || !scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _isLoadingMore = true;
      myTestCubit.state.myTests.isNotEmpty
          ? myTestCubit.getMyTests(loadMore: true)
          : myTestCubit.getTopTests(loadMore: true).whenComplete(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onBuyTestPressed() => context.octopus.push(Routes.purchaseTest);
  Future<void> onRefresh() async {
    context.telegramWebApp.hapticImpact(.light);
    await myTestCubit.initialize();
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
}
