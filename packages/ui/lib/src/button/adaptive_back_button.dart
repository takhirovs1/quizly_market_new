import '../../ui.dart';

/// {@template adaptive_back_button}
/// AdaptiveBackButton widget.
/// {@endtemplate}
class AdaptiveBackButton extends StatefulWidget {
  /// {@macro adaptive_back_button}
  const AdaptiveBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  State<AdaptiveBackButton> createState() => _AdaptiveBackButtonState();
}

/// State for widget [AdaptiveBackButton].
class _AdaptiveBackButtonState extends State<AdaptiveBackButton> {
  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {
      HapticsService.selectionClick();
      widget.onTap();
    },
    tooltip: 'Back',
    // icon: Assets.lib.vectors.icChevronLeft.svg(
    //   package: 'ui',
    //   colorFilter: ColorFilter.mode(Theme.of(context).appColors.onSecondary, BlendMode.srcIn),
    // ),
    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).appColors.onSecondary),
  );
}
