import 'package:flutter/foundation.dart';

class Logger {
  static const bool _enableLogs = kDebugMode;
  
  static void info(String message) {
    if (_enableLogs) {
      debugPrint('ℹ️ INFO: $message');
    }
  }
  
  static void debug(String message) {
    if (_enableLogs) {
      debugPrint('🐛 DEBUG: $message');
    }
  }
  
  static void warning(String message) {
    if (_enableLogs) {
      debugPrint('⚠️ WARNING: $message');
    }
  }
  
  static void error(String message) {
    if (_enableLogs) {
      debugPrint('❌ ERROR: $message');
    }
  }
  
  static void success(String message) {
    if (_enableLogs) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}
