import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/news_article.dart';
import 'package:apps/domain/usecases/news/get_health_news_usecase.dart';

/// Provider untuk state management news
class NewsProvider extends ChangeNotifier {
  final GetHealthNewsUsecase getHealthNewsUsecase;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<NewsArticle> _articles = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NewsArticle> get articles => _articles;
  
  NewsProvider(this.getHealthNewsUsecase);
  
  /// Load health news articles
  Future<void> loadHealthNews({String? keyword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await getHealthNewsUsecase(
      keyword: keyword,
      pageSize: 10,
    );
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _articles = [];
        _isLoading = false;
        notifyListeners();
      },
      (articles) {
        _articles = articles;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  /// Refresh news
  Future<void> refresh() async {
    await loadHealthNews();
  }
}

