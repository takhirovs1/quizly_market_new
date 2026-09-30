import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
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
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile;

    Widget buildContent() => BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) => switch (state.status) {
        StateStatus.idle || StateStatus.loading => const _PaymentHistoryShimmer(),
        StateStatus.noInternetConnection || StateStatus.error => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? context.x.l10n.errorOccurred,
                  style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => context.read<ProfileCubit>().getTransactions(),
                  child: Text(context.x.l10n.retry),
                ),
              ],
            ),
          ),
        ),
        StateStatus.success || StateStatus.loadingMore =>
          state.transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyTestWidget(
                    title: context.x.l10n.noInvitationsYet,
                    description: context.x.l10n.referralInfo,
                  ),
                )
              : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.transactions.length + (state.status == StateStatus.loadingMore ? 1 : 0),
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
                    final amountText = '${isPositive ? '+' : '-'}$amountFormatted ${context.x.l10n.uzs}';

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
                    final isPurchase = transaction.type == 'purchase';
                    final isSpend = transaction.type == 'spend';

                    var titleText = transaction.title;
                    if (isPurchase || isSpend) {
                      titleText = transaction.testName ?? transaction.title;
                    } else if (isPayme) {
                      titleText = context.x.l10n.payme;
                    } else if (isClick) {
                      titleText = context.x.l10n.clickSuperApp;
                    } else if (isReferral) {
                      if (titleLower.contains('referral') && titleText.contains(':')) {
                        titleText = titleText.split(':').last.trim();
                      }
                    }

                    final (statusText, statusColor) = switch (transaction.type) {
                      'referral' => (context.x.l10n.referralLabel, context.x.colors.primary),
                      'refund' => (context.x.l10n.refundLabel, Colors.orange.shade600),
                      _ when isPositive => (context.x.l10n.incomeLabel, context.x.colors.success),
                      _ => (context.x.l10n.expenseLabel, isPremium ? Colors.orange.shade600 : context.x.colors.error),
                    };

                    Widget leadingIcon;
                    if (isPayme) {
                      leadingIcon = Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: context.x.colors.primary, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Assets.lib.images.payme.image(package: 'ui', fit: BoxFit.cover),
                        ),
                      );
                    } else if (isClick) {
                      leadingIcon = Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: context.x.colors.primary, width: 1.5),
                        ),
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
                ),
      },
    );

    return Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      resizeToAvoidBottomInset: false,
      appBar: QuizAppBar(
        title: context.x.l10n.paymentHistory,
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? MediaQuery.sizeOf(context).width - 40 : 560,
                child: CustomButton(onTap: openPayment, title: context.x.l10n.topUpBalance),
              ),
            ],
          ),
        ),
      ),
      body: isMobile
          ? buildContent()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.x.colors.cardBackground2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.x.colors.divider),
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(20), child: buildContent()),
                ),
              ),
            ),
    );
  }
}

class _PaymentHistoryShimmer extends StatelessWidget {
  const _PaymentHistoryShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0x20FFFFFF) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0x40FFFFFF) : const Color(0xFFF1F5F9),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 8,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 72),
          child: Divider(height: 20, color: context.x.colors.divider),
        ),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Circular icon placeholder
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              const SizedBox(width: 12),
              // Title and Date/Time placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 140,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount and Status placeholders
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 80,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
