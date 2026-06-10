import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/extension/context_extension.dart';
import '../bloc/profile_cubit.dart';
import '../screen/payment_history_screen.dart';

abstract class PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      context.read<ProfileCubit>().getTransactions(loadMore: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }
}
