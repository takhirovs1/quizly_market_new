import '../../ui.dart';
import '../extension/context_extension.dart';

enum SocialLoginType { google, apple, telegram }

class SocialLoginButton extends StatefulWidget {
  const SocialLoginButton({
    required this.type,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final SocialLoginType type;
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(SocialLoginButton old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !old.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && old.isLoading) {
      _controller
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = switch (widget.type) {
      SocialLoginType.google => _GoogleButton(
        title: widget.title,
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
      ),
      SocialLoginType.apple => _AppleButton(
        title: widget.title,
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
      ),
      SocialLoginType.telegram => _TelegramButton(
        title: widget.title,
        onPressed: widget.onPressed,
        isLoading: widget.isLoading,
      ),
    };

    if (!widget.isLoading) return button;

    final borderColor = switch (widget.type) {
      SocialLoginType.google => context.x.colors.primary,
      SocialLoginType.apple => context.x.colors.black,
      SocialLoginType.telegram => context.x.colors.primary,
    };

    return CustomPaint(
      foregroundPainter: _BorderLoadingPainter(animation: _controller, color: borderColor, radius: 16),
      child: button,
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.title, required this.onPressed, required this.isLoading});
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: context.x.colors.white,
      side: BorderSide(color: context.x.colors.gray),
      elevation: 0,
      fixedSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Assets.lib.vectors.google.svg(package: 'ui'),
        Text(title, style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.black)),
      ],
    ),
  );
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.title, required this.onPressed, required this.isLoading});
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: isLoading ? context.x.colors.white : context.x.colors.black,
      side: isLoading ? BorderSide(color: context.x.colors.gray) : null,
      elevation: 0,
      fixedSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Assets.lib.vectors.apple.svg(
          package: 'ui',
          colorFilter: ColorFilter.mode(isLoading ? context.x.colors.black : context.x.colors.white, BlendMode.srcIn),
        ),
        Text(
          title,
          style: context.x.textStyle.sfW600s16.copyWith(
            color: isLoading ? context.x.colors.black : context.x.colors.white,
          ),
        ),
      ],
    ),
  );
}

class _TelegramButton extends StatelessWidget {
  const _TelegramButton({required this.title, required this.onPressed, required this.isLoading});
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: isLoading ? context.x.colors.white : context.x.colors.primary,
      side: isLoading ? BorderSide(color: context.x.colors.gray) : null,
      elevation: 0,
      fixedSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Assets.lib.images.telegramLogo.image(
          package: 'ui',
          width: 24,
          height: 24,
          color: isLoading ? context.x.colors.primary : context.x.colors.white,
        ),
        Text(
          title,
          style: context.x.textStyle.sfW600s16.copyWith(
            color: isLoading ? context.x.colors.primary : context.x.colors.white,
          ),
        ),
      ],
    ),
  );
}

class _BorderLoadingPainter extends CustomPainter {
  _BorderLoadingPainter({required this.animation, required this.color, required this.radius})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius)));

    final metrics = path.computeMetrics().first;
    final total = metrics.length;
    final segLen = total * 0.3;
    final start = animation.value * total;
    final end = start + segLen;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (end <= total) {
      canvas.drawPath(metrics.extractPath(start, end), paint);
    } else {
      canvas
        ..drawPath(metrics.extractPath(start, total), paint)
        ..drawPath(metrics.extractPath(0, end - total), paint);
    }
  }

  @override
  bool shouldRepaint(_BorderLoadingPainter old) => old.color != color || old.radius != radius;
}
