import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../models/payment_model.dart';
import '../models/test_mode.dart';
import '../screen/purchase_test_screen.dart';

abstract class PurchaseTestScreenState extends State<PurchaseTestScreen> {
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final PageController pageController;
  late final ValueNotifier<int> currentTest;
  final List<PaymentModel> paymentModel = [
    PaymentModel(
      id: 0,
      title: 340000.formatUzs,
      type: .card,
      icon: Assets.lib.images.logoPng.path,
      subtitle: 'QuizlyMarket Card',
    ),
    PaymentModel(id: 1, title: 'Payme', type: .provider, icon: Assets.lib.images.payme2.path),
    PaymentModel(id: 2, title: 'ClickSuperApp', type: .provider, icon: Assets.lib.images.click2.path),
  ];
  final TestModel test = TestModel(
    id: 1,
    title: 'O’zbekistonning eng yangi tarixi fanidan testlar',
    description: 'O’zbekiston tarixi bo‘yicha test savollari',
    author: 'Toshkent Davlat Iqtisodiyot Universiteti',
    price: 20000,
    questions: [
      QuestionModel(
        id: 1,
        question: 'O’zbekiston qachon davlat mustaqilligini e’lon qilgan?',
        answers: [
          AnswerModel(id: 1, text: '1990-yil 20-iyun', isCorrect: false),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: true),
          AnswerModel(id: 3, text: '1992-yil 8-dekabr', isCorrect: false),
          AnswerModel(id: 4, text: '1993-yil 1-yanvar', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 2,
        question: 'O’zbekiston Respublikasi Konstitutsiyasi qachon qabul qilingan?',
        answers: [
          AnswerModel(id: 1, text: '1992-yil 8-dekabr', isCorrect: true),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1995-yil 9-may', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 3,
        question: 'O’zbekiston poytaxti qaysi shahar?',
        answers: [
          AnswerModel(id: 1, text: 'Samarqand', isCorrect: false),
          AnswerModel(id: 2, text: 'Buxoro', isCorrect: false),
          AnswerModel(id: 3, text: 'Toshkent', isCorrect: true),
          AnswerModel(id: 4, text: 'Andijon', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 4,
        question: 'O’zbekiston bayrog‘i qachon tasdiqlangan?',
        answers: [
          AnswerModel(id: 1, text: '1991-yil 18-noyabr', isCorrect: true),
          AnswerModel(id: 2, text: '1992-yil 8-dekabr', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1990-yil 20-iyun', isCorrect: false),
        ],
      ),
      QuestionModel(
        id: 5,
        question: 'O’zbekiston davlat gerbi qachon qabul qilingan?',
        answers: [
          AnswerModel(id: 1, text: '1992-yil 2-iyul', isCorrect: true),
          AnswerModel(id: 2, text: '1991-yil 31-avgust', isCorrect: false),
          AnswerModel(id: 3, text: '1993-yil 1-yanvar', isCorrect: false),
          AnswerModel(id: 4, text: '1995-yil 9-may', isCorrect: false),
        ],
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    pageController = PageController();
    currentTest = ValueNotifier(0);
    selectedPayment = ValueNotifier(
      PaymentModel(
        id: 0,
        title: 340000.formatUzs,
        type: .card,
        icon: Assets.lib.images.logoPng.path,
        subtitle: 'QuizlyMarket Card',
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    selectedPayment.dispose();
    context.teardownTelegramBackButton();
  }

  Future<void> onSwitchPaymentPressed() async {
    final result = await showModalBottomSheet<PaymentModel>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .55,
        builder: (context, scrollController) => BottomSheetView(
          isCenterTitle: false,
          onClose: () => Navigator.pop(ctx),
          title: 'To‘lov turini tanlang',
          child: Padding(
            padding: const .symmetric(horizontal: 14, vertical: 16),
            child: ValueListenableBuilder<PaymentModel?>(
              valueListenable: selectedPayment,
              builder: (context, isSelected, child) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text('Hozirgi to‘lov turi', style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    PaymentCard(
                      hasShadow: true,
                      imagePadding: isSelected?.id != 0
                          ? const .symmetric(horizontal: 6, vertical: 14)
                          : const .symmetric(horizontal: 6, vertical: 8),
                      title: isSelected!.title,
                      subtitle: isSelected.subtitle,
                      image: Image.asset(isSelected.icon, package: 'ui', width: isSelected.type == .card ? 32 : 54),
                      isActive: true,
                    ),
                    const SizedBox(height: 16),
                    Text('Provider orqali to’lov', style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                    for (final payment in paymentModel.where((e) => e != isSelected && e.id != 0))
                      Padding(
                        padding: const .only(bottom: 8),
                        child: PaymentCard(
                          hasShadow: true,
                          imagePadding: const .symmetric(horizontal: 6, vertical: 14),
                          title: payment.title,
                          image: Image.asset(payment.icon, package: 'ui', width: 54),
                          onTap: () => Navigator.pop<PaymentModel>(ctx, payment),
                        ),
                      ),

                    if (isSelected.id != 0) ...[
                      const SizedBox(height: 16),
                      Text('Hamyon', style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                      PaymentCard(
                        hasShadow: true,
                        title: paymentModel.first.title,
                        subtitle: paymentModel.first.subtitle,
                        image: Image.asset(paymentModel.first.icon, package: 'ui', width: 34),
                        onTap: () => Navigator.pop<PaymentModel>(ctx, paymentModel.first),
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

  void onBuyPressed() => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: context.x.colors.transparent,
      child: Center(
        child: SuccessDialog(
          title: 'Test sotib olingan!',
          description: 'Test description Test description Test description Test description',
          cancelButtonText: 'Chiqish',
          successButtonText: 'Qayta urinish',
          onCancelButtonPressed: () => Navigator.pop(context),
          onSuccessButtonPressed: () => Navigator.pop(context),
        ),
      ),
    ),
  );

  void onPressLike() {}
  void onPressShare() {}
}
