import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/article.dart';
import '../services/feedup_api_service.dart';
import '../../utils/logger.dart';

class BookmarkProvider extends ChangeNotifier {
  final Box<Article> _bookmarkBox = Hive.box<Article>('bookmarks');
  List<Article> _bookmarks = [];
  Set<String> _bookmarkIds = {};

  bool _isLoading = false;
  String? _error;

  BookmarkProvider() {
    _loadBookmarksFromHive();
  }

  // --- Getters ---
  List<Article> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isBookmarked(String articleId) => _bookmarkIds.contains(articleId);

  void _loadBookmarksFromHive() {
    _bookmarks = _bookmarkBox.values.toList();
    _bookmarkIds = _bookmarkBox.keys.cast<String>().toSet();
    appLogger.i("📚 Loaded ${_bookmarks.length} bookmarks from Hive cache.");
    notifyListeners();
  }

  Future<void> syncBookmarksFromServer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final serverBookmarks = await FeedUpApiService.fetchBookmarks();
      await _bookmarkBox.clear();
      
      final Map<dynamic, Article> serverBookmarksMap = {
        for (var article in serverBookmarks) article.id: article
      };
      await _bookmarkBox.putAll(serverBookmarksMap);

      _loadBookmarksFromHive();
      appLogger.i("✅ Synced ${_bookmarks.length} bookmarks from server.");
    } catch (e) {
      _error = "Failed to sync bookmarks.";
      appLogger.e("🔥 Failed to sync bookmarks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ RESTORED AND FIXED: The toggle method
  Future<void> toggleBookmark(Article article) async {
    final bool wasBookmarked = isBookmarked(article.id);

    // 1. Optimistic UI Update
    if (wasBookmarked) {
      await _bookmarkBox.delete(article.id);
    } else {
      await _bookmarkBox.put(article.id, article);
    }
    _loadBookmarksFromHive(); // This calls notifyListeners()

    // 2. Sync with Server
    try {
      // ✅ Use the corrected API service method
      await FeedUpApiService.toggleBookmark(article.id);
    } catch (e) {
      appLogger.e("🔥 Failed to sync bookmark toggle for article ${article.id}: $e");
      // 3. Rollback on Failure
      if (wasBookmarked) {
        await _bookmarkBox.put(article.id, article);
      } else {
        await _bookmarkBox.delete(article.id);
      }
      _loadBookmarksFromHive();
    }
  }

  Future<void> clearAllBookmarks() async {
    await _bookmarkBox.clear();
    _bookmarks = [];
    _bookmarkIds = {};
    appLogger.i("🧹 Cleared all local bookmarks.");
    notifyListeners();
  }
}