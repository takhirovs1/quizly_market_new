import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:logbook/logbook.dart';
import 'package:thunder/thunder.dart';

import '../../constant/config.dart';
import '../../constant/pubspec.yaml.g.dart';
import '../../dependency/model/debug_config.dart';
import '../../extension/string_extension.dart';
import '../../service/api_client.dart';
import 'telegram_bot_config.dart';

ApiClientMiddleware telegramBotMiddleware(DebugConfig config) =>
    (next) => (request, context) async {
      final stopwatch = Stopwatch()..start();
      try {
        return await next(request, context);
      } on Object catch (e, s) {
        stopwatch.stop();
        unawaited(_sendTelegramError(e, s, request, stopwatch.elapsedMilliseconds, config));
        rethrow;
      }
    };

Future<void> _sendTelegramError(
  Object error,
  StackTrace stackTrace,
  ApiClientRequest request,
  int elapsedMs,
  DebugConfig config,
) async {
  try {
    final now = DateTime.now();
    final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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

    final headers = request.headers.entries.map((e) => '${e.key}: ${_escapeHtml(e.value)}').join('\n');
    final queryParams = request.url.queryParameters.entries.map((e) => '${e.key}: ${_escapeHtml(e.value)}').join('\n');
    final requestBodyRaw = request.body;
    final truncatedBody = requestBodyRaw.length > 300 ? '${requestBodyRaw.ellipsis(300)}...' : requestBodyRaw;

    final String statusInfo;
    final String errorTypeName;
    if (error is ApiResponseException) {
      statusInfo =
          '''
<b>Status Code:</b> ${error.statusCode}
<b>Response:</b> <code>${_escapeHtml(error.body?.toString() ?? 'No response data')}</code>''';
      errorTypeName = 'HTTP ${error.statusCode}';
    } else if (error is ApiNetworkException) {
      statusInfo = '<b>Status Code:</b> No response received';
      errorTypeName = 'NetworkError';
    } else {
      statusInfo = '<b>Status Code:</b> Unknown';
      errorTypeName = error.runtimeType.toString();
    }

    final errorMessage = error is ApiNetworkException
        ? error.message
        : error is ApiResponseException
        ? error.message
        : error.toString();

    final stackTraceStr = stackTrace.toString();
    final truncatedStack = stackTraceStr.length > 300 ? '${stackTraceStr.ellipsis(200)}...' : stackTraceStr;

    final text =
        '''
#quizly_market #backend  │  <b>logger_version: ${TelegramConfig.version}</b>
🚨 <b>ERROR REPORT</b>

📅 <b>Date:</b> $formattedDate  │  🕐 <b>Time:</b> $formattedTime  │  🌍 <b>Timezone:</b> ${DateTime.now().timeZoneName}

$deviceData

<b>URL:</b> <pre>${_escapeHtml(request.url.toString())}</pre>
<b>Error Type:</b> ${_escapeHtml(errorTypeName)}
<b>Method:</b> ${_escapeHtml(request.method)}
<b>Response Time:</b> $elapsedMs ms
<b>Message:</b> ${_escapeHtml(errorMessage.ellipsis(100))}

📋 <b>REQUEST DETAILS</b>

<b>Headers:</b>
<pre>${headers.isNotEmpty ? _escapeHtml(headers) : 'No headers'}</pre>

<b>Query Parameters:</b>
<pre>${queryParams.isNotEmpty ? _escapeHtml(queryParams) : 'No query parameters'}</pre>

<b>Request Body:</b>
<pre>${_escapeHtml(truncatedBody)}</pre>

$statusInfo

⚡ <b>Stack Trace:</b>
<pre>${_escapeHtml(truncatedStack)}</pre>
''';

    final payload = jsonEncode({'chat_id': config.telegramChatId, 'text': text, 'parse_mode': 'HTML'});

    final res = await http.post(
      .parse('${Config.telegramApiBaseUrl}/bot${config.telegramBotToken}/sendMessage'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: payload,
    );

    l.i('📤 Telegram notification sent: ${res.statusCode}');
  } on Object catch (e, s) {
    l.s(e, s);
  }
}

String _escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#x27;');
