import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service untuk menyimpan data secara secure menggunakan Flutter Secure Storage
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// Keys untuk storage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _recordIdKey = 'medical_record_id';
  
  /// Save access token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  /// Get access token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// Save refresh token (optional)
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Get refresh token (optional)
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  /// Delete refresh token
  static Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }
  
  /// Save medical record ID
  static Future<void> saveRecordId(String recordId) async {
    await _storage.write(key: _recordIdKey, value: recordId);
  }
  
  /// Get medical record ID
  static Future<String?> getRecordId() async {
    return await _storage.read(key: _recordIdKey);
  }
  
  /// Delete medical record ID
  static Future<void> deleteRecordId() async {
    await _storage.delete(key: _recordIdKey);
  }
  
  /// Clear all secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

