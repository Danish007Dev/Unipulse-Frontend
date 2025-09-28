import 'package:dio/dio.dart';
import '../../services/dio_client.dart'; // Your existing Dio client
import '../models/article.dart';

class BookmarkApiService {
  final Dio _dio = DioClient().client; // Use your configured Dio instance
  final String _bookmarksEndpoint = '/feedup/bookmarks/';

  Future<List<Article>> fetchBookmarks() async {
    final response = await _dio.get(_bookmarksEndpoint);
    return (response.data as List)
        .map((articleJson) => Article.fromJson(articleJson))
        .toList();
  }

  Future<void> addBookmark(String articleId) async {
    await _dio.post(_bookmarksEndpoint, data: {'article_id': articleId});
  }

  Future<void> removeBookmark(String articleId) async {
    // Use DELETE method for removing resources
    await _dio.delete(_bookmarksEndpoint, data: {'article_id': articleId});
  }
}