import '../../ui.dart';
import '../extension/context_extension.dart';

enum SocialLoginType { google, apple, telegram }

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({required this.type, required this.title, required this.onPressed, super.key});

  final SocialLoginType type;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => switch (type) {
      SocialLoginType.google => _GoogleButton(title: title, onPressed: onPressed),
      SocialLoginType.apple => _AppleButton(title: title, onPressed: onPressed),
      SocialLoginType.telegram => _TelegramButton(title: title, onPressed: onPressed),
    };
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

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
  const _AppleButton({required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.x.colors.black,
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
            colorFilter: ColorFilter.mode(context.x.colors.white, BlendMode.srcIn),
          ),
          Text(title, style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white)),
        ],
      ),
    );
}

class _TelegramButton extends StatelessWidget {
  const _TelegramButton({required this.title, required this.onPressed});
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.x.colors.primary,
        elevation: 0,
        fixedSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Assets.lib.images.telegramLogo.image(package: 'ui', width: 24, height: 24, color: context.x.colors.white),
          Text(title, style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.white)),
        ],
      ),
    );
}
