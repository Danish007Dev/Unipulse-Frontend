import 'package:dio/dio.dart';
import '../../services/dio_client.dart';
import '../models/ai_response_bookmark.dart';

class AiBookmarkApiService {
  static final Dio _dio = DioClient().client;
  static const String _bookmarksEndpoint = '/feedup/ai-bookmarks/';

  static Future<List<AiResponseBookmark>> fetchAiBookmarks() async {
    final response = await _dio.get(_bookmarksEndpoint);
    
    // The response is a Map, not a List. We need the 'results' key.
    final List<dynamic> results = response.data['results'];
    
    return results
        .map((json) => AiResponseBookmark.fromMap(json))
        .toList();
  }
}