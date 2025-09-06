import 'package:dio/dio.dart';
import '../../../services/dio_client.dart';
import '../models/article.dart';

class FeedUpApiService {
  static final Dio _dio = DioClient().client;

  static Future<List<Article>> fetchBookmarks() async {
    final response = await _dio.get('/feedup/bookmarks/');
    final results = response.data as List;
    return results.map((json) => Article.fromJson(json)).toList();
  }

  static Future<void> toggleBookmark(String articleId) async {
    await _dio.post('/feedup/bookmarks/', data: {'article_id': articleId});
  }
}