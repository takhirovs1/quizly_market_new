import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text, Colors;
import 'package:logbook/logbook.dart';

sealed class ErrorUtil {
  const ErrorUtil._();

  static Future<void> logError(Object exception, StackTrace stackTrace, {String? hint}) async {
    try {
      // if (Firebase.apps.isNotEmpty) _$captureException(exception, stackTrace, hint).ignore();

      // TelegramBotErrorLogger.log(error: exception, stackTrace: stackTrace).ignore();

      l.s(exception, stackTrace);
    } on Object catch (error, stackTrace) {
      l.s('Error while logging error "$error" inside ErrorUtil.logError', stackTrace);
    }
  }

  static Never throwWithStackTrace(Object error, StackTrace stackTrace) => Error.throwWithStackTrace(error, stackTrace);

  static void showSnackBar(BuildContext context, Object message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message'), backgroundColor: Colors.red));
}

// Future<void> _$captureException(Object exception, StackTrace stackTrace, String? hint) =>
//     FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: hint);
