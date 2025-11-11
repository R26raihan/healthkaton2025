import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/news_remote_datasource.dart';
import 'package:apps/domain/entities/news_article.dart';
import 'package:apps/domain/repositories/news_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari NewsRepository
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  
  NewsRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<NewsArticle>>> getHealthNews({
    String? keyword,
    int? pageSize,
  }) async {
    try {
      final articles = await remoteDataSource.getHealthNews(
        keyword: keyword,
        pageSize: pageSize,
      );
      return Right(articles);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

