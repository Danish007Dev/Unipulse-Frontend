import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../utils/logger.dart';


class FeedUpAuthService {
  final Dio _dio = DioClient().client;

  Future<bool?> checkUserExists(String email) async {
    try {
      final response = await _dio.post(
        '/feedup/auth/check-user/',
        data: {'email': email},
      );
      return response.data['exists'] as bool;
    } on DioException catch (e) {
      appLogger.e('Failed to check user: ${e.response?.data}');
      return null;
    }
  }

  Future<bool> sendOtp(String email) async {
    try {
      await _dio.post('/feedup/auth/send-otp/', data: {'email': email});
      appLogger.i('OTP request sent for $email');
      return true;
    } on DioException catch (e) {
      appLogger.e('Failed to send OTP: ${e.response?.data}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '/feedup/auth/verify-otp/',
        data: {'email': email, 'otp': otp},
      );
      appLogger.i('OTP verified for $email');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      appLogger.e('Failed to verify OTP: ${e.response?.data}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerWithPassword({
    required String email,
    required String password,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '/feedup/auth/register/',
        data: {'email': email, 'password': password, 'token': token},
      );
      appLogger.i('User registered successfully: $email');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      appLogger.e('Registration failed: ${e.response?.data}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/feedup/auth/login/',
        data: {'email': email, 'password': password},
      );
      appLogger.i('User logged in successfully with password: $email');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      appLogger.e('Password login failed: ${e.response?.data}');
      return null;
    }
  }

  Future<bool> setFeedUpPassword(String password) async {
    try {
      await _dio.post(
        '/feedup/auth/set-password/',
        data: {'password': password},
      );
      return true;
    } on DioException catch (e) {
      appLogger.e('Failed to set password: ${e.response?.data}');
      return false;
    }
  }
}