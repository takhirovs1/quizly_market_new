
import 'package:telegram_web_app/telegram_web_app.dart';

import '../../ui.dart';

extension BuildContextX on BuildContext {
  /// [Build] extension
  Build get x => Build(this);

}

extension type Build(BuildContext context) {
  /// [ThemeData] extension
  ThemeData get theme => Theme.of(context);

  /// [ThemeColors] extension
  ThemeColors get colors => theme.appColors;

  /// [AppTypography] extension
  AppTypography get textStyle => theme.appTextStyles;

  /// [TelegramWebApp] extension
  TelegramWebApp get telegramWebApp => TelegramWebApp.instance;
}

extension TelegramWebAppX on BuildContext {
  TelegramWebApp get telegramWebApp => TelegramWebApp.instance;
  // WebAppUser? get telegramUser => telegramWebApp.initDataUnsafe?.user;

  void close() => telegramWebApp.close();
  void ready() => telegramWebApp.ready();
  void expand() => telegramWebApp.expand();
  void disableVerticalSwipes() => telegramWebApp.disableVerticalSwipes();
  void disableClosingConfirmation() => telegramWebApp.disableClosingConfirmation();
  void enableClosingConfirmation() => telegramWebApp.enableClosingConfirmation();
}
