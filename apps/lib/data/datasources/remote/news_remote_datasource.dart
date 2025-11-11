import 'package:dio/dio.dart';
import 'package:apps/core/constants/app_constants.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/core/network/dio_client.dart';
import 'package:apps/data/models/news_article_model.dart';

/// Remote data source untuk News API
abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> getHealthNews({
    String? keyword,
    int? pageSize,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  
  NewsRemoteDataSourceImpl({Dio? dio}) 
      : dio = dio ?? DioClient.newsApiClient;
  
  @override
  Future<List<NewsArticleModel>> getHealthNews({
    String? keyword,
    int? pageSize,
  }) async {
    try {
      final response = await dio.get(
        AppConstants.newsApiEndpoint,
        queryParameters: {
          'q': keyword ?? 'kesehatan OR kesehatan Indonesia OR BPJS kesehatan OR layanan kesehatan OR informasi kesehatan',
          'language': 'id', // Bahasa Indonesia
          'sortBy': 'publishedAt',
          'pageSize': pageSize ?? 10,
          'page': 1,
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> articles = response.data['articles'] ?? [];
        return articles
            .map((json) => NewsArticleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerFailure('Gagal memuat berita: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkFailure('Koneksi timeout, coba lagi');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure('Tidak ada koneksi internet');
      } else {
        throw ServerFailure('Error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Terjadi kesalahan: ${e.toString()}');
    }
  }
}

