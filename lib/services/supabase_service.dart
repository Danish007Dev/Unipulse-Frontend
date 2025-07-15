import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path_utils;
import '../utils/logger.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Bucket paths
  static const String DOCUMENT_BUCKET = 'media-unipulse/documents';
  static const String IMAGE_BUCKET = 'media-unipulse/images';
  
  /// Upload a file to Supabase storage and return its public URL
  static Future<String?> uploadFile({
    required File file,
    required String filename,
    required bool isImage,
  }) async {
    try {
      final String bucket = isImage ? IMAGE_BUCKET : DOCUMENT_BUCKET;
      final String ext = path_utils.extension(filename);
      final String uniqueFilename = '${const Uuid().v4()}$ext';
      
      // Upload file
      await _supabase
          .storage
          .from(bucket)
          .upload(uniqueFilename, file);
          
      // Get public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(uniqueFilename);
      
      appLogger.i('✅ File uploaded to Supabase: $url');
      return url;
    } catch (e) {
      appLogger.e('❌ Error uploading file to Supabase', error: e);
      return null;
    }
  }
  
  /// Download a file from Supabase to a temporary directory
  static Future<File?> downloadFile(String url) async {
    try {
      // Implementation for downloading files if needed
      return null;
    } catch (e) {
      appLogger.e('❌ Error downloading file from Supabase', error: e);
      return null;
    }
  }
}