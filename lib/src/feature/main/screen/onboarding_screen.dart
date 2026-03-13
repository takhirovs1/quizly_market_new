import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.appBarBackground,
    appBar: const QuizAppBar(),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Text(
                'QuizlyMarket',
                style: context.x.textStyle.w400s45.copyWith(color: context.x.colors.white, fontWeight: .w600),
                textAlign: .center,
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400, minWidth: 255),
                  child: Assets.lib.images.logoPng.image(package: 'ui'),
                ),
              ),
            ),
            CustomButton(
              borderRadius: 100,
              color: context.x.colors.customButtonBackground,
              textColor: context.x.colors.customButtonText,
              onTap: () {
                context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
                context.octopus.navigate(Routes.home.name);
              },
              title: 'START',
            ),
            const SizedBox(height: 20),
            Text(
              'Copyright © 2025 FlutterBro',
              style: context.x.textStyle.w400s12.copyWith(fontWeight: .w200, color: context.x.colors.white),
              textAlign: .center,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
