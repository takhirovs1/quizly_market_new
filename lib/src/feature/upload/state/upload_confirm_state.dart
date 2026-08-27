import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../../my_tests/models/demo_test_model.dart';
import '../../my_tests/models/payment_model.dart';
import '../screen/upload_confirm_screen.dart';

abstract class UploadConfirmState extends State<UploadConfirmScreen> {
  late final ValueNotifier<int> currentPage;
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final List<PaymentModel> paymentMethods;
  bool _isInitialized = false;
  bool isSubmitting = false;

  late final List<DemoQuestion> questions;

  @override
  void initState() {
    super.initState();
    currentPage = ValueNotifier<int>(0);

    questions = const [
      DemoQuestion(
        id: '1',
        text: "1. O'zbekiston qachon davlat mustaqilligini e'lon qilgan?",
        position: 1,
        options: [
          DemoOption(id: 'a', text: '1990-yil 20-iyun', position: 1),
          DemoOption(id: 'b', text: '1990-yil 20-iyun', position: 2),
          DemoOption(id: 'c', text: '1990-yil 20-iyun', position: 3),
          DemoOption(id: 'd', text: '1990-yil 20-iyun', position: 4),
        ],
      ),
      DemoQuestion(
        id: '2',
        text: "2. O'zbekiston Respublikasi Konstitutsiyasi qachon qabul qilingan?",
        position: 2,
        options: [
          DemoOption(id: 'a', text: '1992-yil 8-dekabr', position: 1),
          DemoOption(id: 'b', text: '1991-yil 1-sentabr', position: 2),
          DemoOption(id: 'c', text: '1993-yil 2-iyul', position: 3),
          DemoOption(id: 'd', text: '1990-yil 20-iyun', position: 4),
        ],
      ),
      DemoQuestion(
        id: '3',
        text: '3. Amir Temur tavallud topgan shahar qaysi?',
        position: 3,
        options: [
          DemoOption(id: 'a', text: 'Kesh (Shahrisabz)', position: 1),
          DemoOption(id: 'b', text: 'Samarqand', position: 2),
          DemoOption(id: 'c', text: 'Buxoro', position: 3),
          DemoOption(id: 'd', text: 'Toshkent', position: 4),
        ],
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      paymentMethods = [
        PaymentModel(
          id: 0,
          title: '340 000 UZS',
          subtitle: context.x.l10n.quizlyMarketCard,
          icon: Assets.lib.images.robot.path,
          type: .card,
        ),
        PaymentModel(id: 1, title: context.x.l10n.payme, icon: Assets.lib.images.payme2.path, type: .provider),
        PaymentModel(id: 2, title: context.x.l10n.clickSuperApp, icon: Assets.lib.images.click2.path, type: .provider),
      ];
      selectedPayment = ValueNotifier(paymentMethods[0]);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    currentPage.dispose();
    selectedPayment.dispose();
    super.dispose();
  }

  void onReportError() {
    context.octopus.push(Routes.supportChat);
  }

  Future<void> onSwitchPaymentPressed() async {
    context.telegramWebApp.hapticImpact(.light);
    final result = await showModalBottomSheet<PaymentModel>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        builder: (context, scrollController) => BottomSheetView(
          isCenterTitle: false,
          onClose: () => Navigator.pop(ctx),
          title: context.x.l10n.selectPaymentType,
          child: Padding(
            padding: const .symmetric(horizontal: 14, vertical: 16),
            child: ValueListenableBuilder<PaymentModel>(
              valueListenable: selectedPayment,
              builder: (context, isSelected, child) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      context.x.l10n.currentPaymentType,
                      style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    PaymentCard(
                      hasShadow: true,
                      imagePadding: isSelected.id != 0
                          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5)
                          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                      title: isSelected.title,
                      subtitle: isSelected.subtitle,
                      image: Image.asset(isSelected.icon, package: 'ui', width: isSelected.type == .card ? 44 : 54),
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.x.l10n.paymentViaProvider,
                      style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18),
                    ),
                    for (final payment in paymentMethods.where((e) => e.id != isSelected.id && e.id != 0))
                      Padding(
                        padding: const .only(bottom: 8),
                        child: PaymentCard(
                          hasShadow: true,
                          imagePadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16.5),
                          title: payment.title,
                          image: Image.asset(payment.icon, package: 'ui', width: 54),
                          onTap: () => Navigator.pop<PaymentModel>(ctx, payment),
                        ),
                      ),
                    if (isSelected.id != 0) ...[
                      const SizedBox(height: 16),
                      Text(context.x.l10n.wallet, style: context.x.textStyle.sfW500s16.copyWith(fontSize: 18)),
                      PaymentCard(
                        hasShadow: true,
                        title: paymentMethods.first.title,
                        subtitle: paymentMethods.first.subtitle,
                        image: Image.asset(paymentMethods.first.icon, package: 'ui', width: 44),
                        onTap: () => Navigator.pop<PaymentModel>(ctx, paymentMethods.first),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      selectedPayment.value = result;
    }
  }

  Future<void> onConfirmUpload() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => isSubmitting = false);
      context.octopus.navigate(Routes.home.name);
    }
  }
}
