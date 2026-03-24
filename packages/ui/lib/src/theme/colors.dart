import 'package:flutter/material.dart';

/// {@template app_colors}
/// Emphasis class
/// Theme colors for the application:
/// https://www.figma.com/design/8MviThY8YQKl4WDJadFklR/Quizly-Theme?node-id=0-1&p=f&t=mSp38R4RkO7Dygx3-0
/// {@endtemplate}
@immutable
final class ThemeColors extends ThemeExtension<ThemeColors> {
  /// {@macro app_colors}
  const ThemeColors({
    required this.error,
    required this.onError,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.success,
    required this.onSuccess,
    required this.surface,
    required this.onSurface,
    required this.tealBlue,
    required this.tertiary,
    required this.tertiaryBold,
    required this.onTertiary,

    // Base colors
    required this.black,
    required this.gray,
    required this.transparent,
    required this.white,
    required this.green,

    // Widget-specific colors
    required this.buttonBorder,
    required this.buttonFill,
    required this.divider,
    required this.primaryButtonFill,
    required this.primaryButtonBorder,

    // text color
    required this.text,

    // duty status circles colors
    required this.breakC,
    required this.driveC,
    required this.shiftC,
    required this.cycleC,
    required this.themeToggle,

    // banner colors
    required this.bannerBackground,
    required this.bannerText,
    required this.bannerSecondaryText,
    required this.bannerPriceText,
    required this.bannerButton,
    required this.bannerIcon,

    // dialog colors
    required this.dialogBackground,
    required this.dialogText,
    required this.dialogCancelButton,

    // app bar colors
    required this.appBarBackground,

    // bottom navigation bar colors
    required this.bottomNavigationBarUnselectedColor,

    // scaffold colors
    required this.scaffoldBackground,

    // custom button
    required this.customButtonBackground,
    required this.customButtonText,

    // bottom sheet colors
    required this.bottomSheetBackground,

    // card background
    required this.cardBackground,

    // indicator background
    required this.indicatorBackground,

    // cardBackground2
    required this.cardBackground2,

    // text field background
    required this.textFieldBackground,
  });

  factory ThemeColors.of(BuildContext context) {
    try {
      final theme = Theme.of(context);
      return theme.extension<ThemeColors>() ??
          switch (theme.brightness) {
            Brightness.light => ThemeColors.light,
            Brightness.dark => ThemeColors.dark,
          };
    } on Object {
      return ThemeColors.light;
    }
  }

  /// Error color light[0xFFff2f22] dark[0xFFff2f22]
  final Color error;

  /// Error color on error light[0xFFF8F9FA] dark[0xFFF8F9FA]
  final Color onError;

  /// Primary color light[0xFF1C60E8] dark[0xFF1C60E8]
  final Color primary;

  /// Primary color on primary light[0xFFF2F7F7] dark[0xFF1A1F22]
  final Color onPrimary;

  /// Secondary color light[0xFFF8F9FA] dark[0xFFE1EBF0]
  final Color secondary;

  /// Secondary color on secondary light[0xFF1A1F22] dark[0xFFF8F9FA]
  final Color onSecondary;

  /// Success color light[0xFF0CD678] dark[0xFF0CD678]
  final Color success;

  /// Success color on success light[0xFFF8F9FA] dark[0xFFF8F9FA]
  final Color onSuccess;

  /// Surface color light[0xFFF8F9FA] dark[0xFF1A1F22]
  final Color surface;

  /// Surface color on surface light[0xFF202732] dark[0xFF202732]
  final Color onSurface;

  /// Teal blue color light[0xFF026492] dark[0xFF026492]
  final Color tealBlue;

  /// Tertiary color light[0xFF0CD678] dark[0xFF0CD678]
  final Color tertiary;

  /// Tertiary bold color light[0xFF09AC60] dark[0xFF09AC60]
  final Color tertiaryBold;

  /// Tertiary bold color on tertiary light[0xFFF8F9FA] dark[0xFFF8F9FA]
  final Color onTertiary;

  /// Black color light[0xFF000000] dark[0xFF000000]
  final Color black;

  /// Gray color light[0xFFA0A9BA] dark[0xFFA0A9BA]
  final Color gray;

  /// Transparent color light[0x00000000] dark[0x00000000]
  final Color transparent;

  /// White color light[0xFFF8F9FA] dark[0xFFF8F9FA]
  final Color white;

