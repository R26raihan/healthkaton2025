import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/news_article.dart';
import 'package:apps/domain/repositories/news_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk mendapatkan berita kesehatan
class GetHealthNewsUsecase {
  final NewsRepository repository;
  
  GetHealthNewsUsecase(this.repository);
  
  Future<Either<Failure, List<NewsArticle>>> call({
    String? keyword,
    int? pageSize,
  }) {
    return repository.getHealthNews(
      keyword: keyword ?? 'kesehatan BPJS',
      pageSize: pageSize ?? 10,
    );
  }
}

