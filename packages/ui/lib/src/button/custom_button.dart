import '../../ui.dart';

/// {@template custom_button}
/// CustomButton widget.
/// {@endtemplate}
class CustomButton extends StatefulWidget {
  /// {@macro custom_button}
  const CustomButton({
    required this.onTap,
    required this.title,
    this.color,
    this.textColor,
    super.key,
    this.textStyle,
    this.borderRadius = 16,
  });

  final VoidCallback onTap;
  final String title;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final double borderRadius;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

/// State for widget [CustomButton].
class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: widget.onTap,
    style: FilledButton.styleFrom(
      backgroundColor: widget.color ?? Theme.of(context).appColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
      fixedSize: const Size(double.infinity, 50),
    ),
    child: Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        widget.title,
        style:
            widget.textStyle ??
            TextStyle(color: widget.textColor ?? Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
