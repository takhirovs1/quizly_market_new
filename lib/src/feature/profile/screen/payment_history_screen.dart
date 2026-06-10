import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/util/state_status.dart';
import '../bloc/profile_cubit.dart';
import '../state/payment_history_screen_state.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends PaymentHistoryScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    resizeToAvoidBottomInset: false,
    appBar: QuizAppBar(
      title: context.x.l10n.paymentHistory,
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
    ),
    body: PaymentHistory(scrollController: scrollController),
  );
}

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({required this.scrollController, super.key});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    builder: (context, state) {
      switch (state.status) {
        case StateStatus.idle:
        case StateStatus.loading:
          return const Center(child: CircularProgressIndicator.adaptive());
        case StateStatus.noInternetConnection:
        case StateStatus.error:
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Xatolik yuz berdi',
                    style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => context.read<ProfileCubit>().getTransactions(),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          );
        case StateStatus.success:
        case StateStatus.loadingMore:
          if (state.transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyTestWidget(title: context.x.l10n.noInvitationsYet, description: context.x.l10n.referralInfo),
            );
          }
          final listCount = state.transactions.length + (state.status == StateStatus.loadingMore ? 1 : 0);
          return ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: listCount,
            itemBuilder: (context, index) {
              if (index >= state.transactions.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }
              final transaction = state.transactions[index];
              final isPositive = transaction.amount >= 0;
              final amountText = isPositive
                  ? '+${transaction.amount.formatUzs}'
                  : '-${transaction.amount.abs().formatUzs}';

              // Format time & date
              final hour = transaction.createdAt.hour.toString().padLeft(2, '0');
              final minute = transaction.createdAt.minute.toString().padLeft(2, '0');
              final day = transaction.createdAt.day.toString().padLeft(2, '0');
              final month = transaction.createdAt.month.toString().padLeft(2, '0');
              final year = transaction.createdAt.year;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 10,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        Assets.lib.images.logo.path,
                        width: 40,
                        height: 40,
                        package: Constant.packageUi,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$hour:$minute $day.$month.$year',
                            style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountText,
                          style: context.x.textStyle.sfW700s18.copyWith(
                            color: isPositive ? context.x.colors.primary : context.x.colors.error,
                          ),
                        ),
                        Text(
                          transaction.type,
                          style: context.x.textStyle.sfW400s14.copyWith(
                            color: isPositive ? context.x.colors.primary : context.x.colors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 66),
              child: Divider(height: 20, color: context.x.colors.divider),
            ),
          );
      }
    },
  );
}
