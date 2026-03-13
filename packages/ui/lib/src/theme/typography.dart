import 'package:flutter/material.dart';

import '../gen/fonts.gen.dart';

/// {@template AppTextStyle}
/// {@endtemplate}
enum AppTextStyle {
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
    required this.w400s57,
    required this.w400s45,
    required this.w400s36,
    required this.w400s32,
    required this.w700s28,
    required this.w400s28,
    required this.w400s24,
    required this.w500s22,
    required this.w700s16,
    required this.w500s16,
    required this.w500s14,
    required this.w400s16,
    required this.w400s14,
    required this.w400s12,
    required this.w500s12,
    required this.w500s11,
    required this.w400s10,
  });

  /// {@macro typography}
  static AppTypography textThemeLight = AppTypography(
    w400s57: byDefault.w400s57.copyWith(color: lightTextColor),
    w400s45: byDefault.w400s45.copyWith(color: lightTextColor),
    w400s36: byDefault.w400s36.copyWith(color: lightTextColor),
    w400s32: byDefault.w400s32.copyWith(color: lightTextColor),
    w700s28: byDefault.w700s28.copyWith(color: lightTextColor),
    w400s28: byDefault.w400s28.copyWith(color: lightTextColor),
    w400s24: byDefault.w400s24.copyWith(color: lightTextColor),
    w500s22: byDefault.w500s22.copyWith(color: lightTextColor),
    w700s16: byDefault.w700s16.copyWith(color: lightTextColor),
    w500s16: byDefault.w500s16.copyWith(color: lightTextColor),
    w500s14: byDefault.w500s14.copyWith(color: lightTextColor),
    w400s16: byDefault.w400s16.copyWith(color: lightTextColor),
    w400s14: byDefault.w400s14.copyWith(color: lightTextColor),
    w400s12: byDefault.w400s12.copyWith(color: lightTextColor),
    w500s12: byDefault.w500s12.copyWith(color: lightTextColor),
    w500s11: byDefault.w500s11.copyWith(color: lightTextColor),
    w400s10: byDefault.w400s10.copyWith(color: lightTextColor),
  );

  /// {@macro typography}
  static AppTypography textThemeDark = AppTypography(
    w400s57: byDefault.w400s57.copyWith(color: darkTextColor),
    w400s45: byDefault.w400s45.copyWith(color: darkTextColor),
    w400s36: byDefault.w400s36.copyWith(color: darkTextColor),
    w400s32: byDefault.w400s32.copyWith(color: darkTextColor),
    w700s28: byDefault.w700s28.copyWith(color: darkTextColor),
    w400s28: byDefault.w400s28.copyWith(color: darkTextColor),
    w400s24: byDefault.w400s24.copyWith(color: darkTextColor),
    w500s22: byDefault.w500s22.copyWith(color: darkTextColor),
    w700s16: byDefault.w700s16.copyWith(color: darkTextColor),
    w500s16: byDefault.w500s16.copyWith(color: darkTextColor),
    w500s14: byDefault.w500s14.copyWith(color: darkTextColor),
    w400s16: byDefault.w400s16.copyWith(color: darkTextColor),
    w400s14: byDefault.w400s14.copyWith(color: darkTextColor),
    w400s12: byDefault.w400s12.copyWith(color: darkTextColor),
    w500s12: byDefault.w500s12.copyWith(color: darkTextColor),
    w500s11: byDefault.w500s11.copyWith(color: darkTextColor),
    w400s10: byDefault.w400s10.copyWith(color: darkTextColor),
  );

  /// The text color
  static const Color lightTextColor = Color(0xFF202732);
  static const Color darkTextColor = Color(0xFFF2F2F2);

  /// {@macro typography}
  static const AppTypography byDefault = AppTypography(
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
  );

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

  /// Title Bold 16px w700
  final TextStyle w700s16;

  /// Title Medium 16px w500
  final TextStyle w500s16;

  /// Title Small 14px w500
  final TextStyle w500s14;

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

  @override
  Object get type => 'AppTypography';

  @override
  ThemeExtension<AppTypography> copyWith({
    TextStyle? w400s57,
    TextStyle? w400s45,
    TextStyle? w400s36,
    TextStyle? w400s32,
    TextStyle? w700s28,
    TextStyle? w400s28,
    TextStyle? w400s24,
    TextStyle? w500s22,
    TextStyle? w700s16,
    TextStyle? w500s16,
    TextStyle? w500s14,
    TextStyle? w400s16,
    TextStyle? w400s14,
    TextStyle? w400s12,
    TextStyle? w500s12,
    TextStyle? w500s11,
    TextStyle? w400s10,
  }) => AppTypography(
    w400s57: w400s57 ?? this.w400s57,
    w400s45: w400s45 ?? this.w400s45,
    w400s36: w400s36 ?? this.w400s36,
    w400s32: w400s32 ?? this.w400s32,
    w700s28: w700s28 ?? this.w700s28,
    w400s28: w400s28 ?? this.w400s28,
    w400s24: w400s24 ?? this.w400s24,
    w500s22: w500s22 ?? this.w500s22,
    w700s16: w700s16 ?? this.w700s16,
    w500s16: w500s16 ?? this.w500s16,
    w500s14: w500s14 ?? this.w500s14,
    w400s16: w400s16 ?? this.w400s16,
    w400s14: w400s14 ?? this.w400s14,
    w400s12: w400s12 ?? this.w400s12,
    w500s12: w500s12 ?? this.w500s12,
    w500s11: w500s11 ?? this.w500s11,
    w400s10: w400s10 ?? this.w400s10,
  );

  @override
  ThemeExtension<AppTypography> lerp(covariant ThemeExtension<AppTypography>? other, double t) =>
      other is! AppTypography
      ? this
      : AppTypography(
          w400s57: TextStyle.lerp(w400s57, other.w400s57, t) ?? w400s57,
          w400s45: TextStyle.lerp(w400s45, other.w400s45, t) ?? w400s45,
          w400s36: TextStyle.lerp(w400s36, other.w400s36, t) ?? w400s36,
          w400s32: TextStyle.lerp(w400s32, other.w400s32, t) ?? w400s32,
          w700s28: TextStyle.lerp(w700s28, other.w700s28, t) ?? w700s28,
          w400s28: TextStyle.lerp(w400s28, other.w400s28, t) ?? w400s28,
          w400s24: TextStyle.lerp(w400s24, other.w400s24, t) ?? w400s24,
          w500s22: TextStyle.lerp(w500s22, other.w500s22, t) ?? w500s22,
          w700s16: TextStyle.lerp(w700s16, other.w700s16, t) ?? w700s16,
          w500s16: TextStyle.lerp(w500s16, other.w500s16, t) ?? w500s16,
          w500s14: TextStyle.lerp(w500s14, other.w500s14, t) ?? w500s14,
          w400s16: TextStyle.lerp(w400s16, other.w400s16, t) ?? w400s16,
          w400s14: TextStyle.lerp(w400s14, other.w400s14, t) ?? w400s14,
          w400s12: TextStyle.lerp(w400s12, other.w400s12, t) ?? w400s12,
          w500s12: TextStyle.lerp(w500s12, other.w500s12, t) ?? w500s12,
          w500s11: TextStyle.lerp(w500s11, other.w500s11, t) ?? w500s11,
          w400s10: TextStyle.lerp(w400s10, other.w400s10, t) ?? w400s10,
        );

  @override
  bool operator ==(covariant AppTypography other) {
    if (identical(this, other)) return true;

    return other.w400s57 == w400s57 &&
        other.w400s45 == w400s45 &&
        other.w400s36 == w400s36 &&
        other.w400s32 == w400s32 &&
        other.w700s28 == w700s28 &&
        other.w400s28 == w400s28 &&
        other.w400s24 == w400s24 &&
        other.w500s22 == w500s22 &&
        other.w700s16 == w700s16 &&
        other.w500s16 == w500s16 &&
        other.w500s14 == w500s14 &&
        other.w400s16 == w400s16 &&
        other.w400s14 == w400s14 &&
        other.w400s12 == w400s12 &&
        other.w500s12 == w500s12 &&
        other.w500s11 == w500s11 &&
        other.w400s10 == w400s10;
  }

  @override
  int get hashCode =>
      w400s57.hashCode ^
      w400s45.hashCode ^
      w400s36.hashCode ^
      w400s32.hashCode ^
      w700s28.hashCode ^
      w400s28.hashCode ^
      w400s24.hashCode ^
      w500s22.hashCode ^
      w700s16.hashCode ^
      w500s16.hashCode ^
      w500s14.hashCode ^
      w400s16.hashCode ^
      w400s14.hashCode ^
      w400s12.hashCode ^
      w500s12.hashCode ^
      w500s11.hashCode ^
      w400s10.hashCode;
}
