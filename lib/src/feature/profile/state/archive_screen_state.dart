import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/archive_cubit.dart';
import '../screen/archive_screen.dart';

abstract class ArchiveScreenState extends State<ArchiveScreen> {
  late final ScrollController scrollController;
  late final ArchiveCubit archiveCubit;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    archiveCubit = context.read<ArchiveCubit>();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      archiveCubit.loadMore();
    }
  }

  void onUnarchive(String testId) => archiveCubit.unarchiveTest(testId);
  void onDelete(String testId) => archiveCubit.deleteTest(testId);

  @override
  void dispose() {
    scrollController.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
