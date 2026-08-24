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
            ? ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: _buildContent(context))
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.x.colors.cardBackground2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.x.colors.divider),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
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
      onTap: () => openLink('https://play.google.com/store/apps/details?id=uz.corelabs.quizlymarket'),
    ),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.vectors.apple.svg(
        package: 'ui',
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(context.x.colors.text, BlendMode.srcIn),
      ),
      title: 'AppStore',
      subtitle: ' - iPhone / iPad',
      onTap: () => openLink('https://apps.apple.com/uz/app/quizlymarket/id6780981469'),
    ),
    const SizedBox(height: 10),
    LinkCard(
      leading: Assets.lib.vectors.apple.svg(
        package: 'ui',
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(context.x.colors.text, BlendMode.srcIn),
      ),
      title: 'AppStore',
      subtitle: ' - macOS',
      onTap: () => openLink('https://apps.apple.com/uz/app/quizlymarket/id6780981469?mt=12'),
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
