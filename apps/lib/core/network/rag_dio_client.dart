import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:apps/core/utils/api_helper.dart';
import 'package:apps/data/datasources/local/auth_local_datasource.dart';
import 'package:apps/core/di/injection_container.dart' as di;

/// Dio Client untuk RAG Service API
/// Auto-detect IP WiFi untuk device fisik
/// Port: 8004 (rag_service_mobile)
class RagDioClient {
  static Dio? _client;
  static String? _baseUrl;
  static const int _ragPort = 8004;
  
  /// Get Dio client dengan auto-detect base URL untuk RAG service
  static Future<Dio> get client async {
    // Jika client sudah dibuat dan baseUrl belum berubah, return cached
    if (_client != null && _baseUrl != null) {
      return _client!;
    }
    
    // Get base URL dari ApiHelper dan replace port dengan RAG port
    final authBaseUrl = await ApiHelper.getBaseUrl();
    // Extract IP dari base URL (http://192.168.1.11:8000 -> http://192.168.1.11:8004)
    final uri = Uri.parse(authBaseUrl);
    _baseUrl = '${uri.scheme}://${uri.host}:$_ragPort';
    
    if (kDebugMode) {
      debugPrint('🔗 [RAG API] Detected base URL: $_baseUrl');
    }
    
    // Get token from local storage
    final localDataSource = AuthLocalDataSourceImpl(di.getIt());
    final token = await localDataSource.getToken();
    
    _client = Dio(
      BaseOptions(
        baseUrl: _baseUrl!,
        connectTimeout: const Duration(seconds: 60), // RAG bisa lebih lama
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
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
          debugPrint('[RAG API] $object');
        },
      ));
    }
    
    // Add interceptor untuk update token jika berubah
    _client!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Update token setiap request
        final currentToken = await localDataSource.getToken();
        if (currentToken != null) {
          options.headers['Authorization'] = 'Bearer $currentToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired, mungkin perlu refresh atau logout
          if (kDebugMode) {
            debugPrint('⚠️ [RAG API] Unauthorized - Token mungkin expired');
          }
        }
        return handler.next(error);
      },
    ));
    
    return _client!;
  }
  
  /// Refresh client (clear cache dan re-detect IP)
  static Future<void> refresh() async {
    _client = null;
    _baseUrl = null;
    await client; // Re-initialize
  }
}

