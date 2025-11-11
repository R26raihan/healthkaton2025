import 'package:dio/dio.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/core/network/health_calculator_dio_client.dart';
import 'package:apps/data/models/health_calculation_model.dart';
import 'package:apps/data/models/health_metric_model.dart';

/// Remote data source untuk Health Calculator API
abstract class HealthCalculatorRemoteDataSource {
  Future<List<HealthCalculationModel>> getCalculationHistory({
    String? calculationType,
    int? limit,
    int? offset,
  });
  
  Future<Map<String, dynamic>> saveCalculation({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  });
  
  Future<List<HealthMetricModel>> getMetrics({
    String? metricType,
    int? limit,
    int? offset,
  });
}

class HealthCalculatorRemoteDataSourceImpl implements HealthCalculatorRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;
  
  HealthCalculatorRemoteDataSourceImpl({Dio? dio}) : _dio = dio;
  
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
    _initializedDio = await HealthCalculatorDioClient.client;
    return _initializedDio!;
  }
  
  @override
  Future<List<HealthCalculationModel>> getCalculationHistory({
    String? calculationType,
    int? limit,
    int? offset,
  }) async {
    try {
      final dioClient = await dio;
      final response = await dioClient.get(
        '/calculator/history',
        queryParameters: {
          if (calculationType != null) 'calculation_type': calculationType,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data
            .map((json) => HealthCalculationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure('Gagal memuat calculation history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout, coba lagi');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak ada koneksi internet');
      } else if (e.response?.statusCode == 401) {
        throw const AuthFailure('Sesi telah berakhir, silakan login kembali');
      } else {
        throw ServerFailure('Error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> saveCalculation({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  }) async {
    try {
      final dioClient = await dio;
      
      // Determine endpoint based on calculation type
      String endpoint;
      switch (calculationType) {
        case 'BMI':
          endpoint = '/calculator/bmi';
          break;
        case 'BMR':
          endpoint = '/calculator/bmr';
          break;
        case 'TDEE':
          endpoint = '/calculator/tdee';
          break;
        case 'BodyFat':
          endpoint = '/calculator/body-fat';
          break;
        case 'WaistToHip':
          endpoint = '/calculator/waist-to-hip';
          break;
        case 'WaistToHeight':
          endpoint = '/calculator/waist-to-height';
          break;
        case 'IdealBodyWeight':
          endpoint = '/calculator/ideal-body-weight';
          break;
        case 'BodySurfaceArea':
          endpoint = '/calculator/body-surface-area';
          break;
        case 'MaxHeartRate':
          endpoint = '/calculator/max-heart-rate';
          break;
        case 'TargetHeartRate':
          endpoint = '/calculator/target-heart-rate';
          break;
        case 'MAP':
          endpoint = '/calculator/map';
          break;
        case 'MetabolicAge':
          endpoint = '/calculator/metabolic-age';
          break;
        case 'DailyCalories':
          endpoint = '/calculator/daily-calories';
          break;
        case 'Macronutrients':
          endpoint = '/calculator/macronutrients';
          break;
        case 'OneRepMax':
          endpoint = '/calculator/one-rep-max';
          break;
        case 'CaloriesBurned':
          endpoint = '/calculator/calories-burned';
          break;
        case 'VO2Max':
          endpoint = '/calculator/vo2-max';
          break;
        case 'RecoveryTime':
          endpoint = '/calculator/recovery-time';
          break;
        case 'WaterNeeds':
          endpoint = '/calculator/water-needs';
          break;
        case 'BodyWater':
          endpoint = '/calculator/body-water';
          break;
        default:
          throw ServerFailure('Unknown calculation type: $calculationType');
      }
      
      final response = await dioClient.post(
        endpoint,
        data: inputData,
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerFailure('Gagal menyimpan calculation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout, coba lagi');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak ada koneksi internet');
      } else if (e.response?.statusCode == 401) {
        throw const AuthFailure('Sesi telah berakhir, silakan login kembali');
      } else {
        throw ServerFailure('Error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
  
  @override
  Future<List<HealthMetricModel>> getMetrics({
    String? metricType,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await dio;
      
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (metricType != null && metricType.isNotEmpty) {
        queryParams['metric_type'] = metricType;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (offset != null) {
        queryParams['offset'] = offset;
      }
      
      // GET /metrics/
      final response = await client.get(
        '/metrics/',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => HealthMetricModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure('Gagal mengambil data metrics');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthFailure('Sesi telah berakhir, silakan login kembali');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Timeout, silakan coba lagi');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak ada koneksi internet');
      } else {
        throw ServerFailure('Error: ${e.message}');
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

