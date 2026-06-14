// payment_history_screen_state.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../../common/util/app_enum.dart';
import '../bloc/profile_cubit.dart';
import '../model/transaction_model.dart';
import '../screen/payment_history_screen.dart';

class TransactionUiData {
  TransactionUiData({
    required this.title,
    required this.amount,
    required this.date,
    required this.statusText,
    required this.statusColor,
    required this.leadingIcon,
  });

  final String title;
  final String amount;
  final String date;
  final String statusText;
  final Color statusColor;
  final Widget leadingIcon;
}

abstract class PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
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
      profileCubit.getTransactions(loadMore: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    context.teardownTelegramBackButton();
    super.dispose();
  }

  TransactionUiData getTransactionUiData(BuildContext context, Transaction transaction) {
    final isPositive = transaction.amount >= 0;
    final amountFormatted = transaction.amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final amountText = '${isPositive ? '+' : '-'}$amountFormatted UZS';

    final hour = transaction.createdAt.hour.toString().padLeft(2, '0');
    final minute = transaction.createdAt.minute.toString().padLeft(2, '0');
    final day = transaction.createdAt.day.toString().padLeft(2, '0');
    final month = transaction.createdAt.month.toString().padLeft(2, '0');
    final year = transaction.createdAt.year;
    final dateText = '$hour:$minute $day.$month.$year';

    final titleLower = transaction.title.toLowerCase();
    final type = switch (transaction) {
      _ when transaction.provider == 'payme' || titleLower.contains('payme') => TransactionDisplayType.payme,
      _ when transaction.provider == 'click' || titleLower.contains('click') => TransactionDisplayType.click,
      _ when transaction.type == 'referral' => TransactionDisplayType.referral,
      _ when titleLower.contains('premium') => TransactionDisplayType.premium,
      _ => TransactionDisplayType.other,
    };

    final titleText = switch (transaction.type) {
      'purchase' || 'spend' => transaction.testName ?? transaction.title,
      _ => switch (type) {
        TransactionDisplayType.payme => 'Payme',
        TransactionDisplayType.click => 'Click',
        TransactionDisplayType.referral =>
          (titleLower.contains('referral') && transaction.title.contains(':'))
              ? transaction.title.split(':').last.trim()
              : transaction.title,
        _ => transaction.title,
      },
    };

    final statusText = switch (transaction.type) {
      'referral' => context.x.l10n.referralLabel,
      'refund' => context.x.l10n.refundLabel,
      _ => isPositive ? context.x.l10n.incomeLabel : context.x.l10n.expenseLabel,
    };

    final statusColor = switch (transaction.type) {
      'referral' => context.x.colors.primary,
      'refund' => context.x.colors.error,
      _ =>
        isPositive
            ? context.x.colors.success
            : (type == TransactionDisplayType.premium ? context.x.colors.orange : context.x.colors.error),
    };

    final leadingIcon = switch (type) {
      TransactionDisplayType.payme => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.x.colors.primary, width: 1),
        ),
        child: ClipOval(
          child: Assets.lib.images.payme.image(package: 'ui', fit: BoxFit.cover),
        ),
      ),
      TransactionDisplayType.click => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.x.colors.divider),
        ),
        child: ClipOval(
          child: Assets.lib.images.click.image(package: 'ui', fit: BoxFit.cover),
        ),
      ),
      TransactionDisplayType.referral => Container(
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
      ),
      TransactionDisplayType.premium => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.x.colors.orange, width: 1.5),
          color: context.x.colors.orange.withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: Assets.lib.icon.strong.svg(
          package: 'ui',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(context.x.colors.orange, BlendMode.srcIn),
        ),
      ),
      _ => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.x.colors.primary, width: 1),
          color: context.x.colors.primary.withValues(alpha: 0.1),
        ),
        alignment: Alignment.center,
        child: Assets.lib.icon.fileIcon.svg(
          package: 'ui',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(context.x.colors.primary, BlendMode.srcIn),
        ),
      ),
    };

    return TransactionUiData(
      title: titleText,
      amount: amountText,
      date: dateText,
      statusText: statusText,
      statusColor: statusColor,
      leadingIcon: leadingIcon,
    );
  }

  void openPayment() => context.octopus.pushReplacement(Routes.payment);
}
