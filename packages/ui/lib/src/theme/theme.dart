import 'package:flutter/material.dart';

import '../gen/fonts.gen.dart';
import 'colors.dart';
import 'typography.dart';

export 'colors.dart';
export 'typography.dart';

/// {@template theme}
/// App theme data.
/// {@endtemplate}
extension type AppThemeData._(ThemeData data) implements ThemeData {
  /// {@macro theme}
  factory AppThemeData.light({String fontFamily = FontFamily.nunito}) => AppThemeData._(_appLightTheme(fontFamily));

  /// {@macro theme}
  factory AppThemeData.dark({String fontFamily = FontFamily.nunito}) => AppThemeData._(_appDarkTheme(fontFamily));
}

/// Extension on [ThemeData] to provide App theme data.
extension AutoThemeExtension on ThemeData {
  /// Returns the App theme colors.
  ThemeColors get appColors =>
      extension<ThemeColors>() ??
      switch (brightness) {
        Brightness.light => ThemeColors.light,
        Brightness.dark => ThemeColors.dark,
      };

  AppTypography get appTextStyles =>
      extension<AppTypography>() ??
      switch (brightness) {
        Brightness.light => AppTypography.textThemeLight,
        Brightness.dark => AppTypography.textThemeDark,
      };
}

// --- Light Theme --- //

/// Light theme data for the App.
ThemeData _appLightTheme(String fontFamily) => ThemeData(
  fontFamily: fontFamily,
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: ThemeColors.dark.primary,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: ThemeColors.light.primary,
    onPrimary: ThemeColors.light.onPrimary,
    secondary: ThemeColors.light.secondary,
    onSecondary: ThemeColors.light.onSecondary,
    error: ThemeColors.light.error,
    onError: ThemeColors.light.onError,
    surface: ThemeColors.light.surface,
    onSurface: ThemeColors.light.onSurface,
  ),
  // splashFactory: NoSplash.splashFactory,
  scaffoldBackgroundColor: ThemeColors.light.onPrimary,
  tabBarTheme: TabBarThemeData(indicatorColor: ThemeColors.light.primary),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: ThemeColors.light.primary),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    backgroundColor: ThemeColors.light.white,
    titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  // pageTransitionsTheme: PageTransitionsTheme(
  //   builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
  //     TargetPlatform.values,
  //     value: (_) => const OpenUpwardsPageTransitionsBuilder(),
  //   ),
  // ),
).copyWith(extensions: <ThemeExtension<Object?>>[ThemeColors.light, AppTypography.textThemeLight]);

// --- Dark Theme --- //

/// Dark theme data for the App.
ThemeData _appDarkTheme(String fontFamily) => ThemeData(
  fontFamily: fontFamily,
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: ThemeColors.dark.primary,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: ThemeColors.dark.primary,
    onPrimary: ThemeColors.dark.onPrimary,
    secondary: ThemeColors.dark.secondary,
    onSecondary: ThemeColors.dark.onSecondary,
    error: ThemeColors.dark.error,
    onError: ThemeColors.dark.onError,
    surface: ThemeColors.dark.surface,
    onSurface: ThemeColors.dark.onSurface,
  ),
  // splashFactory: NoSplash.splashFactory,
  scaffoldBackgroundColor: ThemeColors.dark.onPrimary,
  tabBarTheme: TabBarThemeData(indicatorColor: ThemeColors.dark.primary),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: ThemeColors.dark.primary),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    backgroundColor: ThemeColors.dark.surface,
    titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
).copyWith(extensions: <ThemeExtension<Object?>>[ThemeColors.dark, AppTypography.textThemeDark]);
