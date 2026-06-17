import 'package:flutter/foundation.dart';

final class PlatformInfo {
  const PlatformInfo._();

  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == .iOS;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == .android;
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == .macOS;
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == .windows;

  /// Apple Sign-In is required on iOS/macOS and available via Firebase popup on web.
  static bool get showAppleSignIn => isIOS || isMacOS || isWeb;
}
