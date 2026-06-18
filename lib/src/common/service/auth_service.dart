import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../feature/authentication/model/auth_service_response.dart';
import '../util/platform_info.dart';
import '../util/telegram_detector.dart';
import 'auth_service_windows_stub.dart' if (dart.library.io) 'auth_service_windows.dart';

const _webClientId = '568369386495-mhssl36boosa0qjksku66rr9rngk2lvm.apps.googleusercontent.com';

final class AuthService {
  const AuthService._();

  static bool _googleInitialized = false;

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  static Future<AuthServiceResponse?> signInWithGoogle() {
    if (kIsWeb && isTelegramMiniApp()) return Future.value(null);
    if (kIsWeb) return _signInWithGoogleWeb();
    if (PlatformInfo.isWindows) return signInWithGoogleWindows();
    return _signInWithGoogleNative();
  }

  static Future<AuthServiceResponse?> _signInWithGoogleWeb() async {
    try {
      final userCred = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      final idToken = (userCred.credential as OAuthCredential?)?.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      return AuthServiceResponse(idToken: idToken);
    } on FirebaseAuthException {
      rethrow;
    } on Object catch (error) {
      log('signInWithGoogleWeb error: $error');
      return null;
    }
  }

  static Future<AuthServiceResponse?> _signInWithGoogleNative() async {
    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(serverClientId: _webClientId);
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        log('signInWithGoogleNative: idToken is null');
        return null;
      }
      return AuthServiceResponse(idToken: idToken);
    } on FirebaseAuthException {
      rethrow;
    } on Object catch (error) {
      log('signInWithGoogleNative error: $error');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Apple Sign-In
  // ---------------------------------------------------------------------------

  static Future<AuthServiceResponse?> signInWithApple() {
    if (kIsWeb && isTelegramMiniApp()) return Future.value(null);
    if (kIsWeb) return _signInWithAppleWeb();
    return _signInWithAppleNative();
  }

  static Future<AuthServiceResponse?> _signInWithAppleWeb() async {
    try {
      final userCred = await FirebaseAuth.instance.signInWithPopup(
        AppleAuthProvider()
          ..addScope('email')
          ..addScope('name'),
      );
      final idToken = (userCred.credential as OAuthCredential?)?.idToken;
      if (idToken == null || idToken.isEmpty) return null;
      return AuthServiceResponse(idToken: idToken);
    } on FirebaseAuthException {
      rethrow;
    } on Object catch (error) {
      log('signInWithAppleWeb error: $error');
      return null;
    }
  }

  static Future<AuthServiceResponse?> _signInWithAppleNative() async {
    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final idToken = apple.identityToken;
      if (idToken == null || idToken.isEmpty) return null;
      return AuthServiceResponse(idToken: idToken);
    } on FirebaseAuthException {
      rethrow;
    } on Object catch (error) {
      log('signInWithAppleNative error: $error');
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Error types
// ---------------------------------------------------------------------------

enum AuthErrorCode { telegramWebviewBlocked, cancelled, accountExistsWithDifferentCredential, networkError, unknown }

final class AuthServiceException implements Exception {
  const AuthServiceException(this.code, [this.message]);

  final AuthErrorCode code;
  final String? message;

  @override
  String toString() => 'AuthServiceException($code${message != null ? ': $message' : ''})';
}
