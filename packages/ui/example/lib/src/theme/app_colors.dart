import 'package:ui/ui.dart';

/// {@template app_colors}
/// AppColorsUI widget.
/// {@endtemplate}
class AppColorsUI extends StatelessWidget {
  /// {@macro app_colors}
  const AppColorsUI({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => Column(
    spacing: 8,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppText.w400s57('Theme Colors'),
      ColorCompereItem(
        name: 'black',
        colorLight: AppThemeData.light().appColors.black,
        colorDark: AppThemeData.dark().appColors.black,
      ),
      ColorCompereItem(
        name: 'gray',
        colorLight: AppThemeData.light().appColors.gray,
        colorDark: AppThemeData.dark().appColors.gray,
      ),
      ColorCompereItem(
        name: 'transparent',
        colorLight: AppThemeData.light().appColors.transparent,
        colorDark: AppThemeData.dark().appColors.transparent,
      ),
      ColorCompereItem(
        name: 'white',
        colorLight: AppThemeData.light().appColors.white,
        colorDark: AppThemeData.dark().appColors.white,
      ),
      ColorCompereItem(
        name: 'error',
        colorLight: AppThemeData.light().appColors.error,
        colorDark: AppThemeData.dark().appColors.error,
      ),
      ColorCompereItem(
        name: 'onError',
        colorLight: AppThemeData.light().appColors.onError,
        colorDark: AppThemeData.dark().appColors.onError,
      ),
      ColorCompereItem(
        name: 'primary',
        colorLight: AppThemeData.light().appColors.primary,
        colorDark: AppThemeData.dark().appColors.primary,
      ),
      ColorCompereItem(
        name: 'onPrimary',
        colorLight: AppThemeData.light().appColors.onPrimary,
        colorDark: AppThemeData.dark().appColors.onPrimary,
      ),
      ColorCompereItem(
        name: 'secondary',
        colorLight: AppThemeData.light().appColors.secondary,
        colorDark: AppThemeData.dark().appColors.secondary,
      ),
      ColorCompereItem(
        name: 'onSecondary',
        colorLight: AppThemeData.light().appColors.onSecondary,
        colorDark: AppThemeData.dark().appColors.onSecondary,
      ),
      ColorCompereItem(
        name: 'success',
        colorLight: AppThemeData.light().appColors.success,
        colorDark: AppThemeData.dark().appColors.success,
      ),
      ColorCompereItem(
        name: 'onSuccess',
        colorLight: AppThemeData.light().appColors.onSuccess,
        colorDark: AppThemeData.dark().appColors.onSuccess,
      ),
      ColorCompereItem(
        name: 'surface',
        colorLight: AppThemeData.light().appColors.surface,
        colorDark: AppThemeData.dark().appColors.surface,
      ),
      ColorCompereItem(
        name: 'onSurface',
        colorLight: AppThemeData.light().appColors.onSurface,
        colorDark: AppThemeData.dark().appColors.onSurface,
      ),
      ColorCompereItem(
        name: 'tealBlue',
        colorLight: AppThemeData.light().appColors.tealBlue,
        colorDark: AppThemeData.dark().appColors.tealBlue,
      ),
      ColorCompereItem(
        name: 'tertiary',
        colorLight: AppThemeData.light().appColors.tertiary,
        colorDark: AppThemeData.dark().appColors.tertiary,
      ),
      ColorCompereItem(
        name: 'tertiaryBold',
        colorLight: AppThemeData.light().appColors.tertiaryBold,
        colorDark: AppThemeData.dark().appColors.tertiaryBold,
      ),
      ColorCompereItem(
        name: 'onTertiary',
        colorLight: AppThemeData.light().appColors.onTertiary,
        colorDark: AppThemeData.dark().appColors.onTertiary,
      ),
      ColorCompereItem(
        name: 'buttonBorder',
        colorLight: AppThemeData.light().appColors.buttonBorder,
        colorDark: AppThemeData.dark().appColors.buttonBorder,
      ),
      ColorCompereItem(
        name: 'buttonFill',
        colorLight: AppThemeData.light().appColors.buttonFill,
        colorDark: AppThemeData.dark().appColors.buttonFill,
      ),
      ColorCompereItem(
        name: 'divider',
        colorLight: AppThemeData.light().appColors.divider,
        colorDark: AppThemeData.dark().appColors.divider,
      ),
      ColorCompereItem(
        name: 'primaryButtonFill',
        colorLight: AppThemeData.light().appColors.primaryButtonFill,
        colorDark: AppThemeData.dark().appColors.primaryButtonFill,
      ),
      ColorCompereItem(
        name: 'primaryButtonBorder',
        colorLight: AppThemeData.light().appColors.primaryButtonBorder,
        colorDark: AppThemeData.dark().appColors.primaryButtonBorder,
      ),
      ColorCompereItem(
        name: 'text',
        colorLight: AppThemeData.light().appColors.text,
        colorDark: AppThemeData.dark().appColors.text,
      ),
      ColorCompereItem(
        name: 'breakC',
        colorLight: AppThemeData.light().appColors.breakC,
        colorDark: AppThemeData.dark().appColors.breakC,
      ),
      ColorCompereItem(
        name: 'driveC',
        colorLight: AppThemeData.light().appColors.driveC,
        colorDark: AppThemeData.dark().appColors.driveC,
      ),
      ColorCompereItem(
        name: 'shiftC',
        colorLight: AppThemeData.light().appColors.shiftC,
        colorDark: AppThemeData.dark().appColors.shiftC,
      ),
      ColorCompereItem(
        name: 'cycleC',
        colorLight: AppThemeData.light().appColors.cycleC,
        colorDark: AppThemeData.dark().appColors.cycleC,
      ),
    ],
  );
}

/// {@template app_colors}
/// ColorCompereItem widget.
/// {@endtemplate}
class ColorCompereItem extends StatelessWidget {
  /// {@macro app_colors}
  const ColorCompereItem({
    required this.name,
    required this.colorLight,
    required this.colorDark,
    super.key, // ignore: unused_element
  });

  final String name;
  final Color colorLight;
  final Color colorDark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox.square(
        dimension: 100,
        child: ColoredBox(color: colorLight, child: const SizedBox.expand()),
      ),
      Expanded(
        child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      ),
      SizedBox.square(
        dimension: 100,
        child: ColoredBox(color: colorDark, child: const SizedBox.expand()),
      ),
    ],
  );
}