  /// Green color light[0xFF099250] dark[0xFF099250]
  final Color green;

  /// Button border color light[0xFFE1EBF0] dark[0xFF41484C]
  final Color buttonBorder;

  /// Button fill color light[0xFFA1ADB5] dark[0xFFA1ADB5]
  final Color buttonFill;

  /// Divider color light[0xFFE1EBF0] dark[0xFF41484C]
  final Color divider;

  /// Primary button fill color light[0xFF18ACEC] dark[0xFF18ACEC]
  final Color primaryButtonFill;

  /// Primary button border color light[0xFF1594CA] dark[0xFF1594CA]
  final Color primaryButtonBorder;

  /// Text color light[0xFF202732] dark[0xFFF8F9FA]
  final Color text;

  /// duty status circles colors
  ///
  /// light[0xFFF79009] dark[0xFFF79009]
  final Color breakC;

  /// light[0xFF12B76A] dark[0xFF12B76A]
  final Color driveC;

  /// light[0xFF1594CA] dark[0xFF1594CA]
  final Color shiftC;

  /// light[0xFFff2f22] dark[0xFFff2f22]
  final Color cycleC;

  /// theme toggle color light[0xFF202732] dark[0xFFF8F9FA]
  final Color themeToggle;

  /// banner background color light[0x14747480] dark[0xFF1E293B]
  final Color bannerBackground;

  /// banner text color light[0xFF000000] dark[0xFFF8FAFC]
  final Color bannerText;

  /// banner secondary text color light[0xFF707579] dark[0xFFCBD5E1]
  final Color bannerSecondaryText;

  /// banner price text color light[0xFF007AFF] dark[0xFF3B82F6]
  final Color bannerPriceText;

  /// banner button color light[0xFF007AFF] dark[0xFF1E40AF]
  final Color bannerButton;

  /// banner icon color light[0xFF333333] dark[0xFFFFFFFF]
  final Color bannerIcon;

  /// dialog background color light[0xFFFFFFFF] dark[0xFF020617]
  final Color dialogBackground;

  /// dialog text color light[0xFF000000] dark[0xFFFFFFFF]
  final Color dialogText;

  /// dialog cancel button color light[0x1A007AFF] dark[0xFF1E293B]
  final Color dialogCancelButton;

  /// app bar background color light[0xFF007AFF] dark[0xFF020617]
  final Color appBarBackground;

  /// bottom navigation bar unselected icon color light[0xFFBBBFD0] dark[0xFFBBBFD0]
  final Color bottomNavigationBarUnselectedColor;

  /// Scaffold background color light[0xFFFFFFFF] dark[0xFF0F172A]
  final Color scaffoldBackground;

  /// Custom button background color light[0xffFBFCF6] dark[0xff1E40AF]
  final Color customButtonBackground;

  /// Custom button background color light[0xff007AFF] dark[0xffF8FAFC]
  final Color customButtonText;

  /// Bottom sheet background color light[0xFFECEDF0] dark[0xFF1E293B]
  final Color bottomSheetBackground;

  /// Card background color light[0xff0F172A] dark[0xffFFFFFF]
  final Color cardBackground;

  /// Indicator background color light[0x40000000] dark[0x40FFFFFF]
  final Color indicatorBackground;

  /// cardBackground2 light[0xffFFFFFF] dark[0xff1E293B]
  final Color cardBackground2;

  /// text field background color light[0xffF3F4F6] dark[0xff1E293B]
  final Color textFieldBackground;

  /// The default light theme colors.
  static const light = ThemeColors(
    error: Color(0xFFFF2F22),
    onError: Color(0xFFF8F9FA),
    primary: Color(0xFF007AFF),
    onPrimary: Color(0xFFF2F7F7),
    secondary: Color(0xFFF8F9FA),
    onSecondary: Color(0xFF1A1F22),
    success: Color(0xFF0CD678),
    onSuccess: Color(0xFFF8F9FA),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF202732),
    tealBlue: Color(0xFF026492),
    tertiary: Color(0xFF0CD678),
    tertiaryBold: Color.fromARGB(255, 9, 172, 96),
    onTertiary: Color(0xFFF8F9FA),

    // Base colors
    black: Color(0xFF000000),
    gray: Color(0xFFA0A9BA),
    transparent: Color(0x00000000),
    white: Color(0xFFF8F9FA),
    green: Color(0xFF099250),

