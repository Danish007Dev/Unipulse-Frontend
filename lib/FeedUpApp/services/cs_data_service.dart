import 'package:dio/dio.dart';
import '../../services/dio_client.dart';
import '../../utils/logger.dart';
import '../models/conference.dart';
import '../models/research_update.dart';

class CSDataService {
  static final Dio _dio = DioClient().client;

  // Conferences API
  static Future<List<Conference>> fetchConferences({
    bool showPast = false,
    String? search,
    String? location,
    String? topic,
    String? ordering = 'start_date',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'show_past': showPast.toString(),
        'page_size': '20',
      };

      if (search != null && search.isNotEmpty) params['search'] = search;
      if (location != null && location.isNotEmpty) params['location'] = location;
      if (topic != null && topic.isNotEmpty) params['topics'] = topic;
      if (ordering != null) params['ordering'] = ordering;

      appLogger.d('Fetching conferences with params: $params');

      final response = await _dio.get('/feedup/conferences/', queryParameters: params);
     
      if (response.data is Map && response.data.containsKey('results')) {
        final results = response.data['results'] as List<dynamic>;
        appLogger.i('Successfully fetched ${results.length} conferences');
        return results.map((json) => Conference.fromJson(json)).toList();
      } else if (response.data is List) {
        // Handle direct list response (non-paginated)
        final results = response.data as List<dynamic>;
        appLogger.i('Successfully fetched ${results.length} conferences (direct list)');
        return results.map((json) => Conference.fromJson(json)).toList();
      } else {
        appLogger.w('Unexpected response format for conferences');
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        appLogger.e('Authentication error: User not authorized to access conferences');
      } else if (e.response?.statusCode == 401) {
        appLogger.e('Authentication expired: Please login again');
      } else {
        appLogger.e('DioException fetching conferences: ${e.message}');
        appLogger.e('Response data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      appLogger.e('Unexpected error fetching conferences: $e');
      return [];
    }
  }

  // Research Updates API
  static Future<List<ResearchUpdate>> fetchResearchUpdates({
    String? search,
    String? category,
    String? institution,
    int? recentDays,
    String? ordering = '-publication_date',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page_size': '20',
      };

      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (institution != null && institution.isNotEmpty) params['institution'] = institution;
      if (recentDays != null) params['recent_days'] = recentDays.toString();
      if (ordering != null) params['ordering'] = ordering;

      appLogger.d('Fetching research updates with params: $params');

      final response = await _dio.get('/feedup/research/', queryParameters: params);
     
      if (response.data is Map && response.data.containsKey('results')) {
        final results = response.data['results'] as List<dynamic>;
        appLogger.i('Successfully fetched ${results.length} research updates');
        return results.map((json) => ResearchUpdate.fromJson(json)).toList();
      } else if (response.data is List) {
        // Handle direct list response (non-paginated)
        final results = response.data as List<dynamic>;
        appLogger.i('Successfully fetched ${results.length} research updates (direct list)');
        return results.map((json) => ResearchUpdate.fromJson(json)).toList();
      } else {
        appLogger.w('Unexpected response format for research updates');
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        appLogger.e('Authentication error: User not authorized to access research updates');
      } else if (e.response?.statusCode == 401) {
        appLogger.e('Authentication expired: Please login again');
      } else {
        appLogger.e('DioException fetching research updates: ${e.message}');
        appLogger.e('Response data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      appLogger.e('Unexpected error fetching research updates: $e');
      return [];
    }
  }

  // Get conference filter options
  static Future<Map<String, List<String>>> getConferenceFilterOptions() async {
    try {
      appLogger.d('Fetching conference filter options');
      
      final response = await _dio.get('/feedup/conferences/filter_options/');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return {
          'locations': List<String>.from(data['locations'] ?? []),
          'topics': List<String>.from(data['topics'] ?? []),
        };
      } else {
        appLogger.w('Failed to fetch conference filter options: ${response.statusCode}');
        return _getDefaultConferenceFilterOptions();
      }
    } on DioException catch (e) {
      appLogger.e('DioException fetching conference filter options: ${e.message}');
      return _getDefaultConferenceFilterOptions();
    } catch (e) {
      appLogger.e('Error fetching conference filter options: $e');
      return _getDefaultConferenceFilterOptions();
    }
  }

  // Get research filter options
  static Future<Map<String, List<String>>> getResearchFilterOptions() async {
    try {
      appLogger.d('Fetching research filter options');
      
      final response = await _dio.get('/feedup/research/filter_options/');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return {
          'categories': List<String>.from(data['categories'] ?? []),
          'institutions': List<String>.from(data['institutions'] ?? []),
        };
      } else {
        appLogger.w('Failed to fetch research filter options: ${response.statusCode}');
        return _getDefaultResearchFilterOptions();
      }
    } on DioException catch (e) {
      appLogger.e('DioException fetching research filter options: ${e.message}');
      return _getDefaultResearchFilterOptions();
    } catch (e) {
      appLogger.e('Error fetching research filter options: $e');
      return _getDefaultResearchFilterOptions();
    }
  }

