import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../state/app_info_state.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends AppInfoState {
  @override
  Widget build(BuildContext context) {
    final isMobile = context.x.isMobile || context.x.isTablet;

    return Scaffold(
      backgroundColor: context.x.colors.scaffoldBackground,
      appBar: QuizAppBar(
        telegramWebAppSafeAreaInsetTop: context.telegramWebApp.safeAreaInset.top.toDouble(),
        title: context.x.l10n.app_info,
      ),
      body: SafeArea(
        child: isMobile
            ? ListView(padding: const .fromLTRB(16, 16, 16, 24), children: _buildContent(context))
            : Center(
                child: SingleChildScrollView(
                  padding: const .symmetric(vertical: 24, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.x.colors.cardBackground2,
                        borderRadius: .circular(20),
                        border: Border.all(color: context.x.colors.divider),
                      ),
                      child: Padding(
                        padding: const .all(24),
                        child: Column(
                          crossAxisAlignment: .stretch,
                          mainAxisSize: .min,
                          children: _buildContent(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) => [
    Text(context.x.l10n.title, style: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text)),
    const SizedBox(height: 8),
    Text(
      context.x.l10n.appInfoDescription,
      style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
    ),
    const SizedBox(height: 20),
    SectionTitle(title: context.x.l10n.apps, color: context.x.colors.text),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.vectors.google.svg(package: 'ui', width: 22, height: 22),
      title: 'GooglePlay',
      subtitle: ' - QuizlyMarket',
      isComingSoon: true,
      onTap: () => openLink('https://play.google.com/store'),
    ),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.vectors.apple.svg(
        package: 'ui',
        width: 22,
        height: 22,
        colorFilter: .mode(context.x.colors.text, .srcIn),
      ),
      title: 'AppStore',
      subtitle: ' - QuizlyMarket',
      isComingSoon: true,
      onTap: () => openLink('https://www.apple.com/app-store/'),
    ),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.images.telegramLogo.image(package: 'ui', width: 22, height: 22),
      title: 'Telegram',
      subtitle: ' - t.me/quizlymarketbot',
      onTap: () => openLink('https://t.me/quizlymarketbot'),
    ),
    const SizedBox(height: 20),
    SectionTitle(title: context.x.l10n.socialNetworks, color: context.x.colors.text),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.vectors.instagram.svg(package: 'ui', width: 22, height: 22),
      title: 'instagram.com/',
      subtitle: 'quizlymarket',
      onTap: () => openLink('https://instagram.com/quizlymarket'),
    ),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.images.telegramLogo.image(package: 'ui', width: 22, height: 22),
      title: 't.me/',
      subtitle: 'quizlymarket',
      onTap: () => openLink('https://t.me/quizlymarket'),
    ),
    const SizedBox(height: 20),
    SectionTitle(title: context.x.l10n.appVersion, color: context.x.colors.text),
    const SizedBox(height: 10),
    Text(appVersionLine(context), style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text)),
  ];
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, required this.color, super.key});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(title, style: context.x.textStyle.sfW700s18.copyWith(color: color));
}

class LinkCard extends StatelessWidget {
  const LinkCard({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isComingSoon = false,
    super.key,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isComingSoon;

  @override
  Widget build(BuildContext context) {
    final colors = context.x.colors;
    final textStyle = context.x.textStyle;
    return Material(
      color: colors.scaffoldBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isComingSoon ? null : onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox(width: 28, height: 28, child: Center(child: leading)),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    maxLines: 3,
                    overflow: .ellipsis,
                    text: subtitle != null
                        ? TextSpan(
                            style: textStyle.sfW400s16.copyWith(color: colors.text),
                            children: [
                              TextSpan(
                                text: title,
                                style: textStyle.sfW700s16.copyWith(color: colors.text),
                              ),
                              TextSpan(text: subtitle ?? ''),
                            ],
                          )
                        : TextSpan(
                            text: title,
                            style: textStyle.sfW700s16.copyWith(color: colors.text),
                          ),
                  ),
                ),
                if (isComingSoon) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const .symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: .circular(20),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      context.x.l10n.comingSoon,
                      style: textStyle.sfW500s11.copyWith(color: colors.primary, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
