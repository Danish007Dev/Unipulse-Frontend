import 'package:dio/dio.dart';
import '../../services/dio_client.dart';
import '../models/article.dart';

class ArticleService {
  final Dio _dio = DioClient().client;

  Future<List<Article>> fetchArticles({
    required int page,
  }) async {
    final response = await _dio.get(
      '/feedup/articles/',
      queryParameters: {
        'page': page,
        'page_size': 10, // Ensure page_size is consistent
      },
    );

    // ❌ INCORRECT: This causes the crash because response.data is a Map.
    // final results = response.data as List;

    // ✅ CORRECT: Access the 'results' key from the paginated response Map.
    final results = response.data['results'] as List;

    return results.map((json) => Article.fromJson(json)).toList();
  }
}
