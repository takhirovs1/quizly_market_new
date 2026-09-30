import 'package:logbook/logbook.dart';
import 'package:thunder/thunder.dart';

import '../service/api_client.dart';

ApiClientHandler httpLogMiddleware(ApiClientHandler next) => (request, context) async {
  final stopwatch = Stopwatch()..start();
  try {
    final response = await next(request, context);
    stopwatch.stop();
    l.f(
      '${request.method} > ${request.url} > '
      '${response.statusCode} | ${stopwatch.elapsedMilliseconds} ms',
    );
    return response;
  } on ApiResponseException catch (e) {
    stopwatch.stop();
    l.w(
      '${request.method} > ${request.url} > '
      '${e.statusCode} | ${stopwatch.elapsedMilliseconds} ms',
    );
    rethrow;
  } on ApiNetworkException catch (e) {
    stopwatch.stop();
    l.w(
      '${request.method} > ${request.url} > '
      '${e.message} | ${stopwatch.elapsedMilliseconds} ms',
    );
    rethrow;
  }
};
