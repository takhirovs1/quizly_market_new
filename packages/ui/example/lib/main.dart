import 'package:ui/ui.dart';

import 'src/home_screen.dart';

void main() {
  runApp(const App());
}

/// {@template main}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro main}
  const App({
    super.key, // ignore: unused_element
  });

  @override
  State<App> createState() => _AppState();
}

/// State for widget App.
class _AppState extends State<App> {
  final GlobalKey<State<StatefulWidget>> appKey = GlobalKey<State<StatefulWidget>>();

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomeScreen(),
    theme: ThemeData(brightness: Brightness.light),
    builder: (context, child) => MediaQuery(
      key: appKey,
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
