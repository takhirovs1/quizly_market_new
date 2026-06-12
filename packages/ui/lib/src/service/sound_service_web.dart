import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Plays audio from a data-URI using the browser's HTMLAudioElement.
void playAudioDataUri(String dataUri) {
  try {
    final audio = web.HTMLAudioElement()..src = dataUri;
    audio.play().toDart.ignore();
  } on Object catch (_) {
    // Ignore playback errors (e.g. autoplay policy).
  }
}
