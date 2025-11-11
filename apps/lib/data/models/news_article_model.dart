import 'package:apps/domain/entities/news_article.dart';

/// News Article Model untuk JSON serialization
class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    required super.source,
    required super.publishedAt,
    super.url,
  });
  
  /// Convert dari JSON News API
  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      id: json['publishedAt']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['content']?.toString() ?? '',
      imageUrl: json['urlToImage']?.toString(),
      source: json['source'] is Map 
          ? json['source']['name']?.toString() ?? 'Unknown'
          : json['source']?.toString() ?? 'Unknown',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      url: json['url']?.toString(),
    );
  }
  
  /// Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'urlToImage': imageUrl,
      'source': {'name': source},
      'publishedAt': publishedAt.toIso8601String(),
      'url': url,
    };
  }
  
  /// Convert dari Entity
  factory NewsArticleModel.fromEntity(NewsArticle article) {
    return NewsArticleModel(
      id: article.id,
      title: article.title,
      description: article.description,
      imageUrl: article.imageUrl,
      source: article.source,
      publishedAt: article.publishedAt,
      url: article.url,
    );
  }
}

