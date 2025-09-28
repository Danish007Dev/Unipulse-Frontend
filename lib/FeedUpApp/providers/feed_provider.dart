import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/article_service.dart';

class FeedProvider extends ChangeNotifier {
  final ArticleService _service = ArticleService();
  
  final List<Article> _articles = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  // --- Getters ---
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  FeedProvider() {
    // Fetch initial articles when the provider is first created.
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    // ✅ Call the service without the unused 'department' parameter.
    final newArticles = await _service.fetchArticles(
      page: _page,
    );

    _articles.addAll(newArticles);
    _hasMore = newArticles.length >= 10;
    if (_hasMore) _page++;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _articles.clear();
    _page = 1;
    _hasMore = true;
    await fetchArticles();
  }
}