import '../../ui.dart';

extension BuildContextX on BuildContext {
  /// [Build] extension
  Build get x => Build(this);
}

extension type Build(BuildContext context) {
  /// [ThemeData] extension
  ThemeData get theme => Theme.of(context);

  /// [ThemeColors] extension
  ThemeColors get colors => theme.appColors;

  /// [AppTypography] extension
  AppTypography get textStyle => theme.appTextStyles;

  /// [HomeColors] extension — Home-screen design tokens
  HomeColors get homeColors => theme.appHomeColors;

  /// [isDarkMode] extension
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
