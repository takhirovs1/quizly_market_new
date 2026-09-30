import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/service/update_service.dart';
import '../../../common/widget/update_bottom_sheet.dart';
import '../../my_tests/screen/my_tests_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../recommendation/screen/recommendation_screen.dart';
import '../../upload/screen/upload_screen.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    this.initialTab = 0,
    super.key, // ignore: unused_element
  });

  final int initialTab;

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  @internal
  static HomeScreenState? maybeOf(BuildContext context) => context.findAncestorStateOfType<_HomeScreenState>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
abstract class HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<int> currentIndex;
  final Set<int> _activatedIndices = {0};

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    currentIndex = ValueNotifier(widget.initialTab);
    if (widget.initialTab != 0) {
      _activatedIndices.add(widget.initialTab);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      currentIndex.value = widget.initialTab;
      _activatedIndices.add(widget.initialTab);
    }
  }

  @override
  void dispose() {
    currentIndex.dispose();
    super.dispose();
  }

  void onTap(int index) {
    if (currentIndex.value != index) {
      if (context.telegramWebApp.isSupported) {
        context.telegramWebApp.hapticImpact(.light);
      } else {
        HapticFeedback.lightImpact();
      }
      if (!_activatedIndices.contains(index)) {
        setState(() {
          _activatedIndices.add(index);
        });
      }
      currentIndex.value = index;
    }
  }

  /* #endregion */
}

class _HomeScreenState extends HomeScreenState {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdate();
      _checkReferralDialog();
    });
  }

  Future<void> _checkUpdate() async {
    final updateInfo = await UpdateService().checkUpdate();
    if (!mounted) return;
    if (updateInfo != null && (updateInfo.hasUpdate || updateInfo.isForced)) {
      showUpdateBottomSheet(context, updateInfo);
    }
  }

  void _checkReferralDialog() {
    if (!mounted) return;
    final localSource = context.x.dependencies.localSource;
    final referralCode = localSource.referralCode;
    if (referralCode.isEmpty) return;

    context.x.dependencies.repository.profileRepository
        .verifyReferral()
        .then((response) {
          if (!mounted) return;
          // Clear saved code regardless of outcome — it's a one-time flag.
          localSource.setReferralCode('');

          if (!response.data.referred) return;

          final bonusAmount = response.data.bonusAmount;
          var title = context.x.l10n.referralBonusTitle;
          if (bonusAmount != null && bonusAmount > 0) {
            final formattedAmount = bonusAmount.splitPerThree;
            title = title.replaceAll('1 000', formattedAmount).replaceAll('1,000', formattedAmount);
          }

          // Show the dialog.
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: context.x.colors.transparent,
              child: Center(
                child: SuccessDialog(
                  title: title,
                  description: context.x.l10n.referralBonusDescription,
                  successButtonText: context.x.l10n.understand,
                  onSuccessButtonPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        })
        .catchError((_) {
          // On error, clear the code silently — don't show the dialog.
          localSource.setReferralCode('');
        });
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      canvasColor: Colors.transparent,
      shadowColor: Colors.transparent,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.transparent, elevation: 0),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.transparent, elevation: 0),
      colorScheme: Theme.of(context).colorScheme.copyWith(surfaceTint: Colors.transparent),
    ),
    child: Scaffold(
      extendBody: !context.x.isMobile,
      backgroundColor: context.x.colors.scaffoldBackground,
      body: ValueListenableBuilder<int>(
        valueListenable: currentIndex,
        builder: (context, value, child) => IndexedStack(
          index: value,
          children: [
            const MyTestsScreen(),
            if (_activatedIndices.contains(1)) const RecommendationScreen() else const SizedBox.shrink(),
            if (_activatedIndices.contains(2)) const UploadScreen() else const SizedBox.shrink(),
            if (_activatedIndices.contains(3)) const ProfileScreen() else const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: currentIndex,
        builder: (context, value, _) {
          final isMobile = context.x.isMobile;
          if (isMobile) {
            return ColoredBox(
              color: context.x.colors.dialogBackground,
              child: Padding(
                padding: .only(
                  bottom: context.telegramWebApp.isSupported
                      ? context.telegramWebApp.safeAreaInset.bottom.toDouble()
                      : 0.0,
                ),
                child: QuizNavigationBar(
                  labels: [context.x.l10n.home, context.x.l10n.market, context.x.l10n.upload, context.x.l10n.profile],
                  currentIndex: value,
                  onTap: onTap,
                ),
              ),
            );
          }

          return SafeArea(
            child: SizedBox(
              height: 104,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const .only(bottom: 24, left: 24, right: 24),
                  child: SizedBox(
                    width: 500,
                    child: QuizNavigationBar(
                      labels: [
                        context.x.l10n.home,
                        context.x.l10n.market,
                        context.x.l10n.upload,
                        context.x.l10n.profile,
                      ],
                      currentIndex: value,
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
