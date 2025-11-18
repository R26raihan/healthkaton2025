import 'package:dio/dio.dart';
import 'package:apps/core/network/rm_dio_client.dart';
import 'package:apps/data/models/allergy_model.dart';
import 'package:apps/core/errors/failures.dart';

/// Remote data source untuk Allergies
/// Menggunakan Dio untuk HTTP requests ke RM Service Mobile API (port 8003)
abstract class AllergyRemoteDataSource {
  Future<List<AllergyModel>> getMyAllergies();
}

class AllergyRemoteDataSourceImpl implements AllergyRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;
  
  AllergyRemoteDataSourceImpl({Dio? dio}) : _dio = dio;
  
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
    _initializedDio = await RmDioClient.client;
    return _initializedDio!;
  }
  
  @override
  Future<List<AllergyModel>> getMyAllergies() async {
    try {
      final client = await dio;
      
      final response = await client.get('/allergies/my-allergies');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => AllergyModel.fromJson(json))
            .toList();
      } else {
        throw ServerFailure('Failed to get allergies: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          'Failed to get allergies: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw ServerFailure('Failed to get allergies: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}

