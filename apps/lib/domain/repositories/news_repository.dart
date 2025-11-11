import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/news_article.dart';
import 'package:dartz/dartz.dart';

/// Interface untuk News Repository
abstract class NewsRepository {
  /// Get news articles dengan keyword (kesehatan/BPJS)
  /// Menggunakan summary/description bukan full content
  Future<Either<Failure, List<NewsArticle>>> getHealthNews({
    String? keyword,
    int? pageSize,
  });
}

