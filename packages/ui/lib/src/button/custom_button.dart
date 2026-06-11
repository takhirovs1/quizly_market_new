import '../../ui.dart';

/// {@template custom_button}
/// CustomButton widget with animated loading border capability.
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
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String title;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final double borderRadius;
  final bool isLoading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

/// State for widget [CustomButton].
class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (widget.isLoading) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CustomButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.appColors.primary;
    const double stroke = 3;

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) => CustomPaint(
        painter: widget.isLoading
            ? _LoadingBorderPainter(
                progress: _rotationController.value,
                color: buttonColor,
                borderRadius: widget.borderRadius,
                strokeWidth: stroke,
              )
            : null,
        child: FilledButton(
          onPressed: widget.isLoading ? null : widget.onTap,
          style: FilledButton.styleFrom(
            backgroundColor: widget.isLoading ? buttonColor.withValues(alpha: 0.1) : buttonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
            fixedSize: const Size(double.infinity, 50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              widget.title,
              style:
                  widget.textStyle ??
                  TextStyle(
                    color: widget.isLoading ? buttonColor : (widget.textColor ?? Colors.white),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingBorderPainter extends CustomPainter {
  _LoadingBorderPainter({
    required this.progress,
    required this.color,
    required this.borderRadius,
    this.strokeWidth = 3.0,
  });
  final double progress;
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final halfStroke = strokeWidth / 2;
    final rect = Rect.fromLTWH(halfStroke, halfStroke, size.width - strokeWidth, size.height - strokeWidth);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius - halfStroke));

    // Draw background track for border
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, trackPaint);

    // Draw active animated border
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color],
        stops: const [0, 1],
        transform: GradientRotation(progress * 2 * 3.1415926535),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, activePaint);
  }

  @override
  bool shouldRepaint(covariant _LoadingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
