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

  /* #endregion */
}

class _HomeScreenState extends HomeScreenState {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    body: ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (context, value, child) => IndexedStack(
        index: value,
        children: const [MyTestsScreen(), RecommendationScreen(), UploadScreen(), ProfileScreen()],
      ),
    ),
    bottomNavigationBar: QuizNavigationBar(
      currentIndex: currentIndex.value,
      onTap: (index) => currentIndex.value = index,
    ),
  );
}

/// {@template home_screen}
/// A widget.
/// {@endtemplate}
class A extends StatelessWidget {
  /// {@macro home_screen}
  const A({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.buttonBorder,
    appBar: AppBar(title: const Text('A')),
    body: const Center(child: Text('A')),
  );
}
