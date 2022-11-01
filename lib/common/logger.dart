import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoggerFactory {
  LoggerFactory._();

  static Logger get<T>() {
    return getWithName(T.toString());
  }
  static Logger getWithName(String name) {
    return Logger(name);
  }
}

class Logger {
  final String _name;

  Logger(this._name);

  num _syncTime = 0;
  String? _syncString;

  void error(dynamic message, dynamic e) {
    print('[ERROR]  $_name: $message -> $e');
  }
  void warn(dynamic message) {
    _print('WARN', message);
  }
  void info(dynamic message) {
    _print('INFO', message);
  }
  void debug(dynamic message) {
    _print('DEBUG', message);
  }
  void _print(String level, dynamic message) {
    if (kDebugMode) debugPrint('[$level] $_name: $message');
  }

  void startSync(String name) {
    if (kDebugMode) {
      Timeline.startSync(name);
      _syncTime = DateTime.now().millisecondsSinceEpoch;
      _syncString = name;
    }
  }

  /// Finishes and logs the time, override the message with [message] if needed.
  void finishSync([String? message]) {
    if (kDebugMode) {
      if (_syncString == null) {
        warn('finishSync without startSync!');
      } else {
        if (message != null) _syncString = message;
        _syncTime = DateTime.now().millisecondsSinceEpoch - _syncTime;
        debug('$_syncString executed in ${_syncTime}ms.');
      }
      Timeline.finishSync();
      _syncString = null;
      _syncTime = DateTime.now().millisecondsSinceEpoch;
    }
  }
}