  // Get all filter options (combined)
  static Future<Map<String, List<String>>> getAllFilterOptions() async {
    try {
      final conferenceOptions = await getConferenceFilterOptions();
      final researchOptions = await getResearchFilterOptions();
      
      return {
        ...conferenceOptions,
        ...researchOptions,
      };
    } catch (e) {
      appLogger.e('Error fetching all filter options: $e');
      return {
        ..._getDefaultConferenceFilterOptions(),
        ..._getDefaultResearchFilterOptions(),
      };
    }
  }

  // Helper method for pagination support
  static Future<Map<String, dynamic>> fetchConferencesPaginated({
    bool showPast = false,
    String? search,
    String? location,
    String? topic,
    String? ordering = 'start_date',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'show_past': showPast.toString(),
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (search != null && search.isNotEmpty) params['search'] = search;
      if (location != null && location.isNotEmpty) params['location'] = location;
      if (topic != null && topic.isNotEmpty) params['topics'] = topic;
      if (ordering != null) params['ordering'] = ordering;

      final response = await _dio.get('/feedup/conferences/', queryParameters: params);
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return {
          'results': (data['results'] as List<dynamic>)
              .map((json) => Conference.fromJson(json))
              .toList(),
          'count': data['count'] ?? 0,
          'next': data['next'],
          'previous': data['previous'],
          'hasNext': data['next'] != null,
          'hasPrevious': data['previous'] != null,
        };
      } else {
        return {
          'results': <Conference>[],
          'count': 0,
          'next': null,
          'previous': null,
          'hasNext': false,
          'hasPrevious': false,
        };
      }
    } on DioException catch (e) {
      appLogger.e('DioException fetching conferences (paginated): ${e.message}');
      return {
        'results': <Conference>[],
        'count': 0,
        'next': null,
        'previous': null,
        'hasNext': false,
        'hasPrevious': false,
        'error': e.message,
      };
    } catch (e) {
      appLogger.e('Error fetching conferences (paginated): $e');
      return {
        'results': <Conference>[],
        'count': 0,
        'next': null,
        'previous': null,
        'hasNext': false,
        'hasPrevious': false,
        'error': e.toString(),
      };
    }
  }

  // Helper method for pagination support - Research
  static Future<Map<String, dynamic>> fetchResearchUpdatesPaginated({
    String? search,
    String? category,
    String? institution,
    int? recentDays,
    String? ordering = '-publication_date',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (search != null && search.isNotEmpty) params['search'] = search;
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (institution != null && institution.isNotEmpty) params['institution'] = institution;
      if (recentDays != null) params['recent_days'] = recentDays.toString();
      if (ordering != null) params['ordering'] = ordering;

      final response = await _dio.get('/feedup/research/', queryParameters: params);
      
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return {
          'results': (data['results'] as List<dynamic>)
              .map((json) => ResearchUpdate.fromJson(json))
              .toList(),
          'count': data['count'] ?? 0,
          'next': data['next'],
          'previous': data['previous'],
          'hasNext': data['next'] != null,
          'hasPrevious': data['previous'] != null,
        };
      } else {
        return {
          'results': <ResearchUpdate>[],
          'count': 0,
          'next': null,
          'previous': null,
          'hasNext': false,
          'hasPrevious': false,
        };
      }
    } on DioException catch (e) {
      appLogger.e('DioException fetching research updates (paginated): ${e.message}');
      return {
        'results': <ResearchUpdate>[],
        'count': 0,
        'next': null,
        'previous': null,
        'hasNext': false,
        'hasPrevious': false,
        'error': e.message,
      };
    } catch (e) {
      appLogger.e('Error fetching research updates (paginated): $e');
      return {
        'results': <ResearchUpdate>[],
        'count': 0,
        'next': null,
        'previous': null,
        'hasNext': false,
        'hasPrevious': false,
        'error': e.toString(),
      };
    }
  }

  // Default filter options
  static Map<String, List<String>> _getDefaultConferenceFilterOptions() {
    return {
      'locations': [
        'New York, USA',
        'San Francisco, USA',
        'London, UK',
        'Online',
        'Boston, USA',
        'Seattle, USA',
        'Berlin, Germany',
        'Tokyo, Japan',
      ],
      'topics': [
        'AI',
        'Machine Learning',
        'Cybersecurity',
        'Web Development',
        'Mobile Development',
        'Data Science',
        'Cloud Computing',
        'DevOps',
      ],
    };
  }

  static Map<String, List<String>> _getDefaultResearchFilterOptions() {
    return {
      'categories': [
        'Machine Learning',
        'Artificial Intelligence',
        'Cybersecurity',
        'Software Engineering',
        'Computer Vision',
        'Natural Language Processing',
        'Distributed Systems',
        'Human-Computer Interaction',
        'Data Science',
        'Algorithms',
      ],
      'institutions': [
        'MIT',
        'Stanford University',
        'Carnegie Mellon University',
        'UC Berkeley',
        'Harvard University',
        'Google Research',
        'Microsoft Research',
        'Facebook AI Research',
        'IBM Research',
        'OpenAI',
      ],
    };
  }
}