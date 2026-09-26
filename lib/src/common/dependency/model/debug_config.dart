import 'package:meta/meta.dart';

import '../../constant/config.dart';

/// {@template debug_config}
/// App debug settings
/// {@endtemplate}
@immutable
final class DebugConfig {
  /// {@macro debug_config}
  const DebugConfig({
    required this.debuggerEnabled,
    this.thunderEnabled = false,
    this.telegramChatId,
    this.telegramBotToken,
  });

  factory DebugConfig.fromJson(Map<String, Object?> json) => DebugConfig(
    debuggerEnabled: !Config.environment.isProduction,
    thunderEnabled: !Config.environment.isProduction,
    telegramChatId: json['TELEGRAM_CHAT_ID']?.toString(),
    telegramBotToken: json['TELEGRAM_BOT_TOKEN']?.toString(),
  );

  final bool debuggerEnabled;
  final bool thunderEnabled;
  final String? telegramChatId;
  final String? telegramBotToken;

  /// Copy the [DebugConfig] with new values.
  DebugConfig copyWith({
    bool? debuggerEnabled,
    bool? thunderEnabled,
    String? telegramChatId,
    String? telegramBotToken,
  }) => DebugConfig(
    debuggerEnabled: debuggerEnabled ?? this.debuggerEnabled,
    thunderEnabled: thunderEnabled ?? this.thunderEnabled,
    telegramChatId: telegramChatId ?? this.telegramChatId,
    telegramBotToken: telegramBotToken ?? this.telegramBotToken,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DebugConfig &&
        other.debuggerEnabled == debuggerEnabled &&
        other.thunderEnabled == thunderEnabled &&
        other.telegramChatId == telegramChatId &&
        other.telegramBotToken == telegramBotToken;
  }

  @override
  int get hashCode =>
      debuggerEnabled.hashCode ^ thunderEnabled.hashCode ^ telegramChatId.hashCode ^ telegramBotToken.hashCode;

  @override
  String toString() =>
      'DebugConfig('
      'debuggerEnabled: $debuggerEnabled, '
      'thunderEnabled: $thunderEnabled, '
      'telegramChatId: $telegramChatId, '
      'telegramBotToken: $telegramBotToken'
      ')';
}
