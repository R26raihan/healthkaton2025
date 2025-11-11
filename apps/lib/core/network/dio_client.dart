import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:apps/core/constants/app_constants.dart';

/// Dio Client setup untuk HTTP requests
class DioClient {
  static Dio get newsApiClient {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.newsApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'X-Api-Key': AppConstants.newsApiKey,
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptors untuk logging (optional - hanya di debug mode)
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          debugPrint(object.toString());
        },
      ));
    }
    
    return dio;
  }
}

