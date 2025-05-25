import 'package:dio/dio.dart';
import '../../services/dio_client.dart';
import 'stu_post_model.dart';
import '../../utils/logger.dart';
import '../../services/api_config.dart';

class StudentPostService {
  static final Dio _dio = DioClient().client;

  static Future<PaginatedPosts> fetchPostsForStudent({String? url}) async {
    try {
      final response = await _dio.get(url ?? ApiConfig.studentPosts);
      final results = response.data['results'] as List<dynamic>;
      final next = response.data['next'] as String?;
      final posts = results.map((json) => Post.fromJson(json)).toList();

    appLogger.i('📦stu posts response: ${response.data}');
      return PaginatedPosts(posts: posts, next: next);
    } catch (e) {
      appLogger.e('Error fetching student posts: $e');
      rethrow;
    }
  }


  static Future<String?> toggleSavePost(int postId) async {
    try {
      final response = await _dio.post(ApiConfig.toggleSavePost, data: {
        'post_id': postId,
      });

      if (response.statusCode == 200 && response.data != null) {
        return response.data['message']; // "Post saved" or "Post unsaved"
      } else {
        return null;
      }
    } catch (e, stack) {
      appLogger.e('Error toggling save post: $e\n$stack');
      return null;
    }
  }

  static Future<PaginatedPosts> fetchSavedPosts({String? url, bool isSavedOnly = false}) async {
  try {
    final response = await _dio.get(
      url ?? ApiConfig.studentPosts,
      queryParameters: isSavedOnly ? {'saved': 'true'} : null,
    );
    final results = response.data['results'] as List<dynamic>;
    final next = response.data['next'] as String?;
    final posts = results.map((json) => Post.fromJson(json)).toList();

    appLogger.i('📦 saved posts response: ${response.data}');
    return PaginatedPosts(posts: posts, next: next);
  } catch (e) {
    appLogger.e('Error fetching saved posts: $e');
    rethrow;
  }
}

}

