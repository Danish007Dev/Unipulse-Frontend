import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path_utils;
import 'package:uuid/uuid.dart';
import '/services/dio_client.dart';
import '/utils/logger.dart';
import 'fac_post_model.dart';
import '/models/course_model.dart';
import '/models/semester_model.dart';
import '/services/api_config.dart'; 

class PostService {
  static final Dio _dio = DioClient().client;
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String DOCUMENT_BUCKET = 'media-unipulse/documents';
  static const String IMAGE_BUCKET = 'media-unipulse/images';
  
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

  /// Creates a new post with Supabase file upload
  static Future<PostCreationResult> createPost(PostCreateData data) async {
    String? documentUrl;
    String? imageUrl;
    
    // Step 1: Upload files to Supabase with better error handling
    try {
      // Handle document upload
      if (data.document != null && data.document!.path != null) {
        final File documentFile = File(data.document!.path!);
        
        if (await documentFile.exists()) {
          final String ext = path_utils.extension(data.document!.name).toLowerCase();
          final String uniqueFilename = '${const Uuid().v4()}$ext';
          
          appLogger.i('📄 Uploading document to Supabase: ${documentFile.path}');
          
          // Upload to Supabase
          await _supabase
              .storage
              .from(DOCUMENT_BUCKET)
              .upload(uniqueFilename, documentFile);
              
          // Get public URL
          documentUrl = _supabase.storage.from(DOCUMENT_BUCKET).getPublicUrl(uniqueFilename);
          
          // Log the URL for debugging
          appLogger.i('✅ Document uploaded to Supabase: $documentUrl');
        } else {
          appLogger.e('❌ Document file does not exist: ${data.document!.path}');
        }
      }
      
      // Handle image upload - separate from document upload
      if (data.image != null && data.image!.path != null) {
        final File imageFile = File(data.image!.path!);
        
        if (await imageFile.exists()) {
          final String ext = path_utils.extension(data.image!.name).toLowerCase();
          final String uniqueFilename = '${const Uuid().v4()}$ext';
          
          appLogger.i('🖼️ Uploading image to Supabase: ${imageFile.path}');
          
          // Upload to Supabase
          await _supabase
              .storage
              .from(IMAGE_BUCKET)
              .upload(uniqueFilename, imageFile);
              
          // Get public URL
          imageUrl = _supabase.storage.from(IMAGE_BUCKET).getPublicUrl(uniqueFilename);
          
          // Log the URL for debugging
          appLogger.i('✅ Image uploaded to Supabase: $imageUrl');
        } else {
          appLogger.e('❌ Image file does not exist: ${data.image!.path}');
        }
      }
    } catch (e) {
      appLogger.e('❌ Error uploading files to Supabase', error: e);
      return PostCreationResult(success: false, message: 'File upload failed: ${e.toString()}');
    }
    
    // Step 2: Create post with file URLs
    try {
      final formData = FormData.fromMap({
        'content': data.content,
        'course': data.courseId.toString(),
        'semester': data.semesterId.toString(),
        // Pass URLs directly to backend
        if (documentUrl != null) 'document_url': documentUrl,
        if (imageUrl != null) 'image_url': imageUrl,
      });
      
      appLogger.i('📦 Creating post with form data: ${formData.fields}');
      
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
    } catch (e) {
      appLogger.e('❌ Failed to create post', error: e);

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
