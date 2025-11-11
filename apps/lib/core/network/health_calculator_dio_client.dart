import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:apps/core/utils/api_helper.dart';
import 'package:apps/core/storage/secure_storage_service.dart';

/// Dio Client untuk Health Calculator API
/// Auto-detect IP WiFi untuk device fisik
class HealthCalculatorDioClient {
  static Dio? _client;
  static String? _baseUrl;
  
  /// Get Dio client dengan auto-detect base URL
  static Future<Dio> get client async {
    // Jika client sudah dibuat dan baseUrl belum berubah, return cached
    if (_client != null && _baseUrl != null) {
      return _client!;
    }
    
    // Auto-detect base URL (termasuk IP WiFi untuk device fisik)
    final detectedBaseUrl = await ApiHelper.getBaseUrl();
    // Health Calculator Service runs on port 8005
    _baseUrl = detectedBaseUrl.replaceAll(RegExp(r':\d+$'), ':8005');
    
    if (kDebugMode) {
      debugPrint('🔗 [HEALTH CALC API] Detected base URL: $_baseUrl');
      debugPrint('🔗 [HEALTH CALC API] Testing connection...');
      
      // Test connection
      final isConnected = await ApiHelper.testConnection(_baseUrl!);
      if (isConnected) {
        debugPrint('✅ [HEALTH CALC API] Connection test: SUCCESS');
      } else {
        debugPrint('❌ [HEALTH CALC API] Connection test: FAILED');
        debugPrint('⚠️ [HEALTH CALC API] Make sure backend is running at $_baseUrl');
      }
    }
    
    _client = Dio(
      BaseOptions(
        baseUrl: _baseUrl!,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ),
    );
    
    // Add interceptor untuk selalu mengambil token terbaru dari secure storage
    _client!.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token terbaru dari secure storage setiap request
          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              debugPrint('[HEALTH CALC API] ✅ Token added to request headers');
            }
          } else {
            if (kDebugMode) {
              debugPrint('[HEALTH CALC API] ⚠️ No token found in secure storage');
            }
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 error - token mungkin expired
          if (error.response?.statusCode == 401) {
            if (kDebugMode) {
              debugPrint('[HEALTH CALC API] ⚠️ 401 Unauthorized - Token mungkin expired atau tidak valid');
            }
          }
          handler.next(error);
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
          debugPrint('[HEALTH CALC API] $object');
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

