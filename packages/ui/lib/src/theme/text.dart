import 'package:flutter/material.dart';

import 'typography.dart';

/// {@template text}
/// AppText widget.
/// {@endtemplate}
class AppText extends StatelessWidget {
  /// {@macro text}
  const AppText(
    this.text,
    this.style, {
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
    super.key,
  });

  /// {@macro text}
  ///
  /// displayLarge (57px w400)
  AppText.w400s57(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.displayLarge.style;

  /// {@macro text}
  ///
  /// displayMedium (45px w400)
  AppText.w400s45(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.displayMedium.style;

  /// {@macro text}
  ///
  /// displaySmall (36px w400)
  AppText.w400s36(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.displaySmall.style;

  /// {@macro text}
  ///
  /// headlineLarge (32px w400)
  AppText.w400s32(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.headlineLarge.style;

  /// {@macro text}
  ///
  /// headlineBold (28px w700)
  AppText.w700s28(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.headlineBold.style;

  /// {@macro text}
  ///
  /// headlineMedium (28px w400)
  AppText.w400s28(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.headlineMedium.style;

  /// {@macro text}
  ///
  /// headlineSmall (24px w400)
  AppText.w400s24(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.headlineSmall.style;

  /// {@macro text}
  ///
  /// titleLarge (22px w500)
  AppText.w500s22(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleLarge.style;

  /// {@macro text}
  ///
  /// titleBold18 (18px w700)
  AppText.w700s18(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleBold18.style;

  /// {@macro text}
  ///
  /// bodyLarge18 (18px w400)
  AppText.w400s18(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.bodyLarge18.style;

  /// {@macro text}
  ///
  /// titleBold (16px w700)
  AppText.w700s16(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleBold.style;

  /// {@macro text}
  ///
  /// titleSemiBold16 (16px w600)
  AppText.w600s16(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleSemiBold16.style;

  /// {@macro text}
  ///
  /// titleMedium (16px w500)
  AppText.w500s16(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleMedium.style;

  /// {@macro text}
  ///
  /// titleSmall (14px w500)
  AppText.w500s14(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.titleSmall.style;

  /// {@macro text}
  ///
  /// bodyLarge (16px w400)
  AppText.w400s16(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.bodyLarge.style;

  /// {@macro text}
  ///
  /// bodyMedium (14px w400)
  AppText.w400s14(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.bodyMedium.style;

  /// {@macro text}
  ///
  /// bodySmall (12px w400)
  AppText.w400s12(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.bodySmall.style;

  /// {@macro text}
  ///
  /// labelMedium (12px w500)
  AppText.w500s12(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.labelMedium.style;

  /// {@macro text}
  ///
  /// labelSmall (11px w500)
  AppText.w500s11(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.labelSmall.style;

  /// {@macro text}
  ///
  /// Small (10px w400)
  AppText.w400s10(this.text, {this.overflow, this.maxLines, this.textAlign, this.softWrap, this.color, super.key})
    : style = AppTextStyle.small.style;

  /// The text to display
  final String text;

  /// The style to apply to the text
  final TextStyle style;

  /// The overflow behavior
  final TextOverflow? overflow;

  /// The maximum number of lines to display
  final int? maxLines;

  /// The text alignment
  final TextAlign? textAlign;

  /// Whether the text should wrap
  final bool? softWrap;

  /// The color of the text
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? AppTypography.lightTextColor : AppTypography.darkTextColor;

    return Text(
      text,
      style: style.copyWith(color: color ?? textColor),
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      softWrap: softWrap,
    );
  }
}
