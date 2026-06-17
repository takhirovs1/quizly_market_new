import 'package:telegram_web_app/telegram_web_app.dart';

bool isTelegramMiniApp() {
  try {
    return TelegramWebApp.instance.initData.raw.isNotEmpty;
  } on Object catch (_) {
    return false;
  }
}
