import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logbook/logbook.dart';

import '../../constant/pubspec.yaml.g.dart';
import '../../dependency/model/debug_config.dart';
import 'telegram_bot_config.dart';

sealed class TelegramBotErrorLogger {
  const TelegramBotErrorLogger._();

  static const Duration _rateLimitDuration = Duration(seconds: 30);
  static const int _maxStackTraceLength = 800;
  static const int _maxExceptionLength = 2000;

  static DateTime? _lastErrorSendDate;

  static final http.Client _client = .new();

  static Future<void> log({
    required Object? error,
    required StackTrace stackTrace,
    required DebugConfig config,
    Map<String, Object?>? additionalInfo,
    bool forceError = false,
  }) async {
    try {
      if ((!_shouldSendError || kDebugMode) && !forceError) return;

      _lastErrorSendDate = DateTime.now();

      final message = await _buildErrorMessage(error: error, stackTrace: stackTrace, additionalInfo: additionalInfo);

      await _sendToTelegram(message, config);
    } on Object catch (e) {
      l.s('[TelegramBotErrorLogger.log] Error while logging error to Telegram: $e');
    }
  }

  static bool get _shouldSendError {
    if (_lastErrorSendDate == null) return true;

    final timeSinceLastError = DateTime.now().difference(_lastErrorSendDate!);
    return timeSinceLastError >= _rateLimitDuration;
  }

  static Future<String> _buildErrorMessage({
    required Object? error,
    required StackTrace stackTrace,
    Map<String, Object?>? additionalInfo,
  }) async {
    final now = DateTime.now();
    final deviceInfo = await _getDeviceInfo();
    final errorDetails = _formatError(error);
    final stackTraceFormatted = _formatStackTrace(stackTrace);

    final additionalInfoFormatted = _formatAdditionalInfo(additionalInfo);

    return '''
#quizly_market #flutter_error  │  <b>logger_version: ${TelegramConfig.version}</b>
🚨 <b>ERROR REPORT</b>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 <b>Date:</b> ${_formatDate(now)}  │  🕐 <b>Time:</b> ${_formatTime(now)}  │  🌍 <b>Timezone:</b> ${now.timeZoneName}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<b>App Version:</b> ${_escapeHtml(Pubspec.version.representation)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<b>📱 Device Information</b>
$deviceInfo

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<b>❌ Error Details</b>
<pre>${_escapeHtml(errorDetails)}</pre>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${additionalInfoFormatted.isNotEmpty ? '''

<b>📍 Additional Context</b>
$additionalInfoFormatted
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

''' : ''}
<b>📍 Stack Trace</b>
<pre>${_escapeHtml(stackTraceFormatted)}</pre>
''';
  }

  static Future<String> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return '''
├ <b>Model:</b> ${_escapeHtml(iosInfo.model)}
├ <b>Device:</b> ${_escapeHtml(iosInfo.modelName)}
├ <b>OS:</b> ${_escapeHtml(iosInfo.systemName)} ${_escapeHtml(iosInfo.systemVersion)}
└ <b>App Version:</b> ${_escapeHtml(Pubspec.version.representation)}
''';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return '''
├ <b>Brand:</b> ${_escapeHtml(androidInfo.brand)}
├ <b>Model:</b> ${_escapeHtml(androidInfo.model)}
├ <b>OS:</b> Android ${_escapeHtml(androidInfo.version.release)} (SDK ${androidInfo.version.sdkInt})
└ <b>App Version:</b> ${_escapeHtml(Pubspec.version.representation)}
''';
      } else {
        return '└ <b>Platform:</b> ${Platform.operatingSystem}';
      }
    } on Object catch (_) {
      return '└ <b>Device Info:</b> Failed to retrieve';
    }
  }

  static String _formatError(Object? error) {
    if (error == null) return 'No error information available';

    var errorString = error.toString();

    if (errorString.length > _maxExceptionLength) {
      errorString = '${errorString.substring(0, _maxExceptionLength)}... [truncated]';
    }

    final errorType = error.runtimeType.toString();
    return 'Type: $errorType\n$errorString';
  }

  static String _formatStackTrace(StackTrace stackTrace) {
    final trace = stackTrace.toString();
    return trace.length > _maxStackTraceLength ? '${trace.substring(0, _maxStackTraceLength)}...' : trace;
  }

  static String _formatAdditionalInfo(Map<String, Object?>? info) {
    if (info == null || info.isEmpty) return '';
    final lines = info.entries.map((e) => '├ <b>${_escapeHtml(e.key)}:</b> ${_escapeHtml(e.value.toString())}');
    return '\n<b>📋 Additional Context</b>\n${lines.join('\n')}\n';
  }

  static Future<void> _sendToTelegram(String message, DebugConfig config) async {
    try {
      final payload = jsonEncode({
        'chat_id': config.telegramChatId,
        'text': message,
        'parse_mode': 'HTML',
        'disable_web_page_preview': true,
      });

      await _client.post(
        Uri.parse('https://api.telegram.org/bot${config.telegramBotToken}/sendMessage'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: payload,
      );
    } on Object catch (e) {
      l.s('[TelegramBotErrorLogger._sendToTelegram] Error while sending error to Telegram: $e');
    }
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  static String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}:'
      '${date.second.toString().padLeft(2, '0')}';

  static String _escapeHtml(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;');
}

extension ErrorLoggingExtension on Object {
  Future<void> logToTelegram(
    StackTrace stackTrace, {
    required DebugConfig config,
    Map<String, Object?>? additionalInfo,
    bool forceError = false,
  }) => TelegramBotErrorLogger.log(
    error: this,
    stackTrace: stackTrace,
    config: config,
    additionalInfo: additionalInfo,
    forceError: forceError,
  );
}
