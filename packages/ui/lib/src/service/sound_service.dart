import 'dart:convert';

import 'package:flutter/services.dart';

import 'sound_service_stub.dart' if (dart.library.js_interop) 'sound_service_web.dart';

/// Plays short sound-effect assets bundled with the **ui** package.
///
/// On web, delegates to the browser's HTML `<audio>` element via JS interop.
/// On mobile/desktop the service is a silent no-op (add native impl if needed).
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  /// Pre-encoded base-64 data-URIs keyed by asset path.
  final Map<String, String> _cache = {};

  /// Loads an asset from the **ui** package bundle and caches its data-URI.
  Future<void> preload(String assetPath) async {
    if (_cache.containsKey(assetPath)) return;
    try {
      final data = await rootBundle.load('packages/ui/$assetPath');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final b64 = base64Encode(bytes);
      _cache[assetPath] = 'data:audio/mpeg;base64,$b64';
    } on Object catch (_) {
      // Asset not found – silently ignore.
    }
  }

  /// Plays the previously-preloaded sound.
  void play(String assetPath) {
    final dataUri = _cache[assetPath];
    if (dataUri == null) return;
    playAudioDataUri(dataUri);
  }
}
