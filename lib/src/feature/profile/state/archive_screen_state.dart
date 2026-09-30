import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/profile_cubit.dart';
import '../screen/archive_screen.dart';

abstract class ArchiveScreenState extends State<ArchiveScreen> {
  late final ScrollController scrollController;
  late final ProfileCubit profileCubit;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    profileCubit = context.read<ProfileCubit>();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      profileCubit.loadMoreArchiveTests();
    }
  }

  void onUnarchive(String testId) => profileCubit.unarchiveTest(testId);
  void onDelete(String testId) => profileCubit.deleteArchiveTest(testId);

  @override
  void dispose() {
    scrollController.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
