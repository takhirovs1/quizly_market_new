import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../feature/main/bloc/main_cubit.dart';
import '../../../feature/main/model/login_with_telegram.dart';
import '../../../feature/my_tests/models/test_by_code_model.dart';
import '../../extension/context_extension.dart';
import '../../router/pages.dart';
import '../../util/helpers.dart';
import '../../util/locale_codec.dart';

/// {@template splash_screen}
/// Splash screen widget.
/// {@endtemplate}
class SplashScreen extends StatefulWidget {
  /// {@macro splash_screen}
  const SplashScreen({this.logo, this.progress, super.key});

  /// Logo to display.
  final ({String path, double scale})? logo;

  /// Progress notifier.
  final ValueNotifier<({int progress, String message})>? progress;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends SplashController {
  @override
  Widget build(BuildContext context) {
    final theme = View.of(context).platformDispatcher.platformBrightness == .light
        ? AppThemeData.light()
        : AppThemeData.dark();

    return Material(
      color: theme.appColors.white,
      child: Directionality(
        textDirection: .ltr,
        child: Scaffold(
          backgroundColor: const Color(0xff1C58F2),
          body: Column(
            children: [
              Expanded(
                child: Center(child: SizedBox(width: 180, height: 180, child: _buildLogo())),
              ),
              const Padding(
                padding: .only(bottom: 32),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2, backgroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// --- Splash screen controller --- ///
/// {@template splash_controller}
/// Splash screen controller.
/// {@endtemplate}
abstract class SplashController extends State<SplashScreen> with SingleTickerProviderStateMixin {
  SvgPicture? svgImage;
  double logoScale = 1;
  bool _vibrated = false;
  ({String path, double scale})? _logo;

  late AnimationController controller;
  late Animation<double> opacityAnimation;

  Widget _buildLogo() {
    final logoPath = _logo?.path;
    if (logoPath == null || logoPath.isEmpty) return const SizedBox.shrink();

    final normalizedPath = logoPath.toLowerCase();

    if (normalizedPath.endsWith('.vec')) {
      return SvgPicture(AssetBytesLoader(logoPath, packageName: 'ui'));
    }

    if (normalizedPath.endsWith('.svg')) {
      return SvgPicture.asset(logoPath, package: 'ui');
    }

    return Image.asset(logoPath, package: 'ui');
  }

  void _providePreciseHapticFeedback() {
    if (controller.value > 0.2 && !_vibrated) {
      HapticFeedback.mediumImpact();
      _vibrated = true;
    }
  }

  void _onAppInitializedListener() {
    if (widget.progress?.value.progress == 100) {
      controller.forward();
    }
  }

  // --- Lifecycle --- //
  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    opacityAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.addListener(_providePreciseHapticFeedback);

    _logo = widget.logo;
    if (_logo == null) {
      Helpers.getPlatformSpecificLogo().then((logo) {
        if (mounted) {
          setState(() {
            _logo = logo;
          });
        }
      });
    }

    if (widget.progress != null) {
      widget.progress!.addListener(_onAppInitializedListener);
    } else {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    if (widget.progress != null) {
      widget.progress!.removeListener(_onAppInitializedListener);
    }
    super.dispose();
  }

  // --- End of Lifecycle --- //
}

class SplashRouteWrapper extends StatefulWidget {
  const SplashRouteWrapper({super.key});

  @override
  State<SplashRouteWrapper> createState() => _SplashRouteWrapperState();
}

class _SplashRouteWrapperState extends State<SplashRouteWrapper> {
  @override
  void initState() {
    super.initState();
    final tg = context.telegramWebApp;
    if (tg.isSupported) {
      context.read<MainCubit>().signInWithTelegram(LoginWithTelegramRequest(initData: tg.initDataRaw));
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<MainCubit, MainState>(
    listenWhen: (previous, current) => current.status.isSuccess && previous.status != current.status,
    listener: (context, state) async {
      final language = state.loginWithTelegramResponse?.language;
      if (language != null && language.isNotEmpty) {
        context.x.setLocalization(AppLocaleCodec.decode(language));
      }
      await context.x.dependencies.localSource.setOnboardingCompleted(completed: true);
      if (context.mounted) {
        final startParam = context.telegramWebApp.startParam;
        if (startParam != null && startParam.isNotEmpty) {
          try {
            final repo = context.x.dependencies.repository.myTestRepository;
            final response = await repo.getTestByCode(TestByCodeRequest(code: startParam));
            final isPurchased = response.data?.isPurchased ?? false;
            final testId = response.data?.id ?? startParam;
            if (context.mounted) {
              if (isPurchased) {
                context.octopus.setState(
                  (s) => s
                    ..clear()
                    ..add(OctopusNode(name: Routes.home.name, arguments: const {}, children: const []))
                    ..add(OctopusNode(name: Routes.testMode.name, arguments: {'id': testId}, children: const [])),
                );
              } else {
                context.octopus.setState(
                  (s) => s
                    ..clear()
                    ..add(OctopusNode(name: Routes.home.name, arguments: const {}, children: const []))
                    ..add(OctopusNode(name: Routes.purchaseTest.name, arguments: {'id': testId}, children: const [])),
                );
              }
            }
          } on Object catch (_) {
            if (context.mounted) {
              context.octopus.setState(
                (s) => s
                  ..clear()
                  ..add(OctopusNode(name: Routes.home.name, arguments: const {}, children: const []))
                  ..add(OctopusNode(name: Routes.purchaseTest.name, arguments: {'id': startParam}, children: const [])),
              );
            }
          }
        } else {
          context.octopus.navigate('home');
        }
      }
    },
    child: const SplashScreen(),
  );
}
