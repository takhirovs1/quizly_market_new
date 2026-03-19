import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../feature/authentication/model/auth_service_response.dart';

final class AuthService {
  const AuthService._();

  static final GoogleSignIn _googleSignIn = .instance;

  static Future<AuthServiceResponse?> signInWithGoogleNew() async {
    try {
      await _googleSignIn.initialize();

      // ignore: unnecessary_nullable_for_final_variable_declarations
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) return null;

      String? accessToken;
      try {
        final authorization = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
        accessToken = authorization?.accessToken;

        if (accessToken == null || accessToken.isEmpty) {
          final newAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
          accessToken = newAuth.accessToken;
        }
      } on Object catch (error) {
        log('signInWithGoogleNew error: $error');
        return null;
      }

      String? firstName;
      String? lastName;
      if (googleUser.displayName != null && googleUser.displayName!.isNotEmpty) {
        final nameParts = googleUser.displayName!.trim().split(' ');
        if (nameParts.isNotEmpty) {
          firstName = nameParts.first;
          if (nameParts.length > 1) {
            lastName = nameParts.sublist(1).join(' ');
          }
        }
      }

      final idToken = googleUser.authentication.idToken ?? '';

      return AuthServiceResponse(
        accessToken: idToken,
        email: googleUser.email,
        firstName: firstName,
        lastName: lastName,
        photo: googleUser.photoUrl,
      );
    } on Object catch (error) {
      log('signInWithGoogleNew error: $error');
      return null;
    }
  }

  static Future<AuthServiceResponse?> signInWithApple() async {
    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final oauth = OAuthProvider(
        'apple.com',
      ).credential(idToken: apple.identityToken, accessToken: apple.authorizationCode);
      final userCred = await FirebaseAuth.instance.signInWithCredential(oauth);

      var firstName = apple.givenName;
      var lastName = apple.familyName;

      if ((firstName == null || firstName.isEmpty) && userCred.user?.displayName != null) {
        final nameParts = userCred.user!.displayName!.trim().split(' ');
        if (nameParts.isNotEmpty) {
          firstName = nameParts.first;
          if (nameParts.length > 1) {
            lastName = nameParts.sublist(1).join(' ');
          }
        }
      }

      log('apple: ${apple.toString()}');

      return AuthServiceResponse(
        accessToken: userCred.credential?.accessToken,
        email: userCred.user?.email ?? apple.email,
        firstName: firstName,
        lastName: lastName,
        photo: userCred.user?.photoURL,
      );
    } on Object catch (error) {
      log('signInWithApple error: $error');
      return null;
    }
  }
}