    // Widget-specific colors
    buttonBorder: Color(0xFFE1EBF0),
    buttonFill: Color(0xFFF4F4F4),
    divider: Color(0xFFE1EBF0),
    primaryButtonFill: Color(0xFFF8F9FA),
    primaryButtonBorder: Color(0xFF1594CA),

    // text color
    text: Color(0xFF202732),

    // duty status circles colors
    breakC: Color(0xFFF79009),
    driveC: Color(0xFF12B76A),
    shiftC: Color(0xFF1594CA),
    cycleC: Color(0xFFFF2F22),

    // theme toggle color
    themeToggle: Color(0xFF202732),

    // banner colors
    bannerBackground: Color(0x14747480),
    bannerText: Color(0xFF000000),
    bannerSecondaryText: Color(0xFF707579),
    bannerPriceText: Color(0xFF007AFF),
    bannerButton: Color(0xFF007AFF),
    bannerIcon: Color(0xFF333333),

    // dialog colors
    dialogBackground: Color(0xFFFFFFFF),
    dialogText: Color(0xFF000000),
    dialogCancelButton: Color(0x1A007AFF),

    // app bar colors
    appBarBackground: Color(0xFF007AFF),

    // bottom navigation bar colors
    bottomNavigationBarUnselectedColor: Color(0xFFBBBFD0),

    // scaffold colors
    scaffoldBackground: Color(0xFFFFFFFF),

    // custom button
    customButtonBackground: Color(0xffFBFCF6),
    customButtonText: Color(0xff007AFF),

    // bottom sheet colors
    bottomSheetBackground: Color(0xFFECEDF0),

    // card background
    cardBackground: Color(0xffFBFCF6),

    // indicator background
    indicatorBackground: Color(0x40000000),

    // cardBackground2
    cardBackground2: Color(0xffFFFFFF),

