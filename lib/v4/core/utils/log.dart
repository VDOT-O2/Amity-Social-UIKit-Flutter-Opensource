import 'dart:developer' as developer;

import 'package:amity_uikit_beta_service/v4/core/utils/log_level.dart';
import 'package:flutter/foundation.dart';

const String tag = 'AmityUIKit';
const String kDebugTrackTag = 'AmityDebug';

class AmityLog {
  static AmityLogLevel logLevel = kDebugMode ? AmityLogLevel.debug : AmityLogLevel.info;

  static void verbose(String message) {
    if (_ignoreLogLevel(AmityLogLevel.verbose)) {
      return;
    }

    _logMessage('[$tag] $message', name: 'AMITY_VERBOSE');
  }

  static void debug(String message) {
    if (_ignoreLogLevel(AmityLogLevel.debug)) {
      return;
    }

    _logMessage('[$tag] $message', name: 'AMITY_DEBUG');
  }

  static void info(String message) {
    if (_ignoreLogLevel(AmityLogLevel.info)) {
      return;
    }

    _logMessage('[$tag] $message', name: 'AMITY_INFO');
  }

  static void warn(String message) {
    if (_ignoreLogLevel(AmityLogLevel.warn)) {
      return;
    }

    _logMessage('[$tag] $message', name: 'AMITY_WARN');
  }

  static void error(String message, dynamic error, {StackTrace? stackTrace}) {
    if (_ignoreLogLevel(AmityLogLevel.error)) {
      return;
    }

    final errorObject = error is Error ? error : null;

    var stackTraceText = stackTrace?.toString() ?? errorObject?.stackTrace?.toString() ?? '';
    if ((stackTraceText.length) > 1000) {
      stackTraceText = stackTraceText.substring(0, 1000);
    }

    final errorMessage = error?.toString();

    _logMessage(
      '[$tag] $message',
      name: 'AMITY_ERROR',
      error: '🟥 [$tag] $message: $errorMessage${stackTraceText.isEmpty ? '' : '\r\nstack: $stackTraceText'}',
    );
  }

  static Future fatal(String message, dynamic error, {StackTrace? stackTrace}) async {
    final logStackTrace = stackTrace ?? (error is Error ? error.stackTrace : null);

    AmityLog.error(message, error, stackTrace: logStackTrace);
  }

  static void raw(String message) {
    developer.log(message, name: 'AMITY_LOG');
  }

  static bool _ignoreLogLevel(AmityLogLevel logLevel) {
    return AmityLog.logLevel.index > logLevel.index;
  }

  static void _logMessage(String message, {String name = '', dynamic error}) {
    return developer.log(message, name: name, error: error);
  }
}
