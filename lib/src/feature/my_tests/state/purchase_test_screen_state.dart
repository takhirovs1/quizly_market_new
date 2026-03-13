import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../models/payment_model.dart';
import '../models/test_mode.dart';
import '../screen/purchase_test_screen.dart';

abstract class PurchaseTestScreenState extends State<PurchaseTestScreen> {
  late final ValueNotifier<PaymentModel> selectedPayment;
  late final PageController pageController;
  ValueNotifier<int> currentTest = ValueNotifier(0);
  final List<PaymentModel> paymentModel = [
    PaymentModel(
      id: 0,
      title: 340000.formatUzs,
      type: PaymentType.card,
      icon: Assets.lib.images.logoPng.path,
      subtitle: 'QuizlyMarket Card',
    ),
    PaymentModel(id: 1, title: 'Payme', type: PaymentType.provider, icon: Assets.lib.images.payme2.path),
    PaymentModel(id: 2, title: 'ClickSuperApp', type: PaymentType.provider, icon: Assets.lib.images.click2.path),
  ];
  final List<QuestionModel> tests = [
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
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    selectedPayment = ValueNotifier(
      PaymentModel(
        id: 0,
        title: 340000.formatUzs,
        type: PaymentType.card,
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
  }

  Future<void> onSwitchPaymentPressed() async {
    final result = await showModalBottomSheet<PaymentModel>(
      context: context,
      builder: (ctx) => BottomSheetView(
        isCenterTitle: false,
        onClose: () => Navigator.pop(ctx),
        title: 'To‘lov turini tanlang',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: ValueListenableBuilder<PaymentModel?>(
            valueListenable: selectedPayment,
            builder: (context, isSelected, child) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hozirgi to‘lov turi', style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  PaymentCard(
                    title: paymentModel.first.title,
                    subtitle: paymentModel.first.subtitle,
                    image: Image.asset(paymentModel.first.icon ?? '', package: 'ui', width: 32),
                    isActive: isSelected == paymentModel.first,
                    onTap: () => Navigator.pop<PaymentModel>(ctx, paymentModel.first),
                  ),
                  const SizedBox(height: 16),
                  Text('Hoziroq sinab ko’ring', style: context.x.textStyle.w500s16.copyWith(fontSize: 18)),
                  for (var i = 1; i < paymentModel.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PaymentCard(
                        title: paymentModel[i].title,
                        image: Image.asset(paymentModel[i].icon ?? '', package: 'ui', width: 54),
                        onTap: () {
                          selectedPayment.value = paymentModel[i];
                          Navigator.pop<PaymentModel>(ctx, paymentModel[i]);
                        },
                        isActive: isSelected == paymentModel[i],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
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
}
