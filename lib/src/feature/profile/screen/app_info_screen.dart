import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/util/helpers.dart';
import '../state/app_info_state.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends AppInfoState {
  Future<void> _openLink(String url) async {
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.openLink(url, tryInstantView: false);
      return;
    }
    await Helpers.launchUrl(url);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    appBar: QuizAppBar(
      telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
      title: context.x.l10n.app_info,
    ),
    body: SafeArea(
      child: ListView(
        padding: const .fromLTRB(16, 16, 16, 24),
        children: [
          Text(context.x.l10n.title, style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text)),
          const SizedBox(height: 8),
          Text(
            context.x.l10n.appInfoDescription,
            style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: context.x.l10n.apps, color: context.x.colors.text),
          const SizedBox(height: 10),
          _LinkCard(
            leading: Assets.lib.vectors.google.svg(package: 'ui', width: 22, height: 22),
            title: 'GooglePlay',
            subtitle: 'QuizlyMarket',
            onTap: () => _openLink('https://play.google.com/store'),
          ),
          const SizedBox(height: 10),
          _LinkCard(
            leading: Assets.lib.vectors.apple.svg(package: 'ui', width: 22, height: 22),
            title: 'AppStore',
            subtitle: 'QuizlyMarket',
            onTap: () => _openLink('https://www.apple.com/app-store/'),
          ),
          const SizedBox(height: 10),
          _LinkCard(
            leading: Assets.lib.images.telegramLogo.image(package: 'ui', width: 22, height: 22),
            title: 'Telegram',
            subtitle: 't.me/quizlymarketbot',
            onTap: () => _openLink('https://t.me/quizlymarketbot'),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: context.x.l10n.socialNetworks, color: context.x.colors.text),
          const SizedBox(height: 10),
          _LinkCard(
            leading: Assets.lib.vectors.instagram.svg(package: 'ui', width: 22, height: 22),
            title: 'instagram.com/quizlymarket',
            onTap: () => _openLink('https://instagram.com/quizlymarket'),
          ),
          const SizedBox(height: 10),
          _LinkCard(
            leading: Assets.lib.images.telegramLogo.image(package: 'ui', width: 22, height: 22),
            title: 't.me/quizlymarket',
            onTap: () => _openLink('https://t.me/quizlymarket'),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(title, style: context.x.textStyle.sfW700s18.copyWith(color: color));
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.leading, required this.title, required this.onTap, this.subtitle});

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.x.colors.cardBackground2,
    borderRadius: .circular(14),
    child: InkWell(
      borderRadius: .circular(14),
      onTap: onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 28, height: 28, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
                  children: [
                    TextSpan(text: title),
                    if (subtitle != null) ...[
                      TextSpan(
                        text: ' - $subtitle',
                        style: context.x.textStyle.sfW400s16.copyWith(color: context.x.colors.gray),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
