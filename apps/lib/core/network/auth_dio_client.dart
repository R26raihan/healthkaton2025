import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:apps/core/utils/api_helper.dart';

/// Dio Client untuk Authentication API
/// Auto-detect IP WiFi untuk device fisik
class AuthDioClient {
  static Dio? _client;
  static String? _baseUrl;
  
  /// Get Dio client dengan auto-detect base URL
  static Future<Dio> get client async {
    // Jika client sudah dibuat dan baseUrl belum berubah, return cached
    if (_client != null && _baseUrl != null) {
      return _client!;
    }
    
    // Auto-detect base URL (termasuk IP WiFi untuk device fisik)
    _baseUrl = await ApiHelper.getBaseUrl();
    
    if (kDebugMode) {
      debugPrint('🔗 [AUTH API] Detected base URL: $_baseUrl');
      debugPrint('🔗 [AUTH API] Testing connection...');
      
      // Test connection
      final isConnected = await ApiHelper.testConnection(_baseUrl!);
      if (isConnected) {
        debugPrint('✅ [AUTH API] Connection test: SUCCESS');
      } else {
        debugPrint('❌ [AUTH API] Connection test: FAILED');
        debugPrint('⚠️ [AUTH API] Make sure backend is running at $_baseUrl');
      }
    }
    
    _client = Dio(
      BaseOptions(
        baseUrl: _baseUrl!,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors untuk logging (optional - hanya di debug mode)
    if (kDebugMode) {
      _client!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          debugPrint('[AUTH API] $object');
        },
      ));
    }
    
    return _client!;
  }
  
  /// Get Dio client (synchronous - menggunakan cached atau fallback)
  /// Note: Untuk async initialization, gunakan `client` (Future)
  static Dio get clientSync {
    if (_client != null) {
      return _client!;
    }
    
    // Fallback ke sync method
    final baseUrl = ApiHelper.getBaseUrlSync();
    
    if (kDebugMode) {
      debugPrint('[AUTH API] Using base URL (sync): $baseUrl');
    }
    
    _client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json',
        },
      ),
    );
    
    if (kDebugMode) {
      _client!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          debugPrint('[AUTH API] $object');
        },
      ));
    }
    
    return _client!;
  }
  
  /// Refresh client (clear cache dan re-detect IP)
  static Future<void> refresh() async {
    ApiHelper.clearCache();
    _client = null;
    _baseUrl = null;
    await client; // Re-initialize
  }
}

