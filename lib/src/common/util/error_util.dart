import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text, Colors;
import 'package:logbook/logbook.dart';

import '../extension/context_extension.dart';

sealed class ErrorUtil {
  const ErrorUtil._();

  static String toUserFriendlyMessage(Object error) {
    if (error is DioException) {
      final type = error.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.sendTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.connectionError) {
        return 'connectionError';
      }
    }
    return 'somethingWentWrong';
  }

  static String localizeError(BuildContext context, String? error) {
    if (error == null || error.isEmpty) return '';
    final l10n = context.x.l10n;
    if (error == 'connectionError') {
      return l10n.connectionError;
    }
    if (error == 'somethingWentWrong') {
      return l10n.somethingWentWrong;
    }
    if (error == 'pleaseTryAgainLater') {
      return l10n.pleaseTryAgainLater;
    }
    return error;
  }

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

  static void showSnackBar(BuildContext context, Object message) {
    final String displayMessage;
    if (message is String) {
      displayMessage = localizeError(context, message);
    } else {
      displayMessage = localizeError(context, toUserFriendlyMessage(message));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(displayMessage), backgroundColor: Colors.red));
  }
}

// Future<void> _$captureException(Object exception, StackTrace stackTrace, String? hint) =>
//     FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: hint);
