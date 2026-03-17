import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

import 'theme/app_colors.dart';
import 'theme/text_style.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(brightness: Brightness.dark),
    child: Scaffold(
      appBar: const QuizAppBar(title: 'Quizly Market'),
      body: Theme(
        data: Theme.of(context).copyWith(brightness: Brightness.light),
        child: Scaffold(
          // backgroundColor: Theme.of(context).appColors.black,
          appBar: const QuizAppBar(title: 'Quizly Market'),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const TextStyleUI(),

              const SectionWidget(
                title: 'AppColorsUI',
                children: [Center(child: SizedBox(width: 400, child: AppColorsUI()))],
              ),

              SectionWidget(
                title: 'PinCode',
                children: [
                  SizedBox(
                    width: 400,
                    child: PinCode(
                      controller: TextEditingController(),
                      focusNode: FocusNode(),
                      length: 4,
                      onChanged: print,
                      enabled: true,
                    ),
                  ),
                ],
              ),

              SectionWidget(
                title: 'ActionListTile',
                children: [
                  ActionListTile(
                    icon: const Icon(Icons.logout),
                    leading: 'Log out',
                    onPressed: () {},
                    iconColor: Theme.of(context).appColors.error,
                    textColor: Theme.of(context).appColors.error,
                  ),

                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: ActionListTile(
                      icon: const Icon(Icons.attach_money_rounded),
                      leading: 'Add money',
                      onPressed: () {},
                      iconColor: Theme.of(context).appColors.onPrimary,
                      textColor: Theme.of(context).appColors.onPrimary,
                    ),
                  ),
                ],
              ),

              SectionWidget(
                title: 'AppTextField',
                children: [
                  AppTextField(controller: TextEditingController(), title: 'Enter you name...'),

                  AppTextField(
                    controller: TextEditingController(),
                    title: 'What is on your mind?',
                    prefixWidget: const Icon(CupertinoIcons.search),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: TextEditingController(),
                          title: 'Search',
                          prefixWidget: const Icon(CupertinoIcons.search),
                        ),
                      ),

                      IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
                    ],
                  ),
                ],
              ),

              SectionWidget(
                title: 'BannerWidget',
                children: [
                  Center(
                    child: BannerWidget(
                      title: 'Test nomi',
                      companyName: 'Tashkilot nomi',
                      description: 'Test description Test description Test description Test description',
                      price: '10 000 UZS',
                      questionAmount: '100 ta savol',
                      buyButtonText: 'Sotib olish',
                      onBuyButtonPressed: () {},
                      onShareButtonPressed: () {},
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: Center(
                      child: BannerWidget(
                        title: 'Test nomi',
                        companyName: 'Tashkilot nomi',
                        description: 'Test description Test description Test description Test description',
                        price: '10 000 UZS',
                        questionAmount: '100 ta savol',
                        buyButtonText: 'Sotib olish',
                        onBuyButtonPressed: () {},
                        onShareButtonPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),

              SectionWidget(
                title: 'ErrorDialog',
                children: [
                  ErrorDialog(
                    title: 'Test sotib olinmadi!',
                    description: 'Test description Test description Test description Test description',
                    cancelButtonText: 'Chiqish',
                    successButtonText: 'Qayta urinish',
                    onCancelButtonPressed: () {},
                    onSuccessButtonPressed: () {},
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: ErrorDialog(
                      title: 'Test sotib olinmadi!',
                      description: 'Test description Test description Test description Test description',
                      cancelButtonText: 'Chiqish',
                      successButtonText: 'Qayta urinish',
                      onCancelButtonPressed: () {},
                      onSuccessButtonPressed: () {},
                    ),
                  ),
                ],
              ),
              SectionWidget(
                title: 'SuccessDialog',
                children: [
                  SuccessDialog(
                    title: 'Test sotib olingan!',
                    description: 'Test description Test description Test description Test description',
                    cancelButtonText: 'Chiqish',
                    successButtonText: 'Qayta urinish',
                    onCancelButtonPressed: () {},
                    onSuccessButtonPressed: () {},
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: SuccessDialog(
                      title: 'Test sotib olingan!',
                      description: 'Test description Test description Test description Test description',
                      cancelButtonText: 'Chiqish',
                      successButtonText: 'Qayta urinish',
                      onCancelButtonPressed: () {},
                      onSuccessButtonPressed: () {},
                    ),
                  ),
                ],
              ),
              SectionWidget(
                title: 'MiniBannerWidget',
                children: [
                  Wrap(
                    runAlignment: WrapAlignment.center,
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      MiniBannerWidget(
                        title: 'Test nomi',
                        companyName: 'Tashkilot nomi',
                        description: 'Test description Test description Test description Test description ',
                        price: '10 000 UZS',
                        questionAmount: '100 ta savol',
                        buyButtonText: 'Sotib olish',
                        onBuyButtonPressed: () {},
                        onShareButtonPressed: () {},
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(brightness: Brightness.dark),
                        child: MiniBannerWidget(
                          title: 'Test nomi',
                          companyName: 'Tashkilot nomi',
                          description: 'Test description Test description Test description Test description ',
                          price: '10 000 UZS',
                          questionAmount: '100 ta savol',
                          buyButtonText: 'Sotib olish',
                          onBuyButtonPressed: () {},
                          onShareButtonPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SectionWidget(
                title: 'EmptyTestWidget',
                children: [
                  const EmptyTestWidget(
                    title: 'Sizda hali testlar yo‘q.',
                    description: 'Marketda turli mavzulardagi testlar mavjud. O‘zingizga mosini tanlang.',
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: const EmptyTestWidget(
                      title: 'Sizda hali testlar yo‘q.',
                      description: 'Marketda turli mavzulardagi testlar mavjud. O‘zingizga mosini tanlang.',
                    ),
                  ),
                ],
              ),
              SectionWidget(
                title: 'QuizNavigationBar',
                children: [
                  QuizNavigationBar(
                    labels: const ['Home', 'Market', 'Downloads', 'Profile'],
                    currentIndex: 0,
                    onTap: (index) {},
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: QuizNavigationBar(
                      labels: const ['Home', 'Market', 'Downloads', 'Profile'],
                      currentIndex: 1,
                      onTap: (index) {},
                    ),
                  ),
                ],
              ),
              SectionWidget(
                title: 'Custom Buttons',
                children: [
                  CustomButton(onTap: () {}, title: 'Button'),
                  CustomButton(
                    onTap: () {},
                    title: 'Button',
                    color: Theme.of(context).appColors.white,
                    textColor: Theme.of(context).appColors.primary,
                  ),
                ],
              ),

              SectionWidget(
                title: 'SelectableTile',
                children: [
                  SelectableTile(title: 'SelectableTile', isActive: true, onTap: () {}),
                  const SelectableTile(title: 'SelectableTile', isActive: true),
                  SelectableTile(title: 'SelectableTile', onTap: () {}, subtitle: 'Yaqinda qo’shilgan'),
                  const SelectableTile(title: 'SelectableTile', subtitle: 'Subtitle'),
                ],
              ),

              SectionWidget(
                title: 'Payment Cards',
                children: [
                  PaymentCard(
                    title: '340 000 UZS',
                    subtitle: 'QuizlyMarket Card',
                    isActive: true,
                    onTap: () {},
                    image: Assets.lib.images.logoPng.image(package: 'ui', width: 32),
                  ),
                  PaymentCard(
                    title: 'Payme',
                    isActive: true,
                    onTap: () {},
                    image: Assets.lib.images.payme2.image(package: 'ui', width: 54),
                  ),

                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: Column(
                      spacing: 6,
                      children: [
                        PaymentCard(
                          title: '340 000 UZS',
                          subtitle: 'QuizlyMarket Card',
                          isActive: true,
                          onTap: () {},
                          image: Assets.lib.images.logoPng.image(package: 'ui', width: 32),
                        ),
                        PaymentCard(
                          title: 'Payme',
                          isActive: true,
                          onTap: () {},
                          image: Assets.lib.images.payme2.image(package: 'ui', width: 54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SectionWidget(
                title: 'PageIndicator',
                children: [
                  const PageIndicator(totalPages: 12, selectedPage: 5),
                  Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: const PageIndicator(totalPages: 12, selectedPage: 5),
                  ),
                ],
              ),
            ].expand((widget) => [widget, const SizedBox(height: 32)]).toList(),
          ),
        ),
      ),
    ),
  );
}

class SectionWidget extends StatelessWidget {
  const SectionWidget({required this.children, required this.title, this.padding, super.key});

  final String title;
  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Center(
    child: DecoratedBox(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorders(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Theme.of(context).appColors.divider),
        ),
        color: Theme.of(context).appColors.buttonBorder,
      ),
      child: Column(
        children: [
          // Widget title
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).appColors.divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Center(child: AppText.w500s16(title)),
            ),
          ),

          // Children
          Padding(
            padding: padding ?? const EdgeInsets.all(8),
            child: Column(spacing: 8, children: children),
          ),
        ],
      ),
    ),
  );
}
