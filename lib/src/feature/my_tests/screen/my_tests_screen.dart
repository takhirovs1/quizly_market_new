import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/my_tests_screen_state.dart';

class MyTestsScreen extends StatefulWidget {
  const MyTestsScreen({super.key});

  @override
  State<MyTestsScreen> createState() => _MyTestsScreenState();
}

class _MyTestsScreenState extends MyTestsScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: const QuizAppBar(title: 'Testlarim'),
    body: Padding(
      padding: const .symmetric(horizontal: 16),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          const EmptyTestWidget(
            title: 'Sizda hali testlar yo‘q.',
            description: 'Marketda turli mavzulardagi testlar mavjud. O‘zingizga mosini tanlang.',
          ),
          const SizedBox(height: 20),
          Row(children: [Text('Hoziroq sinab ko’ring', style: context.x.textStyle.w700s16.copyWith(fontSize: 22))]),
          for (var i = 0; i < 1; i++)
            BannerWidget(
              title: 'Example test',
              companyName: 'QuizlyMarket',
              description: 'Example test description, Example test description, Example test description',
              price: 'Tekin',
              questionAmount: '100 ta savol',
              buyButtonText: 'Sinab ko’rish',
              onBuyButtonPressed: () {},
              isFree: true,
            ),
          const SizedBox(height: 24),
          Text('Tavsiya', style: context.x.textStyle.w700s16.copyWith(fontSize: 22)),
          for (var i = 0; i < 4; i++)
            Column(
              children: [
                BannerWidget(
                  title: 'Example test',
                  companyName: 'QuizlyMarket',
                  description: 'Example test description, Example test description, Example test description',
                  price: 'Tekin',
                  questionAmount: '100 ta savol',
                  buyButtonText: 'Sinab ko’rish',
                  onBuyButtonPressed: onBuyTestPressed,
                ),
                const SizedBox(height: 10),
              ],
            ),
        ],
      ),
    ),
  );
}
