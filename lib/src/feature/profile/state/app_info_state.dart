import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/app_info_screen.dart';

abstract class AppInfoState extends State<AppInfoScreen> {
  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
  }

  @override
  void dispose() {
    super.dispose();
    context.teardownTelegramBackButton();
  }

  Future<void> openLink(String url) async {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    await launchUrl(.parse(url));
  }

  Future<void> openTelegramLink(String url) async {
    context.telegramWebApp.hapticFeedback.impactOccurred(.light);
    if (context.telegramWebApp.isSupported) {
      context.telegramWebApp.openLink(url, tryInstantView: false);
      return;
    }
    await launchUrl(.parse(url));
  }

  /// Telegram Mini Appda — `QuizlyMarket Telegram App 2.0.0(47)`; aks holda — `QuizlyMarket Mobile …`.
  String appVersionLine(BuildContext context) {
    final meta = context.x.dependencies.metadata;
    final version = meta.appVersion;
    if (context.telegramWebApp.isSupported) {
      return 'QuizlyMarket Telegram App $version';
    }
    return 'QuizlyMarket Mobile $version';
  }
}
