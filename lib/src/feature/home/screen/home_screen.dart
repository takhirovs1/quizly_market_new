import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
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
    super.key, // ignore: unused_element
  });

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
    currentIndex = ValueNotifier(0);
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
  Widget build(BuildContext context) => Scaffold(
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
    bottomNavigationBar: ColoredBox(
      color: context.x.colors.dialogBackground,
      child: Padding(
        padding: .only(
          bottom: context.telegramWebApp.isSupported ? context.telegramWebApp.safeAreaInset.bottom.toDouble() : 0.0,
        ),
        child: QuizNavigationBar(
          labels: [context.x.l10n.home, context.x.l10n.market, context.x.l10n.upload, context.x.l10n.profile],
          currentIndex: currentIndex.value,
          onTap: onTap,
        ),
      ),
    ),
  );
}
