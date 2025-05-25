import 'package:dio/dio.dart';         //20/05/25
import '/services/dio_client.dart';
import '/utils/logger.dart';
import 'fac_post_model.dart';
import '/models/course_model.dart';
import '/models/semester_model.dart';
import '/services/api_config.dart'; 

class PostService {
  static final Dio _dio = DioClient().client;

  /// Fetches courses assigned to the logged-in faculty
  static Future<List<Course>> getCourses() async {
    try {
      final response = await _dio.get(ApiConfig.facultyCourses);
      return (response.data as List)
          .map((e) => Course.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      appLogger.e('❌ Failed to fetch courses', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Fetches semesters for a selected course
  static Future<List<Semester>> getSemesters(int courseId) async {
    try {
      final response = await _dio.get(ApiConfig.courseSemesters(courseId));
      return (response.data as List)
          .map((e) => Semester.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      appLogger.e('❌ Failed to fetch semesters', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Fetches faculty posts with optional course/semester filters and pagination
  static Future<List<Post>> getFacultyPosts({
    int? courseId,
    int? semesterId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (courseId != null) params['course_id'] = courseId.toString();
    if (semesterId != null) params['semester_id'] = semesterId.toString();

    try {
      final response = await _dio.get(
        ApiConfig.facultyPosts,
        queryParameters: params,
      );
      appLogger.i('📦 Raw faculty posts response: ${response.data}');
      return (response.data['results'] as List)
          .map((e) => Post.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      appLogger.e('❌ Failed to fetch posts', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Creates a new post with optional file upload
  static Future<PostCreationResult> createPost(PostCreateData data) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('content', data.content),
      MapEntry('course', data.courseId.toString()),
      MapEntry('semester', data.semesterId.toString()),
    ]);

    if (data.document?.path != null) {
      try {
        final documentFile = await MultipartFile.fromFile(
          data.document!.path!,
          filename: data.document!.name,
        );
        formData.files.add(MapEntry('document_upload', documentFile));
      } catch (e) {
        appLogger.e('❌ Failed to prepare document', error: e);
        return PostCreationResult(success: false, message: 'Document could not be processed.');
      }
    }

    if (data.image?.path != null) {
      try {
        final imageFile = await MultipartFile.fromFile(
          data.image!.path!,
          filename: data.image!.name,
        );
        formData.files.add(MapEntry('image_upload', imageFile));
      } catch (e) {
        appLogger.e('❌ Failed to prepare image', error: e);
        return PostCreationResult(success: false, message: 'Image could not be processed.');
      }
    }

    try {
      final response = await _dio.post(
        ApiConfig.createFacultyPost,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        appLogger.i('✅ Post created successfully');
        return PostCreationResult(success: true);
      } else {
        appLogger.e('❌ Post creation failed with status: ${response.statusCode}');
        return PostCreationResult(
          success: false,
          message: 'Unexpected server response: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      appLogger.e('❌ Failed to create post', error: e, stackTrace: stackTrace);

      String message = 'Failed to create post.';
      if (e is DioException &&
          e.response?.data is Map &&
          e.response?.data['detail'] != null) {
        message = e.response!.data['detail'].toString();
      }

      return PostCreationResult(success: false, message: message);
    }
  }

  /// Deletes a faculty post
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await _dio.delete(ApiConfig.deleteFacultyPost(postId));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e, stackTrace) {
      appLogger.e('❌ Failed to delete post', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

class PostCreationResult {
    final bool success;
    final String? message;

    PostCreationResult({
      required this.success,
      this.message,
    });
}
