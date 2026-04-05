import 'package:ui/ui.dart';

import '../../../common/constant/constant.dart';
import '../../../common/extension/context_extension.dart';
import '../../my_tests/widgets/test_description_widget.dart';
import '../state/test_group_mode_screen_state.dart';

class TestGroupModeScreen extends StatefulWidget {
  const TestGroupModeScreen({super.key});

  @override
  State<TestGroupModeScreen> createState() => _TestGroupModeScreenState();
}

class _TestGroupModeScreenState extends TestGroupModeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: 'Group Mode',
    ),
    body: Padding(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          TestDescriptionWidget(test: test, onPressLike: onPressLike, onPressShare: onPressShare),
          const SizedBox(height: 16),
          Text('Group rejim uchun testni sozlang:', style: context.x.textStyle.sfW500s22),
          const SizedBox(height: 16),
          Row(
            spacing: 12,
            crossAxisAlignment: .center,
            children: [
              SizedBox(
                width: 60,
                height: 28,
                child: Stack(
                  children: [
                    for (var i = 2; i >= 0; i--)
                      Positioned(
                        left: i * 16,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: .circular(100),
                            color: context.x.colors.primary,
                            border: .all(width: 3, color: context.x.colors.scaffoldBackground),
                          ),
                          child: const SizedBox(width: 28, height: 28),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                'Do’stlarni taklif qilish',
                style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) => Row(
                spacing: 16,
                children: [
                  ClipRRect(
                    borderRadius: .circular(100),
                    child: Image.asset(Assets.lib.images.logo.path, width: 48, height: 48, package: Constant.packageUi),
                  ),
                  Column(
                    crossAxisAlignment: .start,
                    spacing: 2,
                    children: [
                      Text('Takhirovs', style: context.x.textStyle.sfW500s16.copyWith(color: context.x.colors.text)),
                      Text(
                        '@takhirov_test',
                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('Joined', style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.success)),
                ],
              ),
              separatorBuilder: (context, index) => Padding(
                padding: const .only(left: 66),
                child: Divider(height: 20, color: context.x.colors.divider),
              ),
              itemCount: 16,
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const .only(left: 20, right: 20, bottom: 16),
        child: CustomButton(onTap: () {}, title: 'Testni boshlash', borderRadius: 10),
      ),
    ),
  );
}
