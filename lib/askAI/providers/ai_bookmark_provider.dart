import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ai_response_bookmark.dart';
import '../services/ai_bookmark_api_service.dart';
import '../../utils/logger.dart';

class AiBookmarkProvider with ChangeNotifier {
  late Box<AiResponseBookmark> _aiBookmarkBox;
  List<AiResponseBookmark> _bookmarks = [];
  bool _isLoading = false;

  AiBookmarkProvider() {
    _init();
  }

  List<AiResponseBookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  Future<void> _init() async {
    _aiBookmarkBox = await Hive.openBox<AiResponseBookmark>('ai_bookmarks');
    _loadBookmarksFromHive();
  }

  void _loadBookmarksFromHive() {
    _bookmarks = _aiBookmarkBox.values.toList();
    notifyListeners();
  }

  Future<void> syncBookmarksFromServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      final serverBookmarks = await AiBookmarkApiService.fetchAiBookmarks();
      await _aiBookmarkBox.clear();
      final Map<dynamic, AiResponseBookmark> serverBookmarksMap = {
        for (var bookmark in serverBookmarks) bookmark.id: bookmark
      };
      await _aiBookmarkBox.putAll(serverBookmarksMap);
      _loadBookmarksFromHive();
      appLogger.i("✅ Synced ${_bookmarks.length} AI bookmarks from server.");
    } catch (e) {
      appLogger.e("🔥 Failed to sync AI bookmarks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllBookmarks() async {
    await _aiBookmarkBox.clear();
    _loadBookmarksFromHive();
    appLogger.i("🧹 Cleared all local AI bookmarks.");
  }
}