    // text field background
    textFieldBackground: Color(0xffF3F4F6),
  );

  /// The default dark theme colors.
  static const dark = ThemeColors(
    error: Color(0xFFFF2F22),
    onError: Color(0xFFF8F9FA),
    primary: Color(0xFF1E40AF),
    onPrimary: Color(0xFF1A1F22),
    secondary: Color.fromARGB(255, 44, 51, 56),
    onSecondary: Color(0xFFF8F9FA),
    success: Color(0xFF0CD678),
    onSuccess: Color(0xFFF8F9FA),
    surface: Color(0xFF1A1F22),
    onSurface: Color(0xFF202732),
    tealBlue: Color(0xFF026492),
    tertiary: Color(0xFF0CD678),
    tertiaryBold: Color.fromARGB(255, 9, 172, 96),
    onTertiary: Color(0xFFF8F9FA),

    // Base colors
    black: Color(0xFF000000),
    gray: Color(0xFFA0A9BA),
    transparent: Color(0x00000000),
    white: Color(0xFFF8F9FA),
    green: Color(0xFF099250),

    // Widget-specific colors
    buttonBorder: Color(0xFF41484C),
    buttonFill: Color(0xFF020617),
    divider: Color(0xFF41484C),
    primaryButtonFill: Color(0xFF344054),
    primaryButtonBorder: Color(0xFF1594CA),

    // text color
    text: Color(0xFFF8F9FA),

    // duty status circles colors
    breakC: Color(0xFFF79009),
    driveC: Color(0xFF12B76A),
    shiftC: Color(0xFF1594CA),
    cycleC: Color(0xFFFF2F22),

    // theme toggle color
    themeToggle: Color(0xFFF8F9FA),

    // banner colors
    bannerBackground: Color(0xFF1E293B),
    bannerText: Color(0xFFF8FAFC),
    bannerSecondaryText: Color(0xFFCBD5E1),
    bannerPriceText: Color(0xFF3B82F6),
    bannerButton: Color(0xFF1E40AF),
    bannerIcon: Color(0xFFFFFFFF),

    // dialog colors
    dialogBackground: Color(0xFF020617),
    dialogText: Color(0xFFFFFFFF),
    dialogCancelButton: Color(0xFF1E293B),

    // app bar colors
    appBarBackground: Color(0xFF020617),

    // bottom navigation bar colors
    bottomNavigationBarUnselectedColor: Color(0xFFBBBFD0),

    // scaffold colors
    scaffoldBackground: Color(0xFF0F172A),

    // custom button
    customButtonBackground: Color(0xff1E40AF),
    customButtonText: Color(0xffF8FAFC),

    // bottom sheet colors
    bottomSheetBackground: Color(0xFF1E293B),

    // card background
    cardBackground: Color(0xff0F172A),

    // indicator background
    indicatorBackground: Color(0x40FFFFFF),

    // cardBackground2
    cardBackground2: Color(0xffFFFFFF),

    // text field background
    textFieldBackground: Color(0xff1E293B),
  );

  @override
  ThemeColors copyWith({
    Color? error,
    Color? onError,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? success,
    Color? onSuccess,
    Color? surface,
    Color? onSurface,
    Color? tealBlue,
    Color? tertiary,
    Color? tertiaryBold,
    Color? onTertiary,

    // Base colors
    Color? black,
    Color? gray,
    Color? transparent,
    Color? white,
    Color? green,

    // Widget-specific colors
    Color? buttonBorder,
    Color? buttonFill,
    Color? divider,
    Color? primaryButtonFill,
    Color? primaryButtonBorder,

    // text color
    Color? text,

    // duty status circles colors
    Color? breakC,
    Color? driveC,
    Color? shiftC,
    Color? cycleC,
    Color? themeToggle,

    // banner colors
    Color? bannerBackground,
    Color? bannerText,
    Color? bannerSecondaryText,
    Color? bannerPriceText,
    Color? bannerButton,
    Color? bannerIcon,

    // dialog colors
    Color? dialogBackground,
    Color? dialogText,
    Color? dialogCancelButton,

    // app bar colors
    Color? appBarBackground,

    // bottom navigation bar colors
    Color? bottomNavigationBarUnselectedColor,

    // scaffold colors
    Color? scaffoldBackground,

    // custom button
    Color? customButtonBackground,
    Color? customButtonText,

    // bottom sheet colors
    Color? bottomSheetBackground,

    // card background
    Color? cardBackground,

    // indicator background
    Color? indicatorBackground,

    // cardBackground2
    Color? cardBackground2,

    // text field background
    Color? textFieldBackground,
  }) => ThemeColors(
    error: error ?? this.error,
    onError: onError ?? this.onError,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    tealBlue: tealBlue ?? this.tealBlue,
    tertiary: tertiary ?? this.tertiary,
    tertiaryBold: tertiaryBold ?? this.tertiaryBold,
    onTertiary: onTertiary ?? this.onTertiary,

    // Base colors
    black: black ?? this.black,
    gray: gray ?? this.gray,
    transparent: transparent ?? this.transparent,
    white: white ?? this.white,
    green: green ?? this.green,

    // Widget-specific colors
    buttonBorder: buttonBorder ?? this.buttonBorder,
    buttonFill: buttonFill ?? this.buttonFill,
    divider: divider ?? this.divider,
    primaryButtonFill: primaryButtonFill ?? this.primaryButtonFill,
    primaryButtonBorder: primaryButtonBorder ?? this.primaryButtonBorder,

    // text color
    text: text ?? this.text,

    // duty status circles colors
    breakC: breakC ?? this.breakC,
    driveC: driveC ?? this.driveC,
    shiftC: shiftC ?? this.shiftC,
    cycleC: cycleC ?? this.cycleC,
    themeToggle: themeToggle ?? this.themeToggle,

    // banner colors
    bannerBackground: bannerBackground ?? this.bannerBackground,
    bannerText: bannerText ?? this.bannerText,
    bannerSecondaryText: bannerSecondaryText ?? this.bannerSecondaryText,
    bannerPriceText: bannerPriceText ?? this.bannerPriceText,
    bannerButton: bannerButton ?? this.bannerButton,
    bannerIcon: bannerIcon ?? this.bannerIcon,

    // dialog colors
    dialogBackground: dialogBackground ?? this.dialogBackground,
    dialogText: dialogText ?? this.dialogText,
    dialogCancelButton: dialogCancelButton ?? this.dialogCancelButton,

    // app bar colors
    appBarBackground: appBarBackground ?? this.appBarBackground,

    // bottom navigation bar colors
    bottomNavigationBarUnselectedColor: bottomNavigationBarUnselectedColor ?? this.bottomNavigationBarUnselectedColor,

    // scaffold colors
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,

    // custom button
    customButtonBackground: customButtonBackground ?? this.customButtonBackground,
    customButtonText: customButtonText ?? this.customButtonText,

    // bottom sheet colors
    bottomSheetBackground: bottomSheetBackground ?? this.bottomSheetBackground,

    // card background
    cardBackground: cardBackground ?? this.cardBackground,

    // indicator background
    indicatorBackground: indicatorBackground ?? this.indicatorBackground,

    // cardBackground2
    cardBackground2: cardBackground2 ?? this.cardBackground2,

    // text field background
    textFieldBackground: textFieldBackground ?? this.textFieldBackground,
  );

  @override
  ThemeExtension<ThemeColors> lerp(ThemeExtension<ThemeColors>? other, double t) => other is! ThemeColors
      ? this
      : ThemeColors(
          error: Color.lerp(error, other.error, t)!,
          onError: Color.lerp(onError, other.onError, t)!,
          primary: Color.lerp(primary, other.primary, t)!,
          onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
          secondary: Color.lerp(secondary, other.secondary, t)!,
          onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
          success: Color.lerp(success, other.success, t)!,
          onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
          surface: Color.lerp(surface, other.surface, t)!,
          onSurface: Color.lerp(onSurface, other.onSurface, t)!,
          tealBlue: Color.lerp(tealBlue, other.tealBlue, t)!,
          tertiary: Color.lerp(tertiary, other.tertiary, t)!,
          tertiaryBold: Color.lerp(tertiaryBold, other.tertiaryBold, t)!,
          onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,

          // Base colors
          black: Color.lerp(black, other.black, t)!,
          gray: Color.lerp(gray, other.gray, t)!,
          transparent: Color.lerp(transparent, other.transparent, t)!,
          white: Color.lerp(white, other.white, t)!,
          green: Color.lerp(green, other.green, t)!,

          // Widget-specific colors
          buttonBorder: Color.lerp(buttonBorder, other.buttonBorder, t)!,
          buttonFill: Color.lerp(buttonFill, other.buttonFill, t)!,
          divider: Color.lerp(divider, other.divider, t)!,
          primaryButtonFill: Color.lerp(primaryButtonFill, other.primaryButtonFill, t)!,
          primaryButtonBorder: Color.lerp(primaryButtonBorder, other.primaryButtonBorder, t)!,

          // text color
          text: Color.lerp(text, other.text, t)!,

          // duty status circles colors
          breakC: Color.lerp(breakC, other.breakC, t)!,
          driveC: Color.lerp(driveC, other.driveC, t)!,
          shiftC: Color.lerp(shiftC, other.shiftC, t)!,
          cycleC: Color.lerp(cycleC, other.cycleC, t)!,
          themeToggle: Color.lerp(themeToggle, other.themeToggle, t)!,

          // banner colors
          bannerBackground: Color.lerp(bannerBackground, other.bannerBackground, t)!,
          bannerText: Color.lerp(bannerText, other.bannerText, t)!,
          bannerSecondaryText: Color.lerp(bannerSecondaryText, other.bannerSecondaryText, t)!,
          bannerPriceText: Color.lerp(bannerPriceText, other.bannerPriceText, t)!,
          bannerButton: Color.lerp(bannerButton, other.bannerButton, t)!,
          bannerIcon: Color.lerp(bannerIcon, other.bannerIcon, t)!,

          // dialog colors
          dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t)!,
          dialogText: Color.lerp(dialogText, other.dialogText, t)!,
          dialogCancelButton: Color.lerp(dialogCancelButton, other.dialogCancelButton, t)!,

          // app bar colors
          appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,

          // bottom navigation bar colors
          bottomNavigationBarUnselectedColor: Color.lerp(
            bottomNavigationBarUnselectedColor,
            other.bottomNavigationBarUnselectedColor,
            t,
          )!,

          // scaffold colors
          scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,

          // custom button
          customButtonBackground: Color.lerp(customButtonBackground, other.customButtonBackground, t)!,
          customButtonText: Color.lerp(customButtonText, other.customButtonText, t)!,

          // bottom sheet colors
          bottomSheetBackground: Color.lerp(bottomSheetBackground, other.bottomSheetBackground, t)!,

          // card background
          cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,

          // indicator background
          indicatorBackground: Color.lerp(indicatorBackground, other.indicatorBackground, t)!,

          // cardBackground2
          cardBackground2: Color.lerp(cardBackground2, other.cardBackground2, t)!,

          // text field background
          textFieldBackground: Color.lerp(textFieldBackground, other.textFieldBackground, t)!,
        );

  @override
  String toString() => 'ThemeColors{}';
}
