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
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).appColors.primary,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            widget.title,
            style:
                widget.textStyle ??
                TextStyle(color: widget.textColor ?? Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
