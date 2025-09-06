import 'package:dio/dio.dart';
import '../../services/dio_client.dart';
import '../../utils/logger.dart';

class FacultyService {
  static final Dio _dio = DioClient().client;

  /// Get faculty majors
  static Future<List<String>> getFacultyMajors() async {
    try {
      final response = await _dio.get('/views/faculty/majors/');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final majors = List<String>.from(data['majors'] ?? []);
        appLogger.i('Successfully fetched faculty majors: $majors');
        return majors;
      } else {
        appLogger.w('Failed to fetch faculty majors: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      appLogger.e('DioException fetching faculty majors: ${e.message}');
      return [];
    } catch (e) {
      appLogger.e('Error fetching faculty majors: $e');
      return [];
    }
  }
}