import 'package:ui/ui.dart';

/// {@template text_style}
/// TextStyleUI widget.
/// {@endtemplate}
class TextStyleUI extends StatelessWidget {
  /// {@macro text_style}
  const TextStyleUI({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Text Styles
      AppText.w400s57('Text Styles'),
      AppText.w400s57('Display Large (57px w400)'),
      AppText.w400s45('Display Medium (45px w400)'),
      AppText.w400s36('Display Small (36px w400)'),
      AppText.w400s32('Headline Large (32px w400)'),
      AppText.w400s28('Headline Medium (28px w400)'),
      AppText.w400s24('Headline Small (24px w400)'),
      AppText.w500s22('Title Large (22px w400)'),
      AppText.w500s16('Title Medium (16px w500)'),
      AppText.w500s14('Title Small (14px w500)'),
      AppText.w400s16('Body Large (16px w400)'),
      AppText.w400s14('Body Medium (14px w400)'),
      AppText.w400s12('Body Small (12px w400)'),
      AppText.w500s14('Label Large (14px w500)'),
      AppText.w500s12('Label Medium (12px w500)'),
      AppText.w500s11('Label Small (11px w500)'),
    ],
  );
}
