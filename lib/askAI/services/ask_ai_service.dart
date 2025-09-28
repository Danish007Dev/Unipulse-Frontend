import 'package:dio/dio.dart';
import '../../services/dio_client.dart';

class AskAiService {
  final Dio _dio = DioClient().client;

  /// Fetches the initial list of questions for an article.
  Future<List<String>> fetchInitialQuestions(int articleId) async {
    final response = await _dio.post(
      '/feedup/ask-ai/',
      data: {'article_id': articleId},
    );
    return List<String>.from(response.data['questions']);
  }

  /// Sends a query and gets an AI-generated answer.
  Future<String> getAiResponse(int articleId, String query) async {
    final response = await _dio.post(
      '/feedup/ask-ai/',
      data: {'article_id': articleId, 'query': query},
    );
    return response.data['answer'];
  }

  /// Toggles the bookmark status of an AI response.
  /// Returns true if the item is now bookmarked, false if it's not.
  Future<bool> toggleBookmark({
    required int articleId,
    required String question,
    required String answer,
  }) async {
    final response = await _dio.post(
      '/feedup/ai-bookmarks/toggle/',
      data: {
        'article_id': articleId,
        'question': question,
        'answer': answer,
      },
    );
    // 201 means created (bookmarked), 204 means deleted (removed).
    return response.statusCode == 201;
  }
}