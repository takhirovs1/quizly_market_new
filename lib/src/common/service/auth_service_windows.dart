import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:url_launcher/url_launcher.dart';

import '../../feature/authentication/model/auth_service_response.dart';

// TODO(setup): Create a "Desktop app" OAuth 2.0 client in Google Cloud Console
// (APIs & Services → Credentials → + Create Credentials → OAuth client ID →
// Application type: Desktop app). Copy the client ID and secret below.
// The web client ID cannot be used here because web-type clients require a
// client secret that must NOT be embedded in desktop binaries; desktop-type
// clients have a "relaxed" secret that is intentionally public.
const _windowsClientId = 'YOUR_DESKTOP_CLIENT_ID.apps.googleusercontent.com';
const _windowsClientSecret = 'YOUR_DESKTOP_CLIENT_SECRET';

Future<AuthServiceResponse?> signInWithGoogleWindows() async {
  // Bind to a random free port so we can receive the OAuth redirect.
  final serverSocket = await ServerSocket.bind('localhost', 0);
  final port = serverSocket.port;
  await serverSocket.close();

  final codeVerifier = _generateCodeVerifier();
  final codeChallenge = _generateCodeChallenge(codeVerifier);
  final state = _generateState();
  final redirectUri = 'http://localhost:$port';

  final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': _windowsClientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': 'openid email profile',
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
    'state': state,
    'access_type': 'offline',
  });

  if (!await launchUrl(authUrl, mode: .externalApplication)) {
    return null;
  }

  final authCode = await _listenForCode(port: port, expectedState: state);
  if (authCode == null) return null;

  final tokenData = await _exchangeCodeForTokens(
    authCode: authCode,
    codeVerifier: codeVerifier,
    redirectUri: redirectUri,
  );
  if (tokenData == null) return null;

  final idToken = tokenData['id_token'] as String?;
  if (idToken == null || idToken.isEmpty) return null;

  return AuthServiceResponse(idToken: idToken);
}

Future<String?> _listenForCode({required int port, required String expectedState}) async {
  final completer = Completer<String?>();

  final server = await shelf_io.serve(
    (request) {
      final code = request.url.queryParameters['code'];
      final returnedState = request.url.queryParameters['state'];

      if (returnedState != expectedState || code == null || code.isEmpty) {
        if (!completer.isCompleted) completer.complete(null);
        return Response.ok(
          '<html><body><h3>Sign-in failed. Please close this tab and try again.</h3></body></html>',
          headers: {'content-type': 'text/html'},
        );
      }

      if (!completer.isCompleted) completer.complete(code);
      return Response.ok(
        '<html><body><h3>Sign-in successful! You can close this tab.</h3></body></html>',
        headers: {'content-type': 'text/html'},
      );
    },
    'localhost',
    port,
  );

  // Timeout after 5 minutes to avoid hanging forever.
  Future<void>.delayed(const Duration(minutes: 5), () {
    if (!completer.isCompleted) completer.complete(null);
  });

  final code = await completer.future;
  await server.close(force: true);
  return code;
}

Future<Map<String, dynamic>?> _exchangeCodeForTokens({
  required String authCode,
  required String codeVerifier,
  required String redirectUri,
}) async {
  try {
    final dio = Dio();
    final response = await dio.post<Map<String, dynamic>>(
      'https://oauth2.googleapis.com/token',
      data: {
        'client_id': _windowsClientId,
        'client_secret': _windowsClientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        'code': authCode,
        'code_verifier': codeVerifier,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  } on Object catch (_) {
    return null;
  }
}

String _generateCodeVerifier() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

String _generateCodeChallenge(String verifier) {
  final bytes = utf8.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64Url.encode(digest.bytes).replaceAll('=', '');
}

String _generateState() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}
