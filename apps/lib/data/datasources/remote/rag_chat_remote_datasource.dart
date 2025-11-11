import 'package:dio/dio.dart';
import 'package:apps/core/network/rag_dio_client.dart';
import 'package:apps/data/models/rag_chat_model.dart';
import 'package:apps/core/errors/failures.dart';

/// Remote data source untuk RAG Chat
/// Menggunakan Dio untuk HTTP requests ke RAG Service API (port 8004)
abstract class RagChatRemoteDataSource {
  Future<RagChatResponseModel> chat(String query);
}

class RagChatRemoteDataSourceImpl implements RagChatRemoteDataSource {
  final Dio? _dio;
  Dio? _initializedDio;
  
  RagChatRemoteDataSourceImpl({Dio? dio}) : _dio = dio;
  
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
    _initializedDio = await RagDioClient.client;
    return _initializedDio!;
  }
  
  @override
  Future<RagChatResponseModel> chat(String query) async {
    try {
      final client = await dio;
      
      final response = await client.post(
        '/rag/chat',
        data: {
          'query': query,
        },
      );
      
      if (response.statusCode == 200) {
        return RagChatResponseModel.fromJson(response.data);
      } else {
        throw ServerFailure('Failed to get chat response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          'Failed to get chat response: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        throw ServerFailure('Failed to get chat response: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}

