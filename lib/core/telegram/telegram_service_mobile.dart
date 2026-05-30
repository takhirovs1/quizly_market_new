import 'telegram_service.dart';

/// Factory function invoked by the conditional import on non-web platforms.
TelegramService createTelegramService() => _MobileTelegramService();

/// Stub implementation for iOS / Android.
///
/// Every method is a safe no-op so that code referencing
/// [TelegramService] compiles and runs without errors on mobile.
class _MobileTelegramService extends TelegramService {
  @override
  bool get isSupported => false;

  @override
  String get initDataRaw => '';

  @override
  TelegramSafeAreaInset get safeAreaInset => TelegramSafeAreaInset.zero;

  @override
  TelegramSafeAreaInset get contentSafeAreaInset => TelegramSafeAreaInset.zero;

  @override
  void ready() {}

  @override
  void expand() {}

  @override
  void close() {}

  @override
  void requestFullscreen() {}

  @override
  void disableVerticalSwipes() {}

  @override
  void enableClosingConfirmation() {}

  @override
  void disableClosingConfirmation() {}

  @override
  void hapticImpact(TelegramHapticImpact impact) {}

  @override
  void hapticNotification(TelegramHapticNotification type) {}

  @override
  void showBackButton(void Function() onPressed) {}

  @override
  void hideBackButton(void Function() onPressed) {}

  @override
  void openLink(String url, {bool tryInstantView = true}) {}

  @override
  void openTelegramLink(String url) {}

  @override
  void addToHomeScreen() {}
}
