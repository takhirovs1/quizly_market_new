import 'package:flutter/material.dart';

import '../gen/fonts.gen.dart';

/// Typography — barcha matn stillari [FontFamily.nunito] va [FontFamily.sFProDisplay] asosida.
///
/// **AppTextStyle enum:** displayLarge, displayMedium, displaySmall, headlineLarge,
/// headlineBold, headlineMedium, headlineSmall, titleLarge, titleBold18, titleBold,
/// titleSemiBold16, bodyLarge18, titleMedium, titleSmall, bodyLarge, bodyMedium,
/// bodySmall, labelLarge, labelMedium, labelSmall, small.
///
/// **AppTypography (context.x.textStyle) variantlari (Nunito):**
/// | Variant   | Size | Weight | Izoh            |
/// |-----------|------|--------|------------------|
/// | w400s57   | 57   | 400    | Display Large    |
/// | w400s45   | 45   | 400    | Display Medium   |
/// | w400s36   | 36   | 400    | Display Small    |
/// | w400s32   | 32   | 400    | Headline Large   |
/// | w700s28   | 28   | 700    | Headline Bold    |
/// | w400s28   | 28   | 400    | Headline Medium  |
/// | w400s24   | 24   | 400    | Headline Small   |
/// | w500s22   | 22   | 400    | Title Large      |
/// | w700s18   | 18   | 700    | Title Bold 18    |
/// | w600s16   | 16   | 600    | Title SemiBold   |
/// | w700s16   | 16   | 700    | Title Bold       |
/// | w500s16   | 16   | 500    | Title Medium     |
/// | w500s14   | 14   | 500    | Title Small      |
/// | w400s18   | 18   | 400    | Body Large 18    |
/// | w400s16   | 16   | 400    | Body Large       |
/// | w400s14   | 14   | 400    | Body Medium      |
/// | w400s12   | 12   | 400    | Body Small       |
/// | w500s12   | 12   | 500    | Label Medium     |
/// | w500s11   | 11   | 500    | Label Small      |
/// | w400s10   | 10   | 400    | Small            |
///
/// **AppTypography SF Pro variantlari:**
/// | Variant      | Size | Weight | Izoh            |
/// |--------------|------|--------|------------------|
/// | sfW400s57    | 57   | 400    | Display Large    |
/// | sfW400s45    | 45   | 400    | Display Medium   |
/// | sfW400s36    | 36   | 400    | Display Small    |
/// | sfW400s32    | 32   | 400    | Headline Large   |
/// | sfW700s28    | 28   | 700    | Headline Bold    |
/// | sfW400s28    | 28   | 400    | Headline Medium  |
/// | sfW400s24    | 24   | 400    | Headline Small   |
/// | sfW500s22    | 22   | 500    | Title Large      |
/// | sfW700s18    | 18   | 700    | Title Bold 18    |
/// | sfW600s16    | 16   | 600    | Title SemiBold   |
/// | sfW700s16    | 16   | 700    | Title Bold       |
/// | sfW500s16    | 16   | 500    | Title Medium     |
/// | sfW500s14    | 14   | 500    | Title Small      |
/// | sfW400s18    | 18   | 400    | Body Large 18    |
/// | sfW400s16    | 16   | 400    | Body Large       |
/// | sfW400s14    | 14   | 400    | Body Medium      |
/// | sfW400s12    | 12   | 400    | Body Small       |
/// | sfW500s12    | 12   | 500    | Label Medium     |
/// | sfW500s11    | 11   | 500    | Label Small      |
/// | sfW400s10    | 10   | 400    | Small            |
///
/// {@template AppTextStyle}
/// {@endtemplate}
enum AppTextStyle {
  // ─── Nunito ───────────────────────────────────────────────────────────────

