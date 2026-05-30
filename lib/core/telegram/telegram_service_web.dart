import 'package:telegram_web_app/telegram_web_app.dart';

import 'telegram_service.dart';

/// Factory function invoked by the conditional import on web.
TelegramService createTelegramService() => _WebTelegramService();

/// Real implementation backed by the `telegram_web_app` package.
///
/// This file is only compiled on web thanks to the conditional
/// import in [telegram_service.dart].
class _WebTelegramService extends TelegramService {
  final TelegramWebApp _tg = TelegramWebApp.instance;

  // ── Identity ──────────────────────────────────────────────────────

  @override
  bool get isSupported => _tg.isSupported;

  @override
  String get initDataRaw => _tg.initData.raw;

  // ── Safe area ─────────────────────────────────────────────────────

  @override
  TelegramSafeAreaInset get safeAreaInset => TelegramSafeAreaInset(
    top: _tg.safeAreaInset.top,
    bottom: _tg.safeAreaInset.bottom,
    left: _tg.safeAreaInset.left,
    right: _tg.safeAreaInset.right,
  );

  @override
  TelegramSafeAreaInset get contentSafeAreaInset => TelegramSafeAreaInset(
    top: _tg.contentSafeAreaInset.top,
    bottom: _tg.contentSafeAreaInset.bottom,
    left: _tg.contentSafeAreaInset.left,
    right: _tg.contentSafeAreaInset.right,
  );

  // ── Lifecycle ─────────────────────────────────────────────────────

  @override
  void ready() => _tg.ready();

  @override
  void expand() => _tg.expand();

  @override
  void close() => _tg.close();

  @override
  void requestFullscreen() => _tg.requestFullscreen();

  // ── Configuration ─────────────────────────────────────────────────

  @override
  void disableVerticalSwipes() => _tg.disableVerticalSwipes();

  @override
  void enableClosingConfirmation() => _tg.enableClosingConfirmation();

  @override
  void disableClosingConfirmation() => _tg.disableClosingConfirmation();

  // ── Haptics ───────────────────────────────────────────────────────

  @override
  void hapticImpact(TelegramHapticImpact impact) {
    _tg.hapticFeedback.impactOccurred(_mapImpact(impact));
  }

  @override
  void hapticNotification(TelegramHapticNotification type) {
    _tg.hapticFeedback.notificationOccurred(_mapNotification(type));
  }

  static HapticFeedbackImpact _mapImpact(TelegramHapticImpact impact) => switch (impact) {
    TelegramHapticImpact.light => HapticFeedbackImpact.light,
    TelegramHapticImpact.medium => HapticFeedbackImpact.medium,
    TelegramHapticImpact.heavy => HapticFeedbackImpact.heavy,
    TelegramHapticImpact.rigid => HapticFeedbackImpact.rigid,
    TelegramHapticImpact.soft => HapticFeedbackImpact.soft,
  };

  static HapticFeedbackNotificationType _mapNotification(TelegramHapticNotification type) => switch (type) {
    TelegramHapticNotification.error => HapticFeedbackNotificationType.error,
    TelegramHapticNotification.success => HapticFeedbackNotificationType.success,
    TelegramHapticNotification.warning => HapticFeedbackNotificationType.warning,
  };

  // ── Back button ───────────────────────────────────────────────────

  @override
  void showBackButton(void Function() onPressed) {
    _tg.backButton
      ..onClick(onPressed)
      ..show();
  }

  @override
  void hideBackButton(void Function() onPressed) {
    _tg.backButton
      ..offClick(onPressed)
      ..hide();
  }

  // ── Links & sharing ───────────────────────────────────────────────

  @override
  void openLink(String url, {bool tryInstantView = true}) => _tg.openLink(url, tryInstantView: tryInstantView);

  @override
  void openTelegramLink(String url) => _tg.openTelegramLink(url);

  // ── Home screen ───────────────────────────────────────────────────

  @override
  void addToHomeScreen() => _tg.addToHomeScreen();
}
