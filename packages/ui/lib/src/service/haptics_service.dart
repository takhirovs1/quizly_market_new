import 'dart:developer' as developer;

import 'package:flutter/services.dart' show HapticFeedback;

final class HapticsService {
  factory HapticsService() => _instance;
  HapticsService._internal();
  static final HapticsService _instance = HapticsService._internal();

  bool _isEnabled = true;

  static bool get isEnabled => _instance._isEnabled;
  static set isEnabled(bool value) {
    if (_instance._isEnabled != value) _instance._isEnabled = value;
  }

  static void toggle() => isEnabled = !isEnabled;

  static void lightImpact() => trigger(HapticFeedbackType.light);

  static void mediumImpact() => trigger(HapticFeedbackType.medium);

  static void heavyImpact() => trigger(HapticFeedbackType.heavy);

  static void selectionClick() => trigger(HapticFeedbackType.selectionClick);

  static void vibrate() => trigger(HapticFeedbackType.vibrate);

  static void trigger(HapticFeedbackType type) {
    if (!_instance._isEnabled) {
      _hapticsAreDisabledLog();
      return;
    }

    final _ = switch (type) {
      HapticFeedbackType.light => HapticFeedback.lightImpact().ignore(),
      HapticFeedbackType.medium => HapticFeedback.mediumImpact().ignore(),
      HapticFeedbackType.heavy => HapticFeedback.heavyImpact().ignore(),
      HapticFeedbackType.selectionClick => HapticFeedback.selectionClick().ignore(),
      HapticFeedbackType.vibrate => HapticFeedback.vibrate().ignore(),
    };
  }

  static void _hapticsAreDisabledLog() => developer.log(
    'Haptics are disabled so not triggering vibration',
    name: 'haptics',
    time: DateTime.now(),
    level: 550,
  );
}

enum HapticFeedbackType { light, medium, heavy, selectionClick, vibrate }