  /// Display Large 57px w400
  displayLarge(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: 'ui',
    ),
  ),

  /// Display Medium 45px w400
  displayMedium(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Display Small 36px w400
  displaySmall(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Headline Large 32px w400
  headlineLarge(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Headline Bold 28px w700
  headlineBold(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Headline Medium 28px w400
  headlineMedium(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Headline Small 24px w400
  headlineSmall(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Title Large 22px w400
  titleLarge(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 22,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.27,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// Title Bold 18px w700
  titleBold18(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// Title Bold 16px w700
  titleBold(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// Title SemiBold 16px w600
  titleSemiBold16(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// Body Large 18px w400
  bodyLarge18(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.44,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// Title Medium 16px w500
  titleMedium(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// Title Small 14px w500
  titleSmall(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),

  /// Body Large 16px w400
  bodyLarge(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// Body Medium 14px w400
  bodyMedium(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.25,
      package: 'ui',
    ),
  ),

  /// Body Small 12px w400
  bodySmall(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: 'ui',
    ),
  ),

  /// Label Large 14px w500
  labelLarge(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),

  /// Label Medium 12px w500
  labelMedium(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// Label Small 11px w500
  labelSmall(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// Small 10px w400
  small(
    TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 10,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      letterSpacing: 0.4,
      package: 'ui',
    ),
  ),

  // ─── SF Pro ───────────────────────────────────────────────────────────────

  /// SF Pro Display Large 57px w400
  sfDisplayLarge(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: 'ui',
    ),
  ),

  /// SF Pro Display Medium 45px w400
  sfDisplayMedium(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Display Small 36px w400
  sfDisplaySmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Headline Large 32px w400
  sfHeadlineLarge(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Headline Bold 28px w700
  sfHeadlineBold(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Headline Medium 28px w400
  sfHeadlineMedium(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Headline Small 24px w400
  sfHeadlineSmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Title Large 22px w500
  sfTitleLarge(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.27,
      letterSpacing: 0,
      package: 'ui',
    ),
  ),

  /// SF Pro Title Bold 18px w700
  sfTitleBold18(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// SF Pro Title Bold 16px w700
  sfTitleBold(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// SF Pro Title SemiBold 16px w600
  sfTitleSemiBold16(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// SF Pro Body Large 18px w400
  sfBodyLarge18(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.44,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// SF Pro Title Medium 16px w500
  sfTitleMedium(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),

  /// SF Pro Title Small 14px w500
  sfTitleSmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),

  /// SF Pro Body Large 16px w400
  sfBodyLarge(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// SF Pro Body Medium 14px w400
  sfBodyMedium(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.25,
      package: 'ui',
    ),
  ),

  /// SF Pro Body Small 12px w400
  sfBodySmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: 'ui',
    ),
  ),

  /// SF Pro Label Large 14px w500
  sfLabelLarge(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),

  /// SF Pro Label Medium 12px w500
  sfLabelMedium(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// SF Pro Label Small 11px w500
  sfLabelSmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),

  /// SF Pro Small 10px w400
  sfSmall(
    TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 10,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      letterSpacing: 0.4,
      package: 'ui',
    ),
  );

  /// AppTextStyle
  const AppTextStyle(this.style);

  /// TextStyle for AppTextStyle
  final TextStyle style;
}

/// {@template typography}
/// AppTypography class
/// {@endtemplate}
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// {@macro typography}
  const AppTypography({
    // ─── Nunito ──────────────────────────────────────────────────────────────
    required this.w400s57,
    required this.w400s45,
    required this.w400s36,
    required this.w400s32,
    required this.w700s28,
    required this.w400s28,
    required this.w400s24,
    required this.w500s22,
    required this.w700s18,
    required this.w600s16,
    required this.w700s16,
    required this.w500s16,
    required this.w500s14,
    required this.w400s18,
    required this.w400s16,
    required this.w400s14,
    required this.w400s12,
    required this.w500s12,
    required this.w500s11,
    required this.w400s10,
    // ─── SF Pro ──────────────────────────────────────────────────────────────
    required this.sfW400s57,
    required this.sfW400s45,
    required this.sfW400s36,
    required this.sfW400s32,
    required this.sfW700s28,
    required this.sfW400s28,
    required this.sfW400s24,
    required this.sfW500s22,
    required this.sfW700s18,
    required this.sfW600s16,
    required this.sfW700s16,
    required this.sfW500s16,
    required this.sfW500s14,
    required this.sfW400s18,
    required this.sfW400s16,
    required this.sfW400s14,
    required this.sfW400s12,
    required this.sfW500s12,
    required this.sfW500s11,
    required this.sfW400s10,
  });

  /// The text color
  static const Color lightTextColor = Color(0xFF202732);
  static const Color darkTextColor = Color(0xFFF2F2F2);

  // ─── Light theme ───────────────────────────────────────────────────────────

  /// {@macro typography}
  static AppTypography textThemeLight = AppTypography(
    // Nunito
    w400s57: byDefault.w400s57.copyWith(color: lightTextColor),
    w400s45: byDefault.w400s45.copyWith(color: lightTextColor),
    w400s36: byDefault.w400s36.copyWith(color: lightTextColor),
    w400s32: byDefault.w400s32.copyWith(color: lightTextColor),
    w700s28: byDefault.w700s28.copyWith(color: lightTextColor),
    w400s28: byDefault.w400s28.copyWith(color: lightTextColor),
    w400s24: byDefault.w400s24.copyWith(color: lightTextColor),
    w500s22: byDefault.w500s22.copyWith(color: lightTextColor),
    w700s18: byDefault.w700s18.copyWith(color: lightTextColor),
    w600s16: byDefault.w600s16.copyWith(color: lightTextColor),
    w700s16: byDefault.w700s16.copyWith(color: lightTextColor),
    w500s16: byDefault.w500s16.copyWith(color: lightTextColor),
    w500s14: byDefault.w500s14.copyWith(color: lightTextColor),
    w400s18: byDefault.w400s18.copyWith(color: lightTextColor),
    w400s16: byDefault.w400s16.copyWith(color: lightTextColor),
    w400s14: byDefault.w400s14.copyWith(color: lightTextColor),
    w400s12: byDefault.w400s12.copyWith(color: lightTextColor),
    w500s12: byDefault.w500s12.copyWith(color: lightTextColor),
    w500s11: byDefault.w500s11.copyWith(color: lightTextColor),
    w400s10: byDefault.w400s10.copyWith(color: lightTextColor),
    // SF Pro
    sfW400s57: byDefault.sfW400s57.copyWith(color: lightTextColor),
    sfW400s45: byDefault.sfW400s45.copyWith(color: lightTextColor),
    sfW400s36: byDefault.sfW400s36.copyWith(color: lightTextColor),
    sfW400s32: byDefault.sfW400s32.copyWith(color: lightTextColor),
    sfW700s28: byDefault.sfW700s28.copyWith(color: lightTextColor),
    sfW400s28: byDefault.sfW400s28.copyWith(color: lightTextColor),
    sfW400s24: byDefault.sfW400s24.copyWith(color: lightTextColor),
    sfW500s22: byDefault.sfW500s22.copyWith(color: lightTextColor),
    sfW700s18: byDefault.sfW700s18.copyWith(color: lightTextColor),
    sfW600s16: byDefault.sfW600s16.copyWith(color: lightTextColor),
    sfW700s16: byDefault.sfW700s16.copyWith(color: lightTextColor),
    sfW500s16: byDefault.sfW500s16.copyWith(color: lightTextColor),
    sfW500s14: byDefault.sfW500s14.copyWith(color: lightTextColor),
    sfW400s18: byDefault.sfW400s18.copyWith(color: lightTextColor),
    sfW400s16: byDefault.sfW400s16.copyWith(color: lightTextColor),
    sfW400s14: byDefault.sfW400s14.copyWith(color: lightTextColor),
    sfW400s12: byDefault.sfW400s12.copyWith(color: lightTextColor),
    sfW500s12: byDefault.sfW500s12.copyWith(color: lightTextColor),
    sfW500s11: byDefault.sfW500s11.copyWith(color: lightTextColor),
    sfW400s10: byDefault.sfW400s10.copyWith(color: lightTextColor),
  );

  // ─── Dark theme ────────────────────────────────────────────────────────────

  /// {@macro typography}
  static AppTypography textThemeDark = AppTypography(
    // Nunito
    w400s57: byDefault.w400s57.copyWith(color: darkTextColor),
    w400s45: byDefault.w400s45.copyWith(color: darkTextColor),
    w400s36: byDefault.w400s36.copyWith(color: darkTextColor),
    w400s32: byDefault.w400s32.copyWith(color: darkTextColor),
    w700s28: byDefault.w700s28.copyWith(color: darkTextColor),
    w400s28: byDefault.w400s28.copyWith(color: darkTextColor),
    w400s24: byDefault.w400s24.copyWith(color: darkTextColor),
    w500s22: byDefault.w500s22.copyWith(color: darkTextColor),
    w700s18: byDefault.w700s18.copyWith(color: darkTextColor),
    w600s16: byDefault.w600s16.copyWith(color: darkTextColor),
    w700s16: byDefault.w700s16.copyWith(color: darkTextColor),
    w500s16: byDefault.w500s16.copyWith(color: darkTextColor),
    w500s14: byDefault.w500s14.copyWith(color: darkTextColor),
    w400s18: byDefault.w400s18.copyWith(color: darkTextColor),
    w400s16: byDefault.w400s16.copyWith(color: darkTextColor),
    w400s14: byDefault.w400s14.copyWith(color: darkTextColor),
    w400s12: byDefault.w400s12.copyWith(color: darkTextColor),
    w500s12: byDefault.w500s12.copyWith(color: darkTextColor),
    w500s11: byDefault.w500s11.copyWith(color: darkTextColor),
    w400s10: byDefault.w400s10.copyWith(color: darkTextColor),
    // SF Pro
    sfW400s57: byDefault.sfW400s57.copyWith(color: darkTextColor),
    sfW400s45: byDefault.sfW400s45.copyWith(color: darkTextColor),
    sfW400s36: byDefault.sfW400s36.copyWith(color: darkTextColor),
    sfW400s32: byDefault.sfW400s32.copyWith(color: darkTextColor),
    sfW700s28: byDefault.sfW700s28.copyWith(color: darkTextColor),
    sfW400s28: byDefault.sfW400s28.copyWith(color: darkTextColor),
    sfW400s24: byDefault.sfW400s24.copyWith(color: darkTextColor),
    sfW500s22: byDefault.sfW500s22.copyWith(color: darkTextColor),
    sfW700s18: byDefault.sfW700s18.copyWith(color: darkTextColor),
    sfW600s16: byDefault.sfW600s16.copyWith(color: darkTextColor),
    sfW700s16: byDefault.sfW700s16.copyWith(color: darkTextColor),
    sfW500s16: byDefault.sfW500s16.copyWith(color: darkTextColor),
    sfW500s14: byDefault.sfW500s14.copyWith(color: darkTextColor),
    sfW400s18: byDefault.sfW400s18.copyWith(color: darkTextColor),
    sfW400s16: byDefault.sfW400s16.copyWith(color: darkTextColor),
    sfW400s14: byDefault.sfW400s14.copyWith(color: darkTextColor),
    sfW400s12: byDefault.sfW400s12.copyWith(color: darkTextColor),
    sfW500s12: byDefault.sfW500s12.copyWith(color: darkTextColor),
    sfW500s11: byDefault.sfW500s11.copyWith(color: darkTextColor),
    sfW400s10: byDefault.sfW400s10.copyWith(color: darkTextColor),
  );

  // ─── Default ───────────────────────────────────────────────────────────────

  /// {@macro typography}
  static const AppTypography byDefault = AppTypography(
    // ── Nunito ──
    w400s57: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      package: 'ui',
    ),
    w400s45: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      package: 'ui',
    ),
    w400s36: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      package: 'ui',
    ),
    w400s32: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      package: 'ui',
    ),
    w700s28: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.28,
      package: 'ui',
    ),
    w400s28: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      package: 'ui',
    ),
    w400s24: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    w500s22: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 22,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.27,
      package: 'ui',
    ),
    w700s18: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    w600s16: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    w700s16: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    w500s16: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    w500s14: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.42,
      package: 'ui',
    ),
    w400s18: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.44,
      package: 'ui',
    ),
    w400s16: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    w400s14: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      package: 'ui',
    ),
    w400s12: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    w500s12: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    w500s11: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.45,
      package: 'ui',
    ),
    w400s10: TextStyle(
      fontFamily: FontFamily.nunito,
      fontSize: 10,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      package: 'ui',
    ),
    // ── SF Pro ──
    sfW400s57: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      package: 'ui',
    ),
    sfW400s45: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      package: 'ui',
    ),
    sfW400s36: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      package: 'ui',
    ),
    sfW400s32: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      package: 'ui',
    ),
    sfW700s28: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.28,
      package: 'ui',
    ),
    sfW400s28: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      package: 'ui',
    ),
    sfW400s24: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    sfW500s22: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.27,
      package: 'ui',
    ),
    sfW700s18: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    sfW600s16: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    sfW700s16: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    sfW500s16: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    sfW500s14: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.42,
      package: 'ui',
    ),
    sfW400s18: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.44,
      package: 'ui',
    ),
    sfW400s16: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      package: 'ui',
    ),
    sfW400s14: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      package: 'ui',
    ),
    sfW400s12: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    sfW500s12: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      package: 'ui',
    ),
    sfW500s11: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.45,
      package: 'ui',
    ),
    sfW400s10: TextStyle(
      fontFamily: FontFamily.sFProDisplay,
      fontSize: 10,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.2,
      package: 'ui',
    ),
  );

  // ─── Nunito fields ─────────────────────────────────────────────────────────

  /// Display Large 57px w400
  final TextStyle w400s57;

  /// Display Medium 45px w400
  final TextStyle w400s45;

  /// Display Small 36px w400
  final TextStyle w400s36;

  /// Headline Large 32px w400
  final TextStyle w400s32;

  /// Headline Bold 28px w700
  final TextStyle w700s28;

  /// Headline Medium 28px w400
  final TextStyle w400s28;

  /// Headline Small 24px w400
  final TextStyle w400s24;

  /// Title Large 22px w400
  final TextStyle w500s22;

  /// Title Bold 18px w700
  final TextStyle w700s18;

  /// Title SemiBold 16px w600
  final TextStyle w600s16;

  /// Title Bold 16px w700
  final TextStyle w700s16;

  /// Title Medium 16px w500
  final TextStyle w500s16;

  /// Title Small 14px w500
  final TextStyle w500s14;

  /// Body Large 18px w400
  final TextStyle w400s18;

  /// Body Large 16px w400
  final TextStyle w400s16;

  /// Body Medium 14px w400
  final TextStyle w400s14;

  /// Body Small 12px w400
  final TextStyle w400s12;

  /// Label Medium 12px w500
  final TextStyle w500s12;

  /// Label Small 11px w500
  final TextStyle w500s11;

  /// Small 10px w400
  final TextStyle w400s10;

  // ─── SF Pro fields ─────────────────────────────────────────────────────────

  /// SF Pro Display Large 57px w400
  final TextStyle sfW400s57;

  /// SF Pro Display Medium 45px w400
  final TextStyle sfW400s45;

  /// SF Pro Display Small 36px w400
  final TextStyle sfW400s36;

  /// SF Pro Headline Large 32px w400
  final TextStyle sfW400s32;

  /// SF Pro Headline Bold 28px w700
  final TextStyle sfW700s28;

  /// SF Pro Headline Medium 28px w400
  final TextStyle sfW400s28;

  /// SF Pro Headline Small 24px w400
  final TextStyle sfW400s24;

  /// SF Pro Title Large 22px w500
  final TextStyle sfW500s22;

  /// SF Pro Title Bold 18px w700
  final TextStyle sfW700s18;

  /// SF Pro Title SemiBold 16px w600
  final TextStyle sfW600s16;

  /// SF Pro Title Bold 16px w700
  final TextStyle sfW700s16;

  /// SF Pro Title Medium 16px w500
  final TextStyle sfW500s16;

  /// SF Pro Title Small 14px w500
  final TextStyle sfW500s14;

  /// SF Pro Body Large 18px w400
  final TextStyle sfW400s18;

  /// SF Pro Body Large 16px w400
  final TextStyle sfW400s16;

  /// SF Pro Body Medium 14px w400
  final TextStyle sfW400s14;

  /// SF Pro Body Small 12px w400
  final TextStyle sfW400s12;

  /// SF Pro Label Medium 12px w500
  final TextStyle sfW500s12;

  /// SF Pro Label Small 11px w500
  final TextStyle sfW500s11;

  /// SF Pro Small 10px w400
  final TextStyle sfW400s10;

  @override
  Object get type => 'AppTypography';

  @override
  ThemeExtension<AppTypography> copyWith({
    // Nunito
    TextStyle? w400s57,
    TextStyle? w400s45,
    TextStyle? w400s36,
    TextStyle? w400s32,
    TextStyle? w700s28,
    TextStyle? w400s28,
    TextStyle? w400s24,
    TextStyle? w500s22,
    TextStyle? w700s18,
    TextStyle? w600s16,
    TextStyle? w700s16,
    TextStyle? w500s16,
    TextStyle? w500s14,
    TextStyle? w400s18,
    TextStyle? w400s16,
    TextStyle? w400s14,
    TextStyle? w400s12,
    TextStyle? w500s12,
    TextStyle? w500s11,
    TextStyle? w400s10,
    // SF Pro
    TextStyle? sfW400s57,
    TextStyle? sfW400s45,
    TextStyle? sfW400s36,
    TextStyle? sfW400s32,
    TextStyle? sfW700s28,
    TextStyle? sfW400s28,
    TextStyle? sfW400s24,
    TextStyle? sfW500s22,
    TextStyle? sfW700s18,
    TextStyle? sfW600s16,
    TextStyle? sfW700s16,
    TextStyle? sfW500s16,
    TextStyle? sfW500s14,
    TextStyle? sfW400s18,
    TextStyle? sfW400s16,
    TextStyle? sfW400s14,
    TextStyle? sfW400s12,
    TextStyle? sfW500s12,
    TextStyle? sfW500s11,
    TextStyle? sfW400s10,
  }) => AppTypography(
    w400s57: w400s57 ?? this.w400s57,
    w400s45: w400s45 ?? this.w400s45,
    w400s36: w400s36 ?? this.w400s36,
    w400s32: w400s32 ?? this.w400s32,
    w700s28: w700s28 ?? this.w700s28,
    w400s28: w400s28 ?? this.w400s28,
    w400s24: w400s24 ?? this.w400s24,
    w500s22: w500s22 ?? this.w500s22,
    w700s18: w700s18 ?? this.w700s18,
    w600s16: w600s16 ?? this.w600s16,
    w700s16: w700s16 ?? this.w700s16,
    w500s16: w500s16 ?? this.w500s16,
    w500s14: w500s14 ?? this.w500s14,
    w400s18: w400s18 ?? this.w400s18,
    w400s16: w400s16 ?? this.w400s16,
    w400s14: w400s14 ?? this.w400s14,
    w400s12: w400s12 ?? this.w400s12,
    w500s12: w500s12 ?? this.w500s12,
    w500s11: w500s11 ?? this.w500s11,
    w400s10: w400s10 ?? this.w400s10,
    sfW400s57: sfW400s57 ?? this.sfW400s57,
    sfW400s45: sfW400s45 ?? this.sfW400s45,
    sfW400s36: sfW400s36 ?? this.sfW400s36,
    sfW400s32: sfW400s32 ?? this.sfW400s32,
    sfW700s28: sfW700s28 ?? this.sfW700s28,
    sfW400s28: sfW400s28 ?? this.sfW400s28,
    sfW400s24: sfW400s24 ?? this.sfW400s24,
    sfW500s22: sfW500s22 ?? this.sfW500s22,
    sfW700s18: sfW700s18 ?? this.sfW700s18,
    sfW600s16: sfW600s16 ?? this.sfW600s16,
    sfW700s16: sfW700s16 ?? this.sfW700s16,
    sfW500s16: sfW500s16 ?? this.sfW500s16,
    sfW500s14: sfW500s14 ?? this.sfW500s14,
    sfW400s18: sfW400s18 ?? this.sfW400s18,
    sfW400s16: sfW400s16 ?? this.sfW400s16,
    sfW400s14: sfW400s14 ?? this.sfW400s14,
    sfW400s12: sfW400s12 ?? this.sfW400s12,
    sfW500s12: sfW500s12 ?? this.sfW500s12,
    sfW500s11: sfW500s11 ?? this.sfW500s11,
    sfW400s10: sfW400s10 ?? this.sfW400s10,
  );

  @override
  ThemeExtension<AppTypography> lerp(covariant ThemeExtension<AppTypography>? other, double t) =>
      other is! AppTypography
      ? this
      : AppTypography(
          // Nunito
          w400s57: TextStyle.lerp(w400s57, other.w400s57, t) ?? w400s57,
          w400s45: TextStyle.lerp(w400s45, other.w400s45, t) ?? w400s45,
          w400s36: TextStyle.lerp(w400s36, other.w400s36, t) ?? w400s36,
          w400s32: TextStyle.lerp(w400s32, other.w400s32, t) ?? w400s32,
          w700s28: TextStyle.lerp(w700s28, other.w700s28, t) ?? w700s28,
          w400s28: TextStyle.lerp(w400s28, other.w400s28, t) ?? w400s28,
          w400s24: TextStyle.lerp(w400s24, other.w400s24, t) ?? w400s24,
          w500s22: TextStyle.lerp(w500s22, other.w500s22, t) ?? w500s22,
          w700s18: TextStyle.lerp(w700s18, other.w700s18, t) ?? w700s18,
          w600s16: TextStyle.lerp(w600s16, other.w600s16, t) ?? w600s16,
          w700s16: TextStyle.lerp(w700s16, other.w700s16, t) ?? w700s16,
          w500s16: TextStyle.lerp(w500s16, other.w500s16, t) ?? w500s16,
          w500s14: TextStyle.lerp(w500s14, other.w500s14, t) ?? w500s14,
          w400s18: TextStyle.lerp(w400s18, other.w400s18, t) ?? w400s18,
          w400s16: TextStyle.lerp(w400s16, other.w400s16, t) ?? w400s16,
          w400s14: TextStyle.lerp(w400s14, other.w400s14, t) ?? w400s14,
          w400s12: TextStyle.lerp(w400s12, other.w400s12, t) ?? w400s12,
          w500s12: TextStyle.lerp(w500s12, other.w500s12, t) ?? w500s12,
          w500s11: TextStyle.lerp(w500s11, other.w500s11, t) ?? w500s11,
          w400s10: TextStyle.lerp(w400s10, other.w400s10, t) ?? w400s10,
          // SF Pro
          sfW400s57: TextStyle.lerp(sfW400s57, other.sfW400s57, t) ?? sfW400s57,
          sfW400s45: TextStyle.lerp(sfW400s45, other.sfW400s45, t) ?? sfW400s45,
          sfW400s36: TextStyle.lerp(sfW400s36, other.sfW400s36, t) ?? sfW400s36,
          sfW400s32: TextStyle.lerp(sfW400s32, other.sfW400s32, t) ?? sfW400s32,
          sfW700s28: TextStyle.lerp(sfW700s28, other.sfW700s28, t) ?? sfW700s28,
          sfW400s28: TextStyle.lerp(sfW400s28, other.sfW400s28, t) ?? sfW400s28,
          sfW400s24: TextStyle.lerp(sfW400s24, other.sfW400s24, t) ?? sfW400s24,
          sfW500s22: TextStyle.lerp(sfW500s22, other.sfW500s22, t) ?? sfW500s22,
          sfW700s18: TextStyle.lerp(sfW700s18, other.sfW700s18, t) ?? sfW700s18,
          sfW600s16: TextStyle.lerp(sfW600s16, other.sfW600s16, t) ?? sfW600s16,
          sfW700s16: TextStyle.lerp(sfW700s16, other.sfW700s16, t) ?? sfW700s16,
          sfW500s16: TextStyle.lerp(sfW500s16, other.sfW500s16, t) ?? sfW500s16,
          sfW500s14: TextStyle.lerp(sfW500s14, other.sfW500s14, t) ?? sfW500s14,
          sfW400s18: TextStyle.lerp(sfW400s18, other.sfW400s18, t) ?? sfW400s18,
          sfW400s16: TextStyle.lerp(sfW400s16, other.sfW400s16, t) ?? sfW400s16,
          sfW400s14: TextStyle.lerp(sfW400s14, other.sfW400s14, t) ?? sfW400s14,
          sfW400s12: TextStyle.lerp(sfW400s12, other.sfW400s12, t) ?? sfW400s12,
          sfW500s12: TextStyle.lerp(sfW500s12, other.sfW500s12, t) ?? sfW500s12,
          sfW500s11: TextStyle.lerp(sfW500s11, other.sfW500s11, t) ?? sfW500s11,
          sfW400s10: TextStyle.lerp(sfW400s10, other.sfW400s10, t) ?? sfW400s10,
        );

  @override
  bool operator ==(covariant AppTypography other) {
    if (identical(this, other)) return true;

    return
    // Nunito
    other.w400s57 == w400s57 &&
        other.w400s45 == w400s45 &&
        other.w400s36 == w400s36 &&
        other.w400s32 == w400s32 &&
        other.w700s28 == w700s28 &&
        other.w400s28 == w400s28 &&
        other.w400s24 == w400s24 &&
        other.w500s22 == w500s22 &&
        other.w700s18 == w700s18 &&
        other.w600s16 == w600s16 &&
        other.w700s16 == w700s16 &&
        other.w500s16 == w500s16 &&
        other.w500s14 == w500s14 &&
        other.w400s18 == w400s18 &&
        other.w400s16 == w400s16 &&
        other.w400s14 == w400s14 &&
        other.w400s12 == w400s12 &&
        other.w500s12 == w500s12 &&
        other.w500s11 == w500s11 &&
        other.w400s10 == w400s10 &&
        // SF Pro
        other.sfW400s57 == sfW400s57 &&
        other.sfW400s45 == sfW400s45 &&
        other.sfW400s36 == sfW400s36 &&
        other.sfW400s32 == sfW400s32 &&
        other.sfW700s28 == sfW700s28 &&
        other.sfW400s28 == sfW400s28 &&
        other.sfW400s24 == sfW400s24 &&
        other.sfW500s22 == sfW500s22 &&
        other.sfW700s18 == sfW700s18 &&
        other.sfW600s16 == sfW600s16 &&
        other.sfW700s16 == sfW700s16 &&
        other.sfW500s16 == sfW500s16 &&
        other.sfW500s14 == sfW500s14 &&
        other.sfW400s18 == sfW400s18 &&
        other.sfW400s16 == sfW400s16 &&
        other.sfW400s14 == sfW400s14 &&
        other.sfW400s12 == sfW400s12 &&
        other.sfW500s12 == sfW500s12 &&
        other.sfW500s11 == sfW500s11 &&
        other.sfW400s10 == sfW400s10;
  }

  @override
  int get hashCode =>
      // Nunito
      w400s57.hashCode ^
      w400s45.hashCode ^
      w400s36.hashCode ^
      w400s32.hashCode ^
      w700s28.hashCode ^
      w400s28.hashCode ^
      w400s24.hashCode ^
      w500s22.hashCode ^
      w700s18.hashCode ^
      w600s16.hashCode ^
      w700s16.hashCode ^
      w500s16.hashCode ^
      w500s14.hashCode ^
      w400s18.hashCode ^
      w400s16.hashCode ^
      w400s14.hashCode ^
      w400s12.hashCode ^
      w500s12.hashCode ^
      w500s11.hashCode ^
      w400s10.hashCode ^
      // SF Pro
      sfW400s57.hashCode ^
      sfW400s45.hashCode ^
      sfW400s36.hashCode ^
      sfW400s32.hashCode ^
      sfW700s28.hashCode ^
      sfW400s28.hashCode ^
      sfW400s24.hashCode ^
      sfW500s22.hashCode ^
      sfW700s18.hashCode ^
      sfW600s16.hashCode ^
      sfW700s16.hashCode ^
      sfW500s16.hashCode ^
      sfW500s14.hashCode ^
      sfW400s18.hashCode ^
      sfW400s16.hashCode ^
      sfW400s14.hashCode ^
      sfW400s12.hashCode ^
      sfW500s12.hashCode ^
      sfW500s11.hashCode ^
      sfW400s10.hashCode;
}
