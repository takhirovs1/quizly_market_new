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
    myTestCubit = context.read<MyTestCubit>()
      ..getMyTests()
      ..getTopTests();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      myTestCubit.getTopTests(loadMore: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onBuyTestPressed() => context.octopus.push(Routes.purchaseTest);
  Future<void> onRefresh() async {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    await Future.wait([myTestCubit.getMyTests(), myTestCubit.getTopTests()]);
  }

  void onShareTestPressed() {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
  }
}
