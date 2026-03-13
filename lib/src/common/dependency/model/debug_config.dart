import 'package:meta/meta.dart';

import '../../constant/config.dart';

/// {@template debug_config}
/// App debug settings
/// {@endtemplate}
@immutable
final class DebugConfig {
  /// {@macro debug_config}
  const DebugConfig({required this.debuggerEnabled, this.telegramChatId, this.telegramBotToken});

  factory DebugConfig.fromJson(Map<String, Object?> json) => DebugConfig(
    debuggerEnabled: !Config.environment.isProduction,
    telegramChatId: json['TELEGRAM_CHAT_ID']?.toString(),
    telegramBotToken: json['TELEGRAM_BOT_TOKEN']?.toString(),
  );

  final bool debuggerEnabled;
  final String? telegramChatId;
  final String? telegramBotToken;

  /// Copy the [DebugConfig] with new values.
  DebugConfig copyWith({bool? debuggerEnabled, String? telegramChatId, String? telegramBotToken}) => DebugConfig(
    debuggerEnabled: debuggerEnabled ?? this.debuggerEnabled,
    telegramChatId: telegramChatId ?? this.telegramChatId,
    telegramBotToken: telegramBotToken ?? this.telegramBotToken,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DebugConfig &&
        other.debuggerEnabled == debuggerEnabled &&
        other.telegramChatId == telegramChatId &&
        other.telegramBotToken == telegramBotToken;
  }

  @override
  int get hashCode => debuggerEnabled.hashCode ^ telegramChatId.hashCode ^ telegramBotToken.hashCode;

  @override
  String toString() =>
      'DebugConfig('
      'debuggerEnabled: $debuggerEnabled, '
      'telegramChatId: $telegramChatId, '
      'telegramBotToken: $telegramBotToken'
      ')';
}
