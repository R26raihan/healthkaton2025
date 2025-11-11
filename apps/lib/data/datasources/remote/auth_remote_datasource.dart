import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:apps/core/constants/app_constants.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/core/network/auth_dio_client.dart';
import 'package:apps/core/utils/api_helper.dart';
import 'package:apps/data/models/user_model.dart';

/// Remote data source untuk authentication
/// Menggunakan Dio untuk HTTP requests ke backend API
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getCurrentUser(String token);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;
  
  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio;
  
  /// Get Dio client (lazy initialization dengan auto-detect IP)
  Future<Dio> get dio async {
    // Jika Dio sudah disediakan, gunakan itu
    final providedDio = _dio;
    if (providedDio != null) {
      return providedDio;
    }
    
    // Jika sudah di-initialize sebelumnya, gunakan cached
    final cachedDio = _initializedDio;
    if (cachedDio != null) {
      return cachedDio;
    }
    
    // Initialize dengan auto-detect IP WiFi
    _initializedDio = await AuthDioClient.client;
    return _initializedDio!;
  }
  
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Get Dio client (dengan auto-detect IP)
      final dioClient = await dio;
      final baseUrl = dioClient.options.baseUrl;
      
      if (kDebugMode) {
        print('[AUTH API] Attempting login to: $baseUrl${AppConstants.loginEndpoint}');
        print('[AUTH API] Email: $email');
      }
      
      // Prepare form data sesuai dengan API backend
      final formData = FormData.fromMap({
        'grant_type': 'password',
        'username': email,
        'password': password,
        'scope': '',
        'client_id': 'string',
        'client_secret': '',
      });
      
      if (kDebugMode) {
        print('[AUTH API] Sending login request...');
      }
      
      // Make POST request to login endpoint
      final response = await dioClient.post(
        AppConstants.loginEndpoint,
        data: formData,
      );
      
      if (kDebugMode) {
        print('[AUTH API] Login response status: ${response.statusCode}');
        print('[AUTH API] Login response data: ${response.data}');
      }
      
      // Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        // Response format dari FastAPI OAuth2:
        // {
        //   "access_token": "string",
        //   "token_type": "bearer"
        // }
        final accessToken = data['access_token'] as String?;
        final tokenType = data['token_type'] as String? ?? 'bearer';
        
        if (accessToken == null || accessToken.isEmpty) {
          throw const AuthFailure('Token tidak ditemukan dalam response');
        }
        
        // Return token dan user info (jika ada)
        return {
          'access_token': accessToken,
          'token_type': tokenType,
          'email': email, // Email dari request
        };
      } else {
        throw const AuthFailure('Login gagal: Response tidak valid');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.connectionError) {
        // Get base URL untuk error message yang lebih informatif
        final baseUrl = await ApiHelper.getBaseUrl();
        final errorMsg = e.message ?? 'Connection error';
        
        if (kDebugMode) {
          print('[AUTH API] Connection error to: $baseUrl');
          print('[AUTH API] Error message: $errorMsg');
        }
        
        // Check jika error karena host tidak ditemukan
        if (errorMsg.contains('Failed host lookup') || 
            errorMsg.contains('SocketException') ||
            errorMsg.contains('Network is unreachable')) {
          throw NetworkFailure('Tidak dapat terhubung ke server di $baseUrl.\n\n'
              'Pastikan:\n'
              '1. Backend berjalan di port 8000\n'
              '2. Device terhubung ke WiFi yang sama dengan komputer\n'
              '3. Firewall tidak memblokir port 8000\n'
              '4. Backend listen di 0.0.0.0:8000 (bukan localhost:8000)');
        }
        
        throw NetworkFailure('Tidak dapat terhubung ke server di $baseUrl. '
            'Pastikan backend berjalan dan device terhubung ke WiFi yang sama dengan komputer.');
      } else if (e.response != null) {
        // Handle HTTP error responses
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (kDebugMode) {
          print('[AUTH API] HTTP Error: $statusCode');
          print('[AUTH API] Error data: $errorData');
        }
        
        if (statusCode == 401) {
          final detail = errorData is Map<String, dynamic> 
              ? errorData['detail'] as String? 
              : 'Email atau password salah';
          throw AuthFailure(detail ?? 'Email atau password salah');
        } else if (statusCode == 422) {
          final detail = errorData is Map<String, dynamic> 
              ? errorData['detail']?.toString() 
              : 'Data tidak valid';
          throw AuthFailure(detail ?? 'Data tidak valid');
        } else {
          throw ServerFailure('Login gagal: ${errorData?.toString() ?? 'Unknown error'}');
        }
      } else {
        // Other DioException types
        final errorMsg = e.message ?? 'Unknown network error';
        if (kDebugMode) {
          print('[AUTH API] Other error: $errorMsg');
        }
        throw NetworkFailure('Terjadi kesalahan jaringan: $errorMsg');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      if (kDebugMode) {
        print('[AUTH API] Unexpected error: $e');
        print('[AUTH API] Error type: ${e.runtimeType}');
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      // Get Dio client (dengan auto-detect IP)
      final dioClient = await dio;
      
      // Make GET request to /me endpoint dengan Bearer token
      final response = await dioClient.get(
        AppConstants.meEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      // Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw const AuthFailure('Gagal mendapatkan informasi user');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak dapat terhubung ke server. Pastikan backend berjalan di http://localhost:8000');
      } else if (e.response != null) {
        // Handle HTTP error responses
        final statusCode = e.response!.statusCode;
        
        if (statusCode == 401) {
          throw const AuthFailure('Token tidak valid atau sudah kedaluwarsa');
        } else {
          throw ServerFailure('Gagal mendapatkan informasi user: ${e.response?.data?.toString() ?? 'Unknown error'}');
        }
      } else {
        throw NetworkFailure('Terjadi kesalahan jaringan: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String ktpNumber,
    required String kkNumber,
  }) async {
    try {
      // Get Dio client (dengan auto-detect IP)
      final dioClient = await dio;
      
      // Prepare request data
      final requestData = {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'ktpNumber': ktpNumber,
        'kkNumber': kkNumber,
      };
      
      // Make POST request to register endpoint
      final response = await dioClient.post(
        AppConstants.registerEndpoint,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      // Parse response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw const AuthFailure('Registrasi gagal: Response tidak valid');
      }
    } on DioException catch (e) {
      // Handle Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout. Periksa koneksi internet Anda.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak dapat terhubung ke server. Pastikan backend berjalan di http://localhost:8000');
      } else if (e.response != null) {
        // Handle HTTP error responses
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 400) {
          final detail = errorData is Map<String, dynamic> 
              ? errorData['detail'] as String? 
              : 'Data tidak valid';
          throw AuthFailure(detail ?? 'Data tidak valid');
        } else if (statusCode == 409) {
          throw const AuthFailure('Email sudah terdaftar');
        } else {
          throw ServerFailure('Registrasi gagal: ${errorData?.toString() ?? 'Unknown error'}');
        }
      } else {
        throw NetworkFailure('Terjadi kesalahan jaringan: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

