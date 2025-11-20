import 'package:dio/dio.dart';
import 'package:apps/core/network/rm_dio_client.dart';
import 'package:apps/data/models/prescription_model.dart';
import 'package:apps/core/errors/failures.dart';

abstract class PrescriptionRemoteDataSource {
  Future<List<PrescriptionModel>> getMyMedications();
}

class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;

  PrescriptionRemoteDataSourceImpl({Dio? dio}) : _dio = dio;

  Future<Dio> get dio async {
    final providedDio = _dio;
    if (providedDio != null) {
      return providedDio;
    }
    final cachedDio = _initializedDio;
    if (cachedDio != null) {
      return cachedDio;
    }
    _initializedDio = await RmDioClient.client;
    return _initializedDio!;
  }

  @override
  Future<List<PrescriptionModel>> getMyMedications() async {
    try {
      final client = await dio;
      final response = await client.get('/prescriptions/my-medications');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PrescriptionModel.fromJson(json)).toList();
      } else {
        throw ServerFailure('Failed to get medications: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          'Failed to get medications: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw ServerFailure('Failed to get medications: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}

