import '../../ui.dart';

/// {@template check_box}
/// CheckBox widget.
/// {@endtemplate}
class CheckBox extends StatelessWidget {
  /// {@macro check_box}
  const CheckBox({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: ThemeColors.of(context).primary, shape: BoxShape.circle),
    child: Padding(
      padding: const EdgeInsetsGeometry.all(4),
      child: Icon(Icons.check, size: 14, color: ThemeColors.of(context).white),
    ),
  );
}
