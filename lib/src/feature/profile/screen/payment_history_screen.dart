import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
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
    body: BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        switch (state.status) {
          case .idle:
          case .loading:
            return const Center(child: CircularProgressIndicator.adaptive());
          case .noInternetConnection:
          case .error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: .min,
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
                child: EmptyTestWidget(
                  title: context.x.l10n.noInvitationsYet,
                  description: context.x.l10n.referralInfo,
                ),
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
                final amountFormatted = transaction.amount.abs().toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (match) => '${match[1]},',
                );
                final amountText = '${isPositive ? '+' : '-'}$amountFormatted UZS';

                // Format time & date
                final hour = transaction.createdAt.hour.toString().padLeft(2, '0');
                final minute = transaction.createdAt.minute.toString().padLeft(2, '0');
                final day = transaction.createdAt.day.toString().padLeft(2, '0');
                final month = transaction.createdAt.month.toString().padLeft(2, '0');
                final year = transaction.createdAt.year;

                final titleLower = transaction.title.toLowerCase();
                final isPayme = transaction.provider == 'payme' || titleLower.contains('payme');
                final isClick = transaction.provider == 'click' || titleLower.contains('click');
                final isReferral = transaction.type == 'referral';
                final isPremium = titleLower.contains('premium');

                String titleText = transaction.title;
                if (isPayme) {
                  titleText = 'Payme';
                } else if (isClick) {
                  titleText = 'Click';
                } else if (isReferral) {
                  if (titleLower.contains('referral') && titleText.contains(':')) {
                    titleText = titleText.split(':').last.trim();
                  }
                }

                String statusText;
                Color statusColor;
                if (isReferral) {
                  statusText = context.x.l10n.referralLabel;
                  statusColor = context.x.colors.primary;
                } else if (isPositive) {
                  statusText = context.x.l10n.incomeLabel;
                  statusColor = Colors.green.shade600;
                } else {
                  statusText = context.x.l10n.expenseLabel;
                  statusColor = isPremium ? Colors.orange.shade600 : context.x.colors.error;
                }

                Widget leadingIcon;
                if (isPayme) {
                  leadingIcon = Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Assets.lib.images.payme.image(package: 'ui', fit: BoxFit.cover),
                    ),
                  );
                } else if (isClick) {
                  leadingIcon = Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Assets.lib.images.click.image(package: 'ui', fit: BoxFit.cover),
                    ),
                  );
                } else if (isReferral) {
                  leadingIcon = Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.x.colors.textFieldBackground),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Assets.lib.icon.person.svg(
                        package: 'ui',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(context.x.colors.primary, BlendMode.srcIn),
                      ),
                    ),
                  );
                } else if (isPremium) {
                  leadingIcon = Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange.shade600, width: 1.5),
                      color: Colors.orange.shade50,
                    ),
                    alignment: Alignment.center,
                    child: Assets.lib.icon.strong.svg(
                      package: 'ui',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(Colors.orange.shade600, BlendMode.srcIn),
                    ),
                  );
                } else {
                  leadingIcon = Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.x.colors.primary, width: 1.5),
                      color: context.x.colors.primary.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Assets.lib.icon.fileIcon.svg(
                      package: 'ui',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(context.x.colors.primary, BlendMode.srcIn),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      leadingIcon,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText,
                              style: context.x.textStyle.sfW600s16.copyWith(
                                color: context.x.colors.text,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
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
                          Text(amountText, style: context.x.textStyle.sfW700s18.copyWith(color: statusColor)),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: context.x.textStyle.sfW500s14.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Divider(height: 20, color: context.x.colors.divider),
              ),
            );
        }
      },
    ),
  );
}
