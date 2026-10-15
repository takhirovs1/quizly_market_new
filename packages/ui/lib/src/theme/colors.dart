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
    required this.appleGreen,
    required this.orange,

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
    required this.bottomSheetSurface,

    // selection pill button
    required this.selectionPillUnselectedBackground,

    // card background
    required this.cardBackground,

    // indicator background
    required this.indicatorBackground,

    // cardBackground2
    required this.cardBackground2,

    // text field background
    required this.textFieldBackground,

    // bottom navigation bar selected icon color
    required this.bottomNavigationBarSelectedColor,

    // profile icon color
    required this.profileIcon,
    required this.podiumGoldTop,
    required this.podiumGoldBottom,
    required this.podiumSilverTop,
    required this.podiumSilverBottom,
    required this.podiumBronzeTop,
    required this.podiumBronzeBottom,
    required this.shimmerGradientBase,
    required this.shimmerGradientHighlight,
    required this.initErrorToggleBorder,
    required this.initErrorToggleText,
    required this.referralBannerLime,
    required this.referralBannerGreen,
    required this.referralBannerMint,
    required this.sheetHandle,
    required this.homeHeroShadow,
    required this.homeHeroSkeleton,
    required this.referralGradientStart,
    required this.referralGradientEnd,
    required this.referralGiftShadow,
    required this.productCoverGradientStart,
    required this.violet,
    required this.sponsorOrange,
    required this.sponsorPink,
    required this.pinCodeBorder,
    required this.pinCodeFocused,
    required this.notificationIconBackground,
    required this.notificationError,
    required this.notificationSuccess,
    required this.chatSurface,
    required this.chatBorder,
    required this.chatWallpaperOverlay,
    required this.chatShimmerBase,
    required this.chatShimmerHighlight,
    required this.chatAccent,
    required this.chatBubbleUser,
    required this.chatBubbleAdmin,
    required this.chatTimeUser,
    required this.chatTimeAdmin,
    required this.chatHighlight,
    required this.chatDanger,
    required this.chatRetry,
    required this.chatReplyUserAccent,
    required this.chatReplyUserBackground,
    required this.chatReplyAdminBackground,
    required this.chatReplySubtitle,
    required this.chatImagePlaceholder,
    required this.chatImageErrorIcon,
    required this.chatMenuBackground,
    required this.chatMenuIcon,
    required this.chatBannerBackground,
    required this.chatEditAccent,
    required this.chatInputBackground,
    required this.chatInputBorder,
    required this.chatAttachIcon,
    required this.chatInputHint,
    required this.chatSendInactive,
    required this.paymentOrange,
    required this.paymentOrangeTint,
    required this.paymentCardShimmerBase,
    required this.paymentCardShimmerHighlight,
    required this.solvingWebGradientStart,
    required this.solvingWebGradientEnd,
    required this.solvingWebCardBorder,
    required this.optionBackground,
    required this.optionCorrectBackground,
    required this.optionWrongBackground,
    required this.resultGlowInner,
    required this.resultGlowOuter,
    required this.resultStar,
    required this.resultParticle,
    required this.resultSparkle,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.shimmerBaseSoft,
    required this.shimmerHighlightSoft,
    required this.answerCorrect,
    required this.answerWrong,
    required this.pureWhite,
    required this.pureBlack,
    required this.brandBlue,
    required this.brandCyan,
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

  /// Apple Green color light[0xFF34C759] dark[0xFF34C759]
  final Color appleGreen;

  /// Orange color light[0xFFF97316] dark[0xFFF97316]
  final Color orange;

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

  /// bottom navigation bar selected icon color light[0xFF007AFF] dark[0xFF007AFF]
  final Color bottomNavigationBarSelectedColor;

  /// Scaffold background color light[0xFFFFFFFF] dark[0xFF0F172A]
  final Color scaffoldBackground;

  /// Custom button background color light[0xffFBFCF6] dark[0xff1E40AF]
  final Color customButtonBackground;

  /// Custom button background color light[0xff007AFF] dark[0xffF8FAFC]
  final Color customButtonText;

  /// Bottom sheet background color light[0xFFECEDF0] dark[0xFF1E293B]
  final Color bottomSheetBackground;

  /// Bottom sheet surface color light[0xFFF4F4F4] dark[0xFF0F172A]
  final Color bottomSheetSurface;

  /// Selection pill button unselected background light[0xFFE6E6E6] dark[0xFF1E293B]
  final Color selectionPillUnselectedBackground;

  /// Card background color light[0xff0F172A] dark[0xffFFFFFF]
  final Color cardBackground;

  /// Indicator background color light[0x40000000] dark[0x40FFFFFF]
  final Color indicatorBackground;

  /// cardBackground2 light[0xffFFFFFF] dark[0xff1E293B]
  final Color cardBackground2;

  /// text field background color light[0xffF3F4F6] dark[0xff1E293B]
  final Color textFieldBackground;

  /// profile icon color light[0xFF007AFF] dark[0xFF007AFF]
  final Color profileIcon;

  /// Rating podium: 1st-place pedestal gradient top light[0xFFFFD66B] dark[0xFFFFD66B]
  final Color podiumGoldTop;

  /// Rating podium: 1st-place pedestal gradient bottom light[0xFFFF9500] dark[0xFFFF9500]
  final Color podiumGoldBottom;

  /// Rating podium: 2nd-place pedestal gradient top light[0xFFE3E7EE] dark[0xFFE3E7EE]
  final Color podiumSilverTop;

  /// Rating podium: 2nd-place pedestal gradient bottom light[0xFFC7CDD8] dark[0xFFC7CDD8]
  final Color podiumSilverBottom;

  /// Rating podium: 3rd-place pedestal gradient top light[0xFFFFD9B8] dark[0xFFFFD9B8]
  final Color podiumBronzeTop;

  /// Rating podium: 3rd-place pedestal gradient bottom light[0xFFF2A46B] dark[0xFFF2A46B]
  final Color podiumBronzeBottom;

  /// Helpers.shimmerGradient outer stops light[0xFFEBEBF4] dark[0xFF334155]
  final Color shimmerGradientBase;

  /// Helpers.shimmerGradient middle stop light[0xFFF4F4F4] dark[0xFF475569]
  final Color shimmerGradientHighlight;

  /// Initialization-failed screen: stack-trace toggle border light[0x76667085] dark[0x76667085]
  final Color initErrorToggleBorder;

  /// Initialization-failed screen: stack-trace toggle icon/text (on white button) light[0xFF1D2939] dark[0xFF1D2939]
  final Color initErrorToggleText;

  /// Animated referral banner gradient: lime (ends) light[0xFFD4FF00] dark[0xFFD4FF00]
  final Color referralBannerLime;

  /// Animated referral banner gradient: green (2nd/4th stop) light[0xFF8FFF3A] dark[0xFF8FFF3A]
  final Color referralBannerGreen;

  /// Animated referral banner gradient: mint (center) light[0xFF1BFF72] dark[0xFF1BFF72]
  final Color referralBannerMint;

  /// Bottom-sheet grabber handle (flashcard picker sheet) light[0xFFD1D1D6] dark[0xFF48484A]
  final Color sheetHandle;

  /// Home hero 'continue' card glow shadow light[0x4D3359F2] dark[0x4D3359F2]
  final Color homeHeroShadow;

  /// Home hero skeleton card background light[0xFFE4E7EE] dark[0xFF334155]
  final Color homeHeroSkeleton;

  /// Home referral card light gradient start (dark mode uses a computed tint; dark value is a fallback) light[0xFFFFF4E5] dark[0xFF2A2116]
  final Color referralGradientStart;

  /// Home referral card light gradient end light[0xFFFFE5EC] dark[0xFF2A1A20]
  final Color referralGradientEnd;

  /// Home referral card gift tile shadow (used at alpha 0.2) light[0xFFFF7333] dark[0xFFFF7333]
  final Color referralGiftShadow;

  /// Home product card cover gradient start (ends in violet) light[0xFFC9B8FF] dark[0xFFC9B8FF]
  final Color productCoverGradientStart;

  /// Violet accent in both themes (product cover gradient end, sponsor gradient) light[0xFF7B5CFF] dark[0xFF7B5CFF]
  final Color violet;

  /// Sponsor card gradient #2 start light[0xFFFF9500] dark[0xFFFF9500]
  final Color sponsorOrange;

  /// Sponsor card gradient #2 end light[0xFFFF3B6B] dark[0xFFFF3B6B]
  final Color sponsorPink;

  /// PinCode unfocused box border (was Colors.grey) light[0xFF9E9E9E] dark[0xFF9E9E9E]
  final Color pinCodeBorder;

  /// PinCode focused box border and cursor light[0xFF1C60E8] dark[0xFF1C60E8]
  final Color pinCodeFocused;

  /// CustomNotification default icon background (used at alpha 0.12) light[0xFF040A14] dark[0xFF040A14]
  final Color notificationIconBackground;

  /// CustomNotification error background / shadow light[0xFFD92D20] dark[0xFFD92D20]
  final Color notificationError;

  /// CustomNotification success background / shadow light[0xFF14C732] dark[0xFF14C732]
  final Color notificationSuccess;

  /// Support chat header / pinned banner / input bar background light[0xFFFFFFFF] dark[0xFF17212B]
  final Color chatSurface;

  /// Support chat separators and banner borders light[0xFFEBEDF2] dark[0xFF1E2936]
  final Color chatBorder;

  /// Support chat wallpaper tint (white 15% light / black 45% dark) light[0x26FFFFFF] dark[0x73000000]
  final Color chatWallpaperOverlay;

  /// Support chat loading shimmer base light[0xFFE2E8F0] dark[0xFF1C2733]
  final Color chatShimmerBase;

  /// Support chat loading shimmer highlight light[0xFFF1F5F9] dark[0xFF2C3947]
  final Color chatShimmerHighlight;

  /// Support chat accent (pinned/reply bars, send button, loaders) light[0xFF3B82F6] dark[0xFF3B82F6]
  final Color chatAccent;

  /// Support chat user message bubble light[0xFFFFFFFF] dark[0xFF182533]
  final Color chatBubbleUser;

  /// Support chat admin message bubble light[0xFFEEFFDE] dark[0xFF2B5278]
  final Color chatBubbleAdmin;

  /// Support chat timestamp in user bubble light[0xFF64748B] dark[0x99FFFFFF]
  final Color chatTimeUser;

  /// Support chat timestamp in admin bubble / read check marks light[0xFF5E8F57] dark[0xB3FFFFFF]
  final Color chatTimeAdmin;

  /// Support chat highlighted (scrolled-to) message background light[0x1A2196F3] dark[0x2E2196F3]
  final Color chatHighlight;

  /// Support chat failed-message icon and delete action light[0xFFFF5252] dark[0xFFFF5252]
  final Color chatDanger;

  /// Support chat retry action light[0xFF448AFF] dark[0xFF448AFF]
  final Color chatRetry;

  /// Reply preview line/title inside user bubble light[0xFF3B82F6] dark[0xFFFFFFFF]
  final Color chatReplyUserAccent;

  /// Reply preview background inside user bubble light[0x0F3B82F6] dark[0x1AFFFFFF]
  final Color chatReplyUserBackground;

  /// Reply preview background inside admin bubble light[0x0F3B82F6] dark[0x1A3B82F6]
  final Color chatReplyAdminBackground;

  /// Reply preview subtitle text light[0xFF64748B] dark[0xD9FFFFFF]
  final Color chatReplySubtitle;

  /// Support chat image placeholder / error background light[0xFFE8EDF5] dark[0xFF1E2936]
  final Color chatImagePlaceholder;

  /// Support chat broken-image icon light[0xFF9E9E9E] dark[0xFF9E9E9E]
  final Color chatImageErrorIcon;

  /// Support chat long-press menu background light[0xFFFFFFFF] dark[0xFF1E2C3A]
  final Color chatMenuBackground;

  /// Support chat long-press menu icons light[0xFF8A9BB0] dark[0xB3FFFFFF]
  final Color chatMenuIcon;

  /// Support chat reply/edit banner above input light[0xFFF5F7FB] dark[0xFF13172A]
  final Color chatBannerBackground;

  /// Support chat editing banner accent light[0xFF10B981] dark[0xFF10B981]
  final Color chatEditAccent;

  /// Support chat text field background light[0xFFF0F2F5] dark[0xFF1E2936]
  final Color chatInputBackground;

  /// Support chat text field / round button border light[0xFFDEE2E9] dark[0xFF2A3347]
  final Color chatInputBorder;

  /// Support chat attach button icon light[0xFF8A9BB0] dark[0x8CFFFFFF]
  final Color chatAttachIcon;

  /// Support chat input hint text light[0xFFA0A9BA] dark[0x59FFFFFF]
  final Color chatInputHint;

  /// Support chat inactive send icon light[0xFFA0A9BA] dark[0x4DFFFFFF]
  final Color chatSendInactive;

  /// Payment history refund/premium accent (was Colors.orange.shade600) light[0xFFFB8C00] dark[0xFFFB8C00]
  final Color paymentOrange;

  /// Payment history premium icon background (was Colors.orange.shade50) light[0xFFFFF3E0] dark[0xFFFFF3E0]
  final Color paymentOrangeTint;

  /// Profile payment card balance shimmer base light[0xFFE2E8F0] dark[0x40FFFFFF]
  final Color paymentCardShimmerBase;

  /// Profile payment card balance shimmer highlight light[0xFFF1F5F9] dark[0x60FFFFFF]
  final Color paymentCardShimmerHighlight;

  /// Test solving web layout: background gradient start color. light[0xFFF8FAFC] dark[0xFF090D16]
  final Color solvingWebGradientStart;

  /// Test solving web layout: background gradient end color. light[0xFFEEF2F6] dark[0xFF151B2C]
  final Color solvingWebGradientEnd;

  /// Test solving web layout: border of the centered content card (also used by its shimmer). light[0x0F000000] dark[0x1FFFFFFF]
  final Color solvingWebCardBorder;

  /// Answer option tile default background in test solving. light[0xFFF8F9FA] dark[0xFF0D1117]
  final Color optionBackground;

  /// Answer option tile background when the answer is correct. light[0xFFE8F5E9] dark[0xFF163C24]
  final Color optionCorrectBackground;

  /// Answer option tile background when the answer is wrong. light[0xFFFFEBEE] dark[0xFF3B1E1E]
  final Color optionWrongBackground;

  /// Test result screen radial glow inner stop (light: FFF2D0@0.95, dark: FFD13B@0.25). light[0xF2FFF2D0] dark[0x40FFD13B]
  final Color resultGlowInner;

  /// Test result screen radial glow second stop (light: FFF9E6@0.5, dark: FFB800@0.12). light[0x80FFF9E6] dark[0x1FFFB800]
  final Color resultGlowOuter;

  /// Test result screen golden sparkle stars. light[0xFFFFD13B] dark[0xFFFFD13B]
  final Color resultStar;

  /// Test result screen floating dot particles. light[0x60333333] dark[0x40FFFFFF]
  final Color resultParticle;

  /// Test result screen secondary (neutral) sparkles. light[0x80333333] dark[0x60FFFFFF]
  final Color resultSparkle;

  /// Shimmer/skeleton base color light[0xFFE2E8F0] dark[0xFF334155]
  final Color shimmerBase;

  /// Shimmer/skeleton highlight color light[0xFFF1F5F9] dark[0xFF475569]
  final Color shimmerHighlight;

  /// Shimmer base on translucent/card surfaces light[0xFFE2E8F0] dark[0x20FFFFFF]
  final Color shimmerBaseSoft;

  /// Shimmer highlight on translucent/card surfaces light[0xFFF1F5F9] dark[0x40FFFFFF]
  final Color shimmerHighlightSoft;

  /// Correct answer / positive accent light[0xFF43C04D] dark[0xFF43C04D]
  final Color answerCorrect;

  /// Wrong answer accent light[0xFFE53935] dark[0xFFE53935]
  final Color answerWrong;

  /// Pure white (text/icons on saturated or dark overlays) in both themes light[0xFFFFFFFF] dark[0xFFFFFFFF]
  final Color pureWhite;

  /// Pure black in both themes (shadows, scrims, media backgrounds) light[0xFF000000] dark[0xFF000000]
  final Color pureBlack;

  /// Brand gradient start / splash blue light[0xFF1C59F2] dark[0xFF1C59F2]
  final Color brandBlue;

  /// Brand gradient end cyan light[0xFF41D6FF] dark[0xFF41D6FF]
  final Color brandCyan;

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
    appleGreen: Color(0xFF34C759),
    orange: Color(0xFFF97316),

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
    bottomNavigationBarUnselectedColor: Color(0xFF64748B),

    bottomNavigationBarSelectedColor: Color(0xFF0E7FF1),

    // scaffold colors
    scaffoldBackground: Color(0xFFFFFFFF),

    // custom button
    customButtonBackground: Color(0xffFBFCF6),
    customButtonText: Color(0xff007AFF),

    // bottom sheet colors
    bottomSheetBackground: Color(0xFFECEDF0),
    bottomSheetSurface: Color(0xFFF4F4F4),

    // selection pill button
    selectionPillUnselectedBackground: Color(0xFFE6E6E6),

    // card background
    cardBackground: Color(0xffFBFCF6),

    // indicator background
    indicatorBackground: Color(0x40000000),

    // cardBackground2
    cardBackground2: Color(0xffFFFFFF),

    // text field background
    textFieldBackground: Color(0xffF3F4F6),

    // profile icon color
    profileIcon: Color(0xFF000000),
    podiumGoldTop: Color(0xFFFFD66B),
    podiumGoldBottom: Color(0xFFFF9500),
    podiumSilverTop: Color(0xFFE3E7EE),
    podiumSilverBottom: Color(0xFFC7CDD8),
    podiumBronzeTop: Color(0xFFFFD9B8),
    podiumBronzeBottom: Color(0xFFF2A46B),
    shimmerGradientBase: Color(0xFFEBEBF4),
    shimmerGradientHighlight: Color(0xFFF4F4F4),
    initErrorToggleBorder: Color(0x76667085),
    initErrorToggleText: Color(0xFF1D2939),
    referralBannerLime: Color(0xFFD4FF00),
    referralBannerGreen: Color(0xFF8FFF3A),
    referralBannerMint: Color(0xFF1BFF72),
    sheetHandle: Color(0xFFD1D1D6),
    homeHeroShadow: Color(0x4D3359F2),
    homeHeroSkeleton: Color(0xFFE4E7EE),
    referralGradientStart: Color(0xFFFFF4E5),
    referralGradientEnd: Color(0xFFFFE5EC),
    referralGiftShadow: Color(0xFFFF7333),
    productCoverGradientStart: Color(0xFFC9B8FF),
    violet: Color(0xFF7B5CFF),
    sponsorOrange: Color(0xFFFF9500),
    sponsorPink: Color(0xFFFF3B6B),
    pinCodeBorder: Color(0xFF9E9E9E),
    pinCodeFocused: Color(0xFF1C60E8),
    notificationIconBackground: Color(0xFF040A14),
    notificationError: Color(0xFFD92D20),
    notificationSuccess: Color(0xFF14C732),
    chatSurface: Color(0xFFFFFFFF),
    chatBorder: Color(0xFFEBEDF2),
    chatWallpaperOverlay: Color(0x26FFFFFF),
    chatShimmerBase: Color(0xFFE2E8F0),
    chatShimmerHighlight: Color(0xFFF1F5F9),
    chatAccent: Color(0xFF3B82F6),
    chatBubbleUser: Color(0xFFFFFFFF),
    chatBubbleAdmin: Color(0xFFEEFFDE),
    chatTimeUser: Color(0xFF64748B),
    chatTimeAdmin: Color(0xFF5E8F57),
    chatHighlight: Color(0x1A2196F3),
    chatDanger: Color(0xFFFF5252),
    chatRetry: Color(0xFF448AFF),
    chatReplyUserAccent: Color(0xFF3B82F6),
    chatReplyUserBackground: Color(0x0F3B82F6),
    chatReplyAdminBackground: Color(0x0F3B82F6),
    chatReplySubtitle: Color(0xFF64748B),
    chatImagePlaceholder: Color(0xFFE8EDF5),
    chatImageErrorIcon: Color(0xFF9E9E9E),
    chatMenuBackground: Color(0xFFFFFFFF),
    chatMenuIcon: Color(0xFF8A9BB0),
    chatBannerBackground: Color(0xFFF5F7FB),
    chatEditAccent: Color(0xFF10B981),
    chatInputBackground: Color(0xFFF0F2F5),
    chatInputBorder: Color(0xFFDEE2E9),
    chatAttachIcon: Color(0xFF8A9BB0),
    chatInputHint: Color(0xFFA0A9BA),
    chatSendInactive: Color(0xFFA0A9BA),
    paymentOrange: Color(0xFFFB8C00),
    paymentOrangeTint: Color(0xFFFFF3E0),
    paymentCardShimmerBase: Color(0xFFE2E8F0),
    paymentCardShimmerHighlight: Color(0xFFF1F5F9),
    solvingWebGradientStart: Color(0xFFF8FAFC),
    solvingWebGradientEnd: Color(0xFFEEF2F6),
    solvingWebCardBorder: Color(0x0F000000),
    optionBackground: Color(0xFFF8F9FA),
    optionCorrectBackground: Color(0xFFE8F5E9),
    optionWrongBackground: Color(0xFFFFEBEE),
    resultGlowInner: Color(0xF2FFF2D0),
    resultGlowOuter: Color(0x80FFF9E6),
    resultStar: Color(0xFFFFD13B),
    resultParticle: Color(0x60333333),
    resultSparkle: Color(0x80333333),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF1F5F9),
    shimmerBaseSoft: Color(0xFFE2E8F0),
    shimmerHighlightSoft: Color(0xFFF1F5F9),
    answerCorrect: Color(0xFF43C04D),
    answerWrong: Color(0xFFE53935),
    pureWhite: Color(0xFFFFFFFF),
    pureBlack: Color(0xFF000000),
    brandBlue: Color(0xFF1C59F2),
    brandCyan: Color(0xFF41D6FF),
  );

  static const dark = ThemeColors(
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    primary: Color(0xFF3B82F6),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF1E2A3A),
    onSecondary: Color(0xFFFFFFFF),
    success: Color(0xFF22C55E),
    onSuccess: Color(0xFFFFFFFF),
    surface: Color(0xFF161B27),
    onSurface: Color(0xFFFFFFFF),
    tealBlue: Color(0xFF026492),
    tertiary: Color(0xFF22C55E),
    tertiaryBold: Color(0xFF16A34A),
    onTertiary: Color(0xFFFFFFFF),

    // Base colors
    black: Color(0xFF000000),
    gray: Color(0xFF8A9BB0),
    transparent: Color(0x00000000),
    white: Color(0xFFFFFFFF),
    green: Color(0xFF22C55E),
    appleGreen: Color(0xFF34C759),
    orange: Color(0xFFF97316),

    // Widget-specific colors
    buttonBorder: Color(0x333B82F6),
    buttonFill: Color(0xFF121626),
    divider: Color(0xFF2A3347),
    primaryButtonFill: Color(0xFF3B82F6),
    primaryButtonBorder: Color(0xFF3B82F6),

    // text color
    text: Color(0xFFFFFFFF),

    // duty status circles colors
    breakC: Color(0xFFF79009),
    driveC: Color(0xFF12B76A),
    shiftC: Color(0xFF3B82F6),
    cycleC: Color(0xFFEF4444),

    // theme toggle color
    themeToggle: Color(0xFFFFFFFF),

    // banner colors
    bannerBackground: Color(0xFF121626),
    bannerText: Color(0xFFFFFFFF),
    bannerSecondaryText: Color(0xFF8A9BB0),
    bannerPriceText: Color(0xFF3B82F6),
    bannerButton: Color(0xFF3B82F6),
    bannerIcon: Color(0xFFFFFFFF),

    // dialog colors
    dialogBackground: Color(0xFF121626),
    dialogText: Color(0xFFFFFFFF),
    dialogCancelButton: Color(0xFF1E2A3A),

    // app bar colors
    appBarBackground: Color(0xFF121626),

    // bottom navigation bar colors
    bottomNavigationBarUnselectedColor: Color(0xFF4A5568),

    bottomNavigationBarSelectedColor: Color(0xFF3B82F6),

    // scaffold colors
    scaffoldBackground: Color(0xFF0D1117),

    // custom button
    customButtonBackground: Color(0xFF3B82F6),
    customButtonText: Color(0xFFFFFFFF),

    // bottom sheet colors
    bottomSheetBackground: Color(0xFF161B27),
    bottomSheetSurface: Color(0xFF0D1117),

    // selection pill button
    selectionPillUnselectedBackground: Color(0xFF1E2A3A),

    // card background
    cardBackground: Color(0xFF161B27),

    // indicator background
    indicatorBackground: Color(0x40FFFFFF),

    // cardBackground2
    cardBackground2: Color(0xFF1E2535),

    // text field background
    textFieldBackground: Color(0xFF161B27),

    // profile icon color
    profileIcon: Color(0xFF3B82F6),
    podiumGoldTop: Color(0xFFFFD66B),
    podiumGoldBottom: Color(0xFFFF9500),
    podiumSilverTop: Color(0xFFE3E7EE),
    podiumSilverBottom: Color(0xFFC7CDD8),
    podiumBronzeTop: Color(0xFFFFD9B8),
    podiumBronzeBottom: Color(0xFFF2A46B),
    shimmerGradientBase: Color(0xFF334155),
    shimmerGradientHighlight: Color(0xFF475569),
    initErrorToggleBorder: Color(0x76667085),
    initErrorToggleText: Color(0xFF1D2939),
    referralBannerLime: Color(0xFFD4FF00),
    referralBannerGreen: Color(0xFF8FFF3A),
    referralBannerMint: Color(0xFF1BFF72),
    sheetHandle: Color(0xFF48484A),
    homeHeroShadow: Color(0x4D3359F2),
    homeHeroSkeleton: Color(0xFF334155),
    referralGradientStart: Color(0xFF2A2116),
    referralGradientEnd: Color(0xFF2A1A20),
    referralGiftShadow: Color(0xFFFF7333),
    productCoverGradientStart: Color(0xFFC9B8FF),
    violet: Color(0xFF7B5CFF),
    sponsorOrange: Color(0xFFFF9500),
    sponsorPink: Color(0xFFFF3B6B),
    pinCodeBorder: Color(0xFF9E9E9E),
    pinCodeFocused: Color(0xFF1C60E8),
    notificationIconBackground: Color(0xFF040A14),
    notificationError: Color(0xFFD92D20),
    notificationSuccess: Color(0xFF14C732),
    chatSurface: Color(0xFF17212B),
    chatBorder: Color(0xFF1E2936),
    chatWallpaperOverlay: Color(0x73000000),
    chatShimmerBase: Color(0xFF1C2733),
    chatShimmerHighlight: Color(0xFF2C3947),
    chatAccent: Color(0xFF3B82F6),
    chatBubbleUser: Color(0xFF182533),
    chatBubbleAdmin: Color(0xFF2B5278),
    chatTimeUser: Color(0x99FFFFFF),
    chatTimeAdmin: Color(0xB3FFFFFF),
    chatHighlight: Color(0x2E2196F3),
    chatDanger: Color(0xFFFF5252),
    chatRetry: Color(0xFF448AFF),
    chatReplyUserAccent: Color(0xFFFFFFFF),
    chatReplyUserBackground: Color(0x1AFFFFFF),
    chatReplyAdminBackground: Color(0x1A3B82F6),
    chatReplySubtitle: Color(0xD9FFFFFF),
    chatImagePlaceholder: Color(0xFF1E2936),
    chatImageErrorIcon: Color(0xFF9E9E9E),
    chatMenuBackground: Color(0xFF1E2C3A),
    chatMenuIcon: Color(0xB3FFFFFF),
    chatBannerBackground: Color(0xFF13172A),
    chatEditAccent: Color(0xFF10B981),
    chatInputBackground: Color(0xFF1E2936),
    chatInputBorder: Color(0xFF2A3347),
    chatAttachIcon: Color(0x8CFFFFFF),
    chatInputHint: Color(0x59FFFFFF),
    chatSendInactive: Color(0x4DFFFFFF),
    paymentOrange: Color(0xFFFB8C00),
    paymentOrangeTint: Color(0xFFFFF3E0),
    paymentCardShimmerBase: Color(0x40FFFFFF),
    paymentCardShimmerHighlight: Color(0x60FFFFFF),
    solvingWebGradientStart: Color(0xFF090D16),
    solvingWebGradientEnd: Color(0xFF151B2C),
    solvingWebCardBorder: Color(0x1FFFFFFF),
    optionBackground: Color(0xFF0D1117),
    optionCorrectBackground: Color(0xFF163C24),
    optionWrongBackground: Color(0xFF3B1E1E),
    resultGlowInner: Color(0x40FFD13B),
    resultGlowOuter: Color(0x1FFFB800),
    resultStar: Color(0xFFFFD13B),
    resultParticle: Color(0x40FFFFFF),
    resultSparkle: Color(0x60FFFFFF),
    shimmerBase: Color(0xFF334155),
    shimmerHighlight: Color(0xFF475569),
    shimmerBaseSoft: Color(0x20FFFFFF),
    shimmerHighlightSoft: Color(0x40FFFFFF),
    answerCorrect: Color(0xFF43C04D),
    answerWrong: Color(0xFFE53935),
    pureWhite: Color(0xFFFFFFFF),
    pureBlack: Color(0xFF000000),
    brandBlue: Color(0xFF1C59F2),
    brandCyan: Color(0xFF41D6FF),
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
    Color? appleGreen,
    Color? orange,

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

    Color? bottomNavigationBarSelectedColor,

    // scaffold colors
    Color? scaffoldBackground,

    // custom button
    Color? customButtonBackground,
    Color? customButtonText,

    // bottom sheet colors
    Color? bottomSheetBackground,
    Color? bottomSheetSurface,

    // selection pill button
    Color? selectionPillUnselectedBackground,

    // card background
    Color? cardBackground,

    // indicator background
    Color? indicatorBackground,

    // cardBackground2
    Color? cardBackground2,

    // text field background
    Color? textFieldBackground,

    // profile icon color
    Color? profileIcon,
    Color? podiumGoldTop,
    Color? podiumGoldBottom,
    Color? podiumSilverTop,
    Color? podiumSilverBottom,
    Color? podiumBronzeTop,
    Color? podiumBronzeBottom,
    Color? shimmerGradientBase,
    Color? shimmerGradientHighlight,
    Color? initErrorToggleBorder,
    Color? initErrorToggleText,
    Color? referralBannerLime,
    Color? referralBannerGreen,
    Color? referralBannerMint,
    Color? sheetHandle,
    Color? homeHeroShadow,
    Color? homeHeroSkeleton,
    Color? referralGradientStart,
    Color? referralGradientEnd,
    Color? referralGiftShadow,
    Color? productCoverGradientStart,
    Color? violet,
    Color? sponsorOrange,
    Color? sponsorPink,
    Color? pinCodeBorder,
    Color? pinCodeFocused,
    Color? notificationIconBackground,
    Color? notificationError,
    Color? notificationSuccess,
    Color? chatSurface,
    Color? chatBorder,
    Color? chatWallpaperOverlay,
    Color? chatShimmerBase,
    Color? chatShimmerHighlight,
    Color? chatAccent,
    Color? chatBubbleUser,
    Color? chatBubbleAdmin,
    Color? chatTimeUser,
    Color? chatTimeAdmin,
    Color? chatHighlight,
    Color? chatDanger,
    Color? chatRetry,
    Color? chatReplyUserAccent,
    Color? chatReplyUserBackground,
    Color? chatReplyAdminBackground,
    Color? chatReplySubtitle,
    Color? chatImagePlaceholder,
    Color? chatImageErrorIcon,
    Color? chatMenuBackground,
    Color? chatMenuIcon,
    Color? chatBannerBackground,
    Color? chatEditAccent,
    Color? chatInputBackground,
    Color? chatInputBorder,
    Color? chatAttachIcon,
    Color? chatInputHint,
    Color? chatSendInactive,
    Color? paymentOrange,
    Color? paymentOrangeTint,
    Color? paymentCardShimmerBase,
    Color? paymentCardShimmerHighlight,
    Color? solvingWebGradientStart,
    Color? solvingWebGradientEnd,
    Color? solvingWebCardBorder,
    Color? optionBackground,
    Color? optionCorrectBackground,
    Color? optionWrongBackground,
    Color? resultGlowInner,
    Color? resultGlowOuter,
    Color? resultStar,
    Color? resultParticle,
    Color? resultSparkle,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? shimmerBaseSoft,
    Color? shimmerHighlightSoft,
    Color? answerCorrect,
    Color? answerWrong,
    Color? pureWhite,
    Color? pureBlack,
    Color? brandBlue,
    Color? brandCyan,
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
    appleGreen: appleGreen ?? this.appleGreen,
    orange: orange ?? this.orange,

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

    bottomNavigationBarSelectedColor: bottomNavigationBarSelectedColor ?? this.bottomNavigationBarSelectedColor,

    // scaffold colors
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,

    // custom button
    customButtonBackground: customButtonBackground ?? this.customButtonBackground,
    customButtonText: customButtonText ?? this.customButtonText,

    // bottom sheet colors
    bottomSheetBackground: bottomSheetBackground ?? this.bottomSheetBackground,
    bottomSheetSurface: bottomSheetSurface ?? this.bottomSheetSurface,
    selectionPillUnselectedBackground: selectionPillUnselectedBackground ?? this.selectionPillUnselectedBackground,

    // card background
    cardBackground: cardBackground ?? this.cardBackground,

    // indicator background
    indicatorBackground: indicatorBackground ?? this.indicatorBackground,

    // cardBackground2
    cardBackground2: cardBackground2 ?? this.cardBackground2,

    // text field background
    textFieldBackground: textFieldBackground ?? this.textFieldBackground,

    // profile icon color
    profileIcon: profileIcon ?? this.profileIcon,
    podiumGoldTop: podiumGoldTop ?? this.podiumGoldTop,
    podiumGoldBottom: podiumGoldBottom ?? this.podiumGoldBottom,
    podiumSilverTop: podiumSilverTop ?? this.podiumSilverTop,
    podiumSilverBottom: podiumSilverBottom ?? this.podiumSilverBottom,
    podiumBronzeTop: podiumBronzeTop ?? this.podiumBronzeTop,
    podiumBronzeBottom: podiumBronzeBottom ?? this.podiumBronzeBottom,
    shimmerGradientBase: shimmerGradientBase ?? this.shimmerGradientBase,
    shimmerGradientHighlight: shimmerGradientHighlight ?? this.shimmerGradientHighlight,
    initErrorToggleBorder: initErrorToggleBorder ?? this.initErrorToggleBorder,
    initErrorToggleText: initErrorToggleText ?? this.initErrorToggleText,
    referralBannerLime: referralBannerLime ?? this.referralBannerLime,
    referralBannerGreen: referralBannerGreen ?? this.referralBannerGreen,
    referralBannerMint: referralBannerMint ?? this.referralBannerMint,
    sheetHandle: sheetHandle ?? this.sheetHandle,
    homeHeroShadow: homeHeroShadow ?? this.homeHeroShadow,
    homeHeroSkeleton: homeHeroSkeleton ?? this.homeHeroSkeleton,
    referralGradientStart: referralGradientStart ?? this.referralGradientStart,
    referralGradientEnd: referralGradientEnd ?? this.referralGradientEnd,
    referralGiftShadow: referralGiftShadow ?? this.referralGiftShadow,
    productCoverGradientStart: productCoverGradientStart ?? this.productCoverGradientStart,
    violet: violet ?? this.violet,
    sponsorOrange: sponsorOrange ?? this.sponsorOrange,
    sponsorPink: sponsorPink ?? this.sponsorPink,
    pinCodeBorder: pinCodeBorder ?? this.pinCodeBorder,
    pinCodeFocused: pinCodeFocused ?? this.pinCodeFocused,
    notificationIconBackground: notificationIconBackground ?? this.notificationIconBackground,
    notificationError: notificationError ?? this.notificationError,
    notificationSuccess: notificationSuccess ?? this.notificationSuccess,
    chatSurface: chatSurface ?? this.chatSurface,
    chatBorder: chatBorder ?? this.chatBorder,
    chatWallpaperOverlay: chatWallpaperOverlay ?? this.chatWallpaperOverlay,
    chatShimmerBase: chatShimmerBase ?? this.chatShimmerBase,
    chatShimmerHighlight: chatShimmerHighlight ?? this.chatShimmerHighlight,
    chatAccent: chatAccent ?? this.chatAccent,
    chatBubbleUser: chatBubbleUser ?? this.chatBubbleUser,
    chatBubbleAdmin: chatBubbleAdmin ?? this.chatBubbleAdmin,
    chatTimeUser: chatTimeUser ?? this.chatTimeUser,
    chatTimeAdmin: chatTimeAdmin ?? this.chatTimeAdmin,
    chatHighlight: chatHighlight ?? this.chatHighlight,
    chatDanger: chatDanger ?? this.chatDanger,
    chatRetry: chatRetry ?? this.chatRetry,
    chatReplyUserAccent: chatReplyUserAccent ?? this.chatReplyUserAccent,
    chatReplyUserBackground: chatReplyUserBackground ?? this.chatReplyUserBackground,
    chatReplyAdminBackground: chatReplyAdminBackground ?? this.chatReplyAdminBackground,
    chatReplySubtitle: chatReplySubtitle ?? this.chatReplySubtitle,
    chatImagePlaceholder: chatImagePlaceholder ?? this.chatImagePlaceholder,
    chatImageErrorIcon: chatImageErrorIcon ?? this.chatImageErrorIcon,
    chatMenuBackground: chatMenuBackground ?? this.chatMenuBackground,
    chatMenuIcon: chatMenuIcon ?? this.chatMenuIcon,
    chatBannerBackground: chatBannerBackground ?? this.chatBannerBackground,
    chatEditAccent: chatEditAccent ?? this.chatEditAccent,
    chatInputBackground: chatInputBackground ?? this.chatInputBackground,
    chatInputBorder: chatInputBorder ?? this.chatInputBorder,
    chatAttachIcon: chatAttachIcon ?? this.chatAttachIcon,
    chatInputHint: chatInputHint ?? this.chatInputHint,
    chatSendInactive: chatSendInactive ?? this.chatSendInactive,
    paymentOrange: paymentOrange ?? this.paymentOrange,
    paymentOrangeTint: paymentOrangeTint ?? this.paymentOrangeTint,
    paymentCardShimmerBase: paymentCardShimmerBase ?? this.paymentCardShimmerBase,
    paymentCardShimmerHighlight: paymentCardShimmerHighlight ?? this.paymentCardShimmerHighlight,
    solvingWebGradientStart: solvingWebGradientStart ?? this.solvingWebGradientStart,
    solvingWebGradientEnd: solvingWebGradientEnd ?? this.solvingWebGradientEnd,
    solvingWebCardBorder: solvingWebCardBorder ?? this.solvingWebCardBorder,
    optionBackground: optionBackground ?? this.optionBackground,
    optionCorrectBackground: optionCorrectBackground ?? this.optionCorrectBackground,
    optionWrongBackground: optionWrongBackground ?? this.optionWrongBackground,
    resultGlowInner: resultGlowInner ?? this.resultGlowInner,
    resultGlowOuter: resultGlowOuter ?? this.resultGlowOuter,
    resultStar: resultStar ?? this.resultStar,
    resultParticle: resultParticle ?? this.resultParticle,
    resultSparkle: resultSparkle ?? this.resultSparkle,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    shimmerBaseSoft: shimmerBaseSoft ?? this.shimmerBaseSoft,
    shimmerHighlightSoft: shimmerHighlightSoft ?? this.shimmerHighlightSoft,
    answerCorrect: answerCorrect ?? this.answerCorrect,
    answerWrong: answerWrong ?? this.answerWrong,
    pureWhite: pureWhite ?? this.pureWhite,
    pureBlack: pureBlack ?? this.pureBlack,
    brandBlue: brandBlue ?? this.brandBlue,
    brandCyan: brandCyan ?? this.brandCyan,
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
          appleGreen: Color.lerp(appleGreen, other.appleGreen, t)!,
          orange: Color.lerp(orange, other.orange, t)!,

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

          // bottom navigation bar selected icon color
          bottomNavigationBarSelectedColor: Color.lerp(
            bottomNavigationBarSelectedColor,
            other.bottomNavigationBarSelectedColor,
            t,
          )!,

          // scaffold colors
          scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,

          // custom button
          customButtonBackground: Color.lerp(customButtonBackground, other.customButtonBackground, t)!,
          customButtonText: Color.lerp(customButtonText, other.customButtonText, t)!,

          // bottom sheet colors
          bottomSheetBackground: Color.lerp(bottomSheetBackground, other.bottomSheetBackground, t)!,
          bottomSheetSurface: Color.lerp(bottomSheetSurface, other.bottomSheetSurface, t)!,
          selectionPillUnselectedBackground: Color.lerp(
            selectionPillUnselectedBackground,
            other.selectionPillUnselectedBackground,
            t,
          )!,

          // card background
          cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,

          // indicator background
          indicatorBackground: Color.lerp(indicatorBackground, other.indicatorBackground, t)!,

          // cardBackground2
          cardBackground2: Color.lerp(cardBackground2, other.cardBackground2, t)!,

          // text field background
          textFieldBackground: Color.lerp(textFieldBackground, other.textFieldBackground, t)!,

          // profile icon color
          profileIcon: Color.lerp(profileIcon, other.profileIcon, t)!,
          podiumGoldTop: Color.lerp(podiumGoldTop, other.podiumGoldTop, t)!,
          podiumGoldBottom: Color.lerp(podiumGoldBottom, other.podiumGoldBottom, t)!,
          podiumSilverTop: Color.lerp(podiumSilverTop, other.podiumSilverTop, t)!,
          podiumSilverBottom: Color.lerp(podiumSilverBottom, other.podiumSilverBottom, t)!,
          podiumBronzeTop: Color.lerp(podiumBronzeTop, other.podiumBronzeTop, t)!,
          podiumBronzeBottom: Color.lerp(podiumBronzeBottom, other.podiumBronzeBottom, t)!,
          shimmerGradientBase: Color.lerp(shimmerGradientBase, other.shimmerGradientBase, t)!,
          shimmerGradientHighlight: Color.lerp(shimmerGradientHighlight, other.shimmerGradientHighlight, t)!,
          initErrorToggleBorder: Color.lerp(initErrorToggleBorder, other.initErrorToggleBorder, t)!,
          initErrorToggleText: Color.lerp(initErrorToggleText, other.initErrorToggleText, t)!,
          referralBannerLime: Color.lerp(referralBannerLime, other.referralBannerLime, t)!,
          referralBannerGreen: Color.lerp(referralBannerGreen, other.referralBannerGreen, t)!,
          referralBannerMint: Color.lerp(referralBannerMint, other.referralBannerMint, t)!,
          sheetHandle: Color.lerp(sheetHandle, other.sheetHandle, t)!,
          homeHeroShadow: Color.lerp(homeHeroShadow, other.homeHeroShadow, t)!,
          homeHeroSkeleton: Color.lerp(homeHeroSkeleton, other.homeHeroSkeleton, t)!,
          referralGradientStart: Color.lerp(referralGradientStart, other.referralGradientStart, t)!,
          referralGradientEnd: Color.lerp(referralGradientEnd, other.referralGradientEnd, t)!,
          referralGiftShadow: Color.lerp(referralGiftShadow, other.referralGiftShadow, t)!,
          productCoverGradientStart: Color.lerp(productCoverGradientStart, other.productCoverGradientStart, t)!,
          violet: Color.lerp(violet, other.violet, t)!,
          sponsorOrange: Color.lerp(sponsorOrange, other.sponsorOrange, t)!,
          sponsorPink: Color.lerp(sponsorPink, other.sponsorPink, t)!,
          pinCodeBorder: Color.lerp(pinCodeBorder, other.pinCodeBorder, t)!,
          pinCodeFocused: Color.lerp(pinCodeFocused, other.pinCodeFocused, t)!,
          notificationIconBackground: Color.lerp(notificationIconBackground, other.notificationIconBackground, t)!,
          notificationError: Color.lerp(notificationError, other.notificationError, t)!,
          notificationSuccess: Color.lerp(notificationSuccess, other.notificationSuccess, t)!,
          chatSurface: Color.lerp(chatSurface, other.chatSurface, t)!,
          chatBorder: Color.lerp(chatBorder, other.chatBorder, t)!,
          chatWallpaperOverlay: Color.lerp(chatWallpaperOverlay, other.chatWallpaperOverlay, t)!,
          chatShimmerBase: Color.lerp(chatShimmerBase, other.chatShimmerBase, t)!,
          chatShimmerHighlight: Color.lerp(chatShimmerHighlight, other.chatShimmerHighlight, t)!,
          chatAccent: Color.lerp(chatAccent, other.chatAccent, t)!,
          chatBubbleUser: Color.lerp(chatBubbleUser, other.chatBubbleUser, t)!,
          chatBubbleAdmin: Color.lerp(chatBubbleAdmin, other.chatBubbleAdmin, t)!,
          chatTimeUser: Color.lerp(chatTimeUser, other.chatTimeUser, t)!,
          chatTimeAdmin: Color.lerp(chatTimeAdmin, other.chatTimeAdmin, t)!,
          chatHighlight: Color.lerp(chatHighlight, other.chatHighlight, t)!,
          chatDanger: Color.lerp(chatDanger, other.chatDanger, t)!,
          chatRetry: Color.lerp(chatRetry, other.chatRetry, t)!,
          chatReplyUserAccent: Color.lerp(chatReplyUserAccent, other.chatReplyUserAccent, t)!,
          chatReplyUserBackground: Color.lerp(chatReplyUserBackground, other.chatReplyUserBackground, t)!,
          chatReplyAdminBackground: Color.lerp(chatReplyAdminBackground, other.chatReplyAdminBackground, t)!,
          chatReplySubtitle: Color.lerp(chatReplySubtitle, other.chatReplySubtitle, t)!,
          chatImagePlaceholder: Color.lerp(chatImagePlaceholder, other.chatImagePlaceholder, t)!,
          chatImageErrorIcon: Color.lerp(chatImageErrorIcon, other.chatImageErrorIcon, t)!,
          chatMenuBackground: Color.lerp(chatMenuBackground, other.chatMenuBackground, t)!,
          chatMenuIcon: Color.lerp(chatMenuIcon, other.chatMenuIcon, t)!,
          chatBannerBackground: Color.lerp(chatBannerBackground, other.chatBannerBackground, t)!,
          chatEditAccent: Color.lerp(chatEditAccent, other.chatEditAccent, t)!,
          chatInputBackground: Color.lerp(chatInputBackground, other.chatInputBackground, t)!,
          chatInputBorder: Color.lerp(chatInputBorder, other.chatInputBorder, t)!,
          chatAttachIcon: Color.lerp(chatAttachIcon, other.chatAttachIcon, t)!,
          chatInputHint: Color.lerp(chatInputHint, other.chatInputHint, t)!,
          chatSendInactive: Color.lerp(chatSendInactive, other.chatSendInactive, t)!,
          paymentOrange: Color.lerp(paymentOrange, other.paymentOrange, t)!,
          paymentOrangeTint: Color.lerp(paymentOrangeTint, other.paymentOrangeTint, t)!,
          paymentCardShimmerBase: Color.lerp(paymentCardShimmerBase, other.paymentCardShimmerBase, t)!,
          paymentCardShimmerHighlight: Color.lerp(paymentCardShimmerHighlight, other.paymentCardShimmerHighlight, t)!,
          solvingWebGradientStart: Color.lerp(solvingWebGradientStart, other.solvingWebGradientStart, t)!,
          solvingWebGradientEnd: Color.lerp(solvingWebGradientEnd, other.solvingWebGradientEnd, t)!,
          solvingWebCardBorder: Color.lerp(solvingWebCardBorder, other.solvingWebCardBorder, t)!,
          optionBackground: Color.lerp(optionBackground, other.optionBackground, t)!,
          optionCorrectBackground: Color.lerp(optionCorrectBackground, other.optionCorrectBackground, t)!,
          optionWrongBackground: Color.lerp(optionWrongBackground, other.optionWrongBackground, t)!,
          resultGlowInner: Color.lerp(resultGlowInner, other.resultGlowInner, t)!,
          resultGlowOuter: Color.lerp(resultGlowOuter, other.resultGlowOuter, t)!,
          resultStar: Color.lerp(resultStar, other.resultStar, t)!,
          resultParticle: Color.lerp(resultParticle, other.resultParticle, t)!,
          resultSparkle: Color.lerp(resultSparkle, other.resultSparkle, t)!,
          shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
          shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
          shimmerBaseSoft: Color.lerp(shimmerBaseSoft, other.shimmerBaseSoft, t)!,
          shimmerHighlightSoft: Color.lerp(shimmerHighlightSoft, other.shimmerHighlightSoft, t)!,
          answerCorrect: Color.lerp(answerCorrect, other.answerCorrect, t)!,
          answerWrong: Color.lerp(answerWrong, other.answerWrong, t)!,
          pureWhite: Color.lerp(pureWhite, other.pureWhite, t)!,
          pureBlack: Color.lerp(pureBlack, other.pureBlack, t)!,
          brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
          brandCyan: Color.lerp(brandCyan, other.brandCyan, t)!,
        );

  @override
  String toString() => 'ThemeColors{}';
}
