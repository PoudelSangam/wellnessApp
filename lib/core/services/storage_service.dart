import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Secure Storage (for sensitive data like tokens)
  Future<void> saveSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      Logger.info('Saved secure: $key');
    } catch (e) {
      Logger.error('Error saving secure data: $e');
      rethrow;
    }
  }
  
  Future<String?> getSecure(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      Logger.info('Retrieved secure: $key');
      return value;
    } catch (e) {
      Logger.error('Error reading secure data: $e');
      return null;
    }
  }
  
  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
      Logger.info('Deleted secure: $key');
    } catch (e) {
      Logger.error('Error deleting secure data: $e');
    }
  }
  
  Future<void> clearSecure() async {
    try {
      await _secureStorage.deleteAll();
      Logger.info('Cleared all secure storage');
    } catch (e) {
      Logger.error('Error clearing secure storage: $e');
    }
  }
  
  // Token Management
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await saveSecure(AppConstants.accessTokenKey, accessToken);
    await saveSecure(AppConstants.refreshTokenKey, refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return await getSecure(AppConstants.accessTokenKey);
  }
  
  Future<String?> getRefreshToken() async {
    return await getSecure(AppConstants.refreshTokenKey);
  }
  
  Future<void> clearTokens() async {
    await deleteSecure(AppConstants.accessTokenKey);
    await deleteSecure(AppConstants.refreshTokenKey);
  }
  
  // Shared Preferences (for non-sensitive data)
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
  
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
  
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
  
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
  
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await clearSecure();
  }
}
