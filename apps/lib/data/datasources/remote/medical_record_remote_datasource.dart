import 'package:dio/dio.dart';
import 'package:apps/core/network/rm_dio_client.dart';
import 'package:apps/data/models/medical_record_model.dart';
import 'package:apps/data/models/medical_record_full_model.dart';
import 'package:apps/core/errors/failures.dart';

/// Remote data source untuk Medical Records
/// Menggunakan Dio untuk HTTP requests ke RM Service API (port 8003)
abstract class MedicalRecordRemoteDataSource {
  Future<List<MedicalRecordModel>> getMyRecords({
    int skip = 0,
    int limit = 100,
  });
  
  Future<MedicalRecordFullModel> getMedicalRecordById(String recordId);
}

class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;
  
  MedicalRecordRemoteDataSourceImpl({Dio? dio}) : _dio = dio;
  
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
  Future<List<MedicalRecordModel>> getMyRecords({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final client = await dio;
      
      final response = await client.get(
        '/medical-records/my-records',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => MedicalRecordModel.fromJson(json))
            .toList();
      } else {
        throw ServerFailure('Failed to get medical records: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          'Failed to get medical records: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw ServerFailure('Failed to get medical records: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
  
  @override
  Future<MedicalRecordFullModel> getMedicalRecordById(String recordId) async {
    try {
      final client = await dio;
      
      final response = await client.get(
        '/medical-records/$recordId',
      );
      
      if (response.statusCode == 200) {
        return MedicalRecordFullModel.fromJson(response.data);
      } else {
        throw ServerFailure('Failed to get medical record: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          'Failed to get medical record: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw ServerFailure('Failed to get medical record: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}

