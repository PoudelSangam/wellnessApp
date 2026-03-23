import 'package:flutter/foundation.dart';

class Logger {
  static const bool _enableLogs = kDebugMode;
  static const int _maxChunkLength = 900;

  static void _write(String level, String message) {
    if (!_enableLogs) {
      return;
    }

    final text = '$level $message';
    debugPrint(text);

    // Print to CMD/terminal too so API logs are visible outside the Flutter console UI.
    if (text.length <= _maxChunkLength) {
      // ignore: avoid_print
      print(text);
      return;
    }

    for (var i = 0; i < text.length; i += _maxChunkLength) {
      final end = (i + _maxChunkLength < text.length)
          ? i + _maxChunkLength
          : text.length;
      final chunk = text.substring(i, end);
      // ignore: avoid_print
      print(chunk);
    }
  }
  
  static void info(String message) {
    _write('ℹ️ INFO:', message);
  }
  
  static void debug(String message) {
    _write('🐛 DEBUG:', message);
  }
  
  static void warning(String message) {
    _write('⚠️ WARNING:', message);
  }
  
  static void error(String message) {
    _write('❌ ERROR:', message);
  }
  
  static void success(String message) {
    _write('✅ SUCCESS:', message);
  }
}
