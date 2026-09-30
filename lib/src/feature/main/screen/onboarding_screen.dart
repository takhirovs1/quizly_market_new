import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/main_cubit.dart';
import '../state/onboarding_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends OnboardingState {
  @override
  Widget build(BuildContext context) => BlocListener<MainCubit, MainState>(
    listenWhen: (previous, current) => current.status.isSuccess && previous.status != current.status,
    listener: (context, state) async {
      await context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
      if (context.mounted) context.octopus.navigate(Routes.home.name);
    },
    child: Scaffold(
      backgroundColor: context.x.colors.appBarBackground,
      appBar: const QuizAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: Column(
                  spacing: 10,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350, minWidth: 200),
                        child: Assets.lib.images.logoPng.image(package: 'ui'),
                      ),
                    ),
                    Center(
                      child: Text(
                        context.x.l10n.quizlyMarket,
                        style: context.x.textStyle.w400s45.copyWith(color: context.x.colors.white, fontWeight: .w600),
                        textAlign: .center,
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                borderRadius: 100,
                color: context.x.colors.customButtonBackground,
                textColor: context.x.colors.customButtonText,
                onTap: onStartApp,
                title: context.x.l10n.start,
              ),
              const SizedBox(height: 20),
              Text(
                context.x.l10n.copyRight,
                style: context.x.textStyle.sfW400s12.copyWith(fontWeight: .w200, color: context.x.colors.white),
                textAlign: .center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}
