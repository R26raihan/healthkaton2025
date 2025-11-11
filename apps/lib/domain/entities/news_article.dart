/// News Article entity - Business object untuk artikel berita
class NewsArticle {
  final String id;
  final String title;
  final String description; // Ringkasan/Summary
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String? url;
  
  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.url,
  });
}

