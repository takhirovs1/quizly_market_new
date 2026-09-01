import 'package:flutter/services.dart';
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
  String? get startParam {
    try {
      final param = Uri.base.queryParameters['tgWebAppStartParam'];
      if (param != null && param.isNotEmpty) {
        return param;
      }
    } catch (_) {}
    return null;
  }

  @override
  TelegramSafeAreaInset get safeAreaInset => .zero;

  @override
  TelegramSafeAreaInset get contentSafeAreaInset => .zero;

  @override
  void ready() {}

  @override
  void expand() {}

  @override
  void close() {}

  @override
  void requestFullscreen() {}

  @override
  void exitFullscreen() {}

  @override
  bool get isFullscreen => false;

  @override
  void disableVerticalSwipes() {}

  @override
  void enableClosingConfirmation() {}

  @override
  void disableClosingConfirmation() {}

  @override
  void hapticImpact(TelegramHapticImpact impact) {
    switch (impact) {
      case TelegramHapticImpact.light:
        HapticFeedback.lightImpact();
        break;
      case TelegramHapticImpact.medium:
        HapticFeedback.mediumImpact();
        break;
      case TelegramHapticImpact.heavy:
        HapticFeedback.heavyImpact();
        break;
      case TelegramHapticImpact.rigid:
      case TelegramHapticImpact.soft:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  void hapticNotification(TelegramHapticNotification type) {
    switch (type) {
      case TelegramHapticNotification.error:
        HapticFeedback.vibrate();
        break;
      case TelegramHapticNotification.success:
      case TelegramHapticNotification.warning:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  @override
  void showBackButton(void Function() onPressed) {}

  @override
  void hideBackButton(void Function() onPressed) {}

  @override
  void removeBackButtonListener(void Function() onPressed) {}

  @override
  void openLink(String url, {bool tryInstantView = true}) {}

  @override
  void openTelegramLink(String url) {}

  @override
  void addToHomeScreen() {}
}
