import 'telegram_service_mobile.dart' if (dart.library.js_interop) 'telegram_service_web.dart';

/// Platform-agnostic abstraction over the Telegram Web App SDK.
///
/// On web, this delegates to the real `telegram_web_app` package.
/// On mobile (iOS/Android), all methods are safe no-ops.
abstract class TelegramService {
  /// Singleton instance resolved via conditional import.
  static final TelegramService instance = createTelegramService();

  // ── Identity ──────────────────────────────────────────────────────

  /// Whether the Telegram Web App JS bridge is available.
  bool get isSupported;

  /// Raw init data string for server-side validation.
  String get initDataRaw;

  /// Start parameter passed in the Telegram link (tgWebAppStartParam).
  String? get startParam;

  // ── Safe area ─────────────────────────────────────────────────────

  /// System safe-area insets (notch, nav-bar, etc.).
  TelegramSafeAreaInset get safeAreaInset;

  /// Content safe-area insets (Telegram UI overlap).
  TelegramSafeAreaInset get contentSafeAreaInset;

  // ── Lifecycle ─────────────────────────────────────────────────────

  void ready();
  void expand();
  void close();
  void requestFullscreen();

  // ── Configuration ─────────────────────────────────────────────────

  void disableVerticalSwipes();
  void enableClosingConfirmation();
  void disableClosingConfirmation();

  // ── Haptics ───────────────────────────────────────────────────────

  void hapticImpact(TelegramHapticImpact impact);
  void hapticNotification(TelegramHapticNotification type);

  // ── Back button ───────────────────────────────────────────────────

  void showBackButton(void Function() onPressed);
  void hideBackButton(void Function() onPressed);
  void removeBackButtonListener(void Function() onPressed);

  // ── Links & sharing ───────────────────────────────────────────────

  void openLink(String url, {bool tryInstantView = true});
  void openTelegramLink(String url);

  // ── Home screen ───────────────────────────────────────────────────

  void addToHomeScreen();
}

// ── Value objects (platform-independent) ────────────────────────────

/// Simple inset data holder that doesn't depend on any web package.
class TelegramSafeAreaInset {
  const TelegramSafeAreaInset({this.top = 0, this.bottom = 0, this.left = 0, this.right = 0});
  final int top;
  final int bottom;
  final int left;
  final int right;

  static const zero = TelegramSafeAreaInset();
}

/// Impact haptic feedback styles.
enum TelegramHapticImpact { light, medium, heavy, rigid, soft }

/// Notification haptic feedback types.
enum TelegramHapticNotification { error, success, warning }
