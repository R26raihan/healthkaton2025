/// Constants yang digunakan di seluruh aplikasi
class AppConstants {
  // App Info
  static const String appName = 'Healthkon BPJS';
  static const String appVersion = '1.0.0';
  
  // Splash Screen
  static const int splashDuration = 3; // seconds
  
  static const String baseUrl = 'http://103.126.116.126:8000';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String meEndpoint = '/me'; // Get current user info
  
  // News API
  static const String newsApiKey = 'a4d0b238cdef4b038db8601d4b3a6522';
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  static const String newsApiEndpoint = '/everything';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String recordIdKey = 'medical_record_id';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  // Private constructor untuk mencegah instantiation
  AppConstants._();
}

