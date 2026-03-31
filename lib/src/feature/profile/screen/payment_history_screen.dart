import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
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
    appBar: AppBar(
      backgroundColor: context.x.colors.primary,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: context.telegramWebApp.safeAreaInset.top + 56,
      surfaceTintColor: context.x.colors.transparent,
      title: Column(
        children: [
          SizedBox(height: context.telegramWebApp.safeAreaInset.top.toDouble()),
          Center(
            child: Text(
              'Payment History',
              style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white, fontSize: 24),
            ),
          ),
        ],
      ),
    ),
    body: const PaymentHistory(),
  );
}

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: literal_only_boolean_expressions
    if (true)
      return ListView.separated(
        padding: const .symmetric(vertical: 16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const .symmetric(horizontal: 16),
          child: Row(
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: .circular(100),
                child: Image.asset(Assets.lib.images.logo.path, width: 40, height: 40, package: Constant.packageUi),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Takhirovs', style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text)),
                  Text('23:30 12.11.2026', style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text('+1,000 UZS', style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.primary)),
                  Text(
                    context.x.l10n.referral,
                    style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        separatorBuilder: (context, index) => Padding(
          padding: const .only(left: 66),
          child: Divider(height: 20, color: context.x.colors.divider),
        ),
      );
    else
      // ignore: dead_code
      return Padding(
        padding: const .all(16),
        child: EmptyTestWidget(title: context.x.l10n.noInvitationsYet, description: context.x.l10n.referralInfo),
      );
  }
}
