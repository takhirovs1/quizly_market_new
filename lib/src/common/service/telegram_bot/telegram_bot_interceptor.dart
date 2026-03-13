import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:logbook/logbook.dart';
import 'package:meta/meta.dart';
import 'package:thunder/thunder.dart';

import '../../constant/config.dart';
import '../../constant/pubspec.yaml.g.dart';
import '../../dependency/model/debug_config.dart';
import '../../extension/string_extension.dart';
import 'telegram_bot_config.dart';

/// {@template telegram_bot_interceptor}
/// TelegramBotInterceptor class
/// {@endtemplate}
class TelegramBotInterceptor extends Interceptor {
  /// {@macro telegram_bot_interceptor}
  @literal
  const TelegramBotInterceptor({
    required this.config,
    this.requests = false,
    this.responses = true,
    this.errors = true,
  });

  static const String _stopwatchKey = '@stopwatch';

  final bool requests;
  final bool responses;
  final bool errors;
  final DebugConfig config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Start timing the request
    options.extra[_stopwatchKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      final now = DateTime.now();

      final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      // Calculate response time
      final responseTime = _extractElapsedTime(err.requestOptions);

      late final String deviceData;

      if (Platform.isIOS) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        deviceData =
            '''
<b>Device:</b> ${_escapeHtml(deviceInfo.modelName)}
<b>OS:</b> ${_escapeHtml(deviceInfo.systemName)} ${_escapeHtml(deviceInfo.systemVersion)}
<b>App Version:</b> ${_escapeHtml(Pubspec.version.representation)}''';
      } else {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        deviceData =
            '''
<b>Device:</b> ${_escapeHtml(deviceInfo.model)}
<b>OS:</b> Android ${_escapeHtml(deviceInfo.version.release)}
<b>App Version:</b> ${_escapeHtml(Pubspec.version.representation)}''';
      }

      // Format request headers
      final headers = err.requestOptions.headers.entries
          .map((e) => '${e.key}: ${_escapeHtml(e.value.toString())}')
          .join('\n');

      // Format query parameters
      final queryParams = err.requestOptions.queryParameters.entries
          .map((e) => '${e.key}: ${_escapeHtml(e.value.toString())}')
          .join('\n');

      // Format request body
      final requestBody = err.requestOptions.data?.toString() ?? 'No request body';
      final truncatedBody = requestBody.length > 300 ? '${requestBody.ellipsis(300)}...' : requestBody;

      final errorDetails =
          '''
<b>URL:</b> <pre>${_escapeHtml(err.requestOptions.uri.toString())}</pre>
<b>Error Type:</b> ${_escapeHtml(err.type.name)}
<b>Method:</b> ${_escapeHtml(err.requestOptions.method)}
<b>Response Time:</b> $responseTime
<b>Message:</b> ${_escapeHtml(err.message ?? 'No message').ellipsis(100)}''';

      final requestDetails =
          '''
📋 <b>REQUEST DETAILS</b>

<b>Headers:</b>
<pre>${headers.isNotEmpty ? _escapeHtml(headers) : 'No headers'}</pre>

<b>Query Parameters:</b>
<pre>${queryParams.isNotEmpty ? _escapeHtml(queryParams) : 'No query parameters'}</pre>

<b>Request Body:</b>
<pre>${_escapeHtml(truncatedBody)}</pre>''';

      final responseData = err.response?.data?.toString() ?? 'No response data';
      final responseInfo = err.response != null
          ? '''
<b>Status Code:</b> ${err.response?.statusCode}
<b>Response:</b> <code>${_escapeHtml(responseData.length > 200 ? '${responseData.ellipsis(200)}...' : responseData)}</code>'''
          : '''
<b>Status Code:</b> No response received''';

      final stackTrace = err.stackTrace.toString();
      final truncatedStackTrace = stackTrace.length > 300 ? '${stackTrace.ellipsis(200)}...' : stackTrace;

      final text =
          '''
#quizly_market #backend  │  <b>logger_version: ${TelegramConfig.version}</b>
🚨 <b>ERROR REPORT</b>

📅 <b>Date:</b> $formattedDate  │  🕐 <b>Time:</b> $formattedTime  │  🌍 <b>Timezone:</b> ${DateTime.now().timeZoneName}

$deviceData

$errorDetails

$requestDetails

$responseInfo

⚡ <b>Stack Trace:</b>
<pre>${_escapeHtml(truncatedStackTrace)}</pre>
''';

      final payload = <String, Object?>{'chat_id': config.telegramChatId, 'text': text, 'parse_mode': 'HTML'};

      final dio = Thunder.addDio(Dio());

      final res = await dio.post<Map<String, Object?>?>(
        '${Config.telegramApiBaseUrl}/bot${config.telegramBotToken}/sendMessage',
        data: payload,
      );

      l.i('📤 Telegram notification sent: ${res.statusCode}');
      l.i('📋 Error details logged: ${err.type.name} at ${err.requestOptions.uri}');
    } on Object catch (error, stackTrace) {
      l.s(error, stackTrace);
    }

    handler.next(err);
  }

  String _extractElapsedTime(RequestOptions options) {
    if (options.extra[_stopwatchKey] case final Stopwatch sw) {
      return '${(sw..stop()).elapsedMilliseconds} ms';
    }
    return 'Unknown';
  }

  // Escape special characters for HTML
  String _escapeHtml(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;');
}
