// import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/token_manager.dart';
import '../utils/logger.dart';
import 'dart:io';

class DioClient {
  // Singleton pattern to ensure only one instance of DioClient exists.
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  /// Public getter to access the Dio instance, aliased as 'client'.
  Dio get client => dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    final String baseUrl = dotenv.env['API_BASE_URL'] ??
        (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000');

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Public endpoints do not need a token.
          if (_isPublicEndpoint(options.path)) {
            return handler.next(options);
          }

          // For protected endpoints, get the token.
          var token = await TokenManager.getAccessToken();

          // If the token is expired, try to refresh it.
          if (token != null && await TokenManager.isTokenExpiredOrExpiring()) {
            appLogger.w("⚠️ Access token expired, attempting refresh...");
            token = await TokenManager.refreshBothTokens();
          }

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            appLogger.i("✅ Token attached for protected route: ${options.path}");
            return handler.next(options);
          } else {
            // If no token is available after checking, reject the request.
            appLogger.e("❌ No valid token found for protected route: ${options.path}. Rejecting request.");
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Authentication token not found or refresh failed.',
                type: DioExceptionType.cancel,
              ),
            );
          }
        },
        onError: (DioException e, handler) async {
          // This block is now less critical as the onRequest handles refresh,
          // but can be kept for other error handling.
          return handler.next(e);
        },
      ),
    );

    // Add a logger for debugging network requests.
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => appLogger.d(obj.toString()),
    ));
  }

  bool _isPublicEndpoint(String path) {
    // Centralized list of all public routes in your app.
    final publicPatterns = [
      // RegExp(r'^/feedup/auth/sync-unipulse-user'),      
      RegExp(r'^/feedup/auth/login'), // FeedUp login
      RegExp(r'^/feedup/auth/check-user'), // FeedUp logout
      RegExp(r'^/feedup/auth/register'), // FeedUp registration
      RegExp(r'^/feedup/auth/request-otp'), // FeedUp OTP request
      RegExp(r'^/feedup/auth/send-otp'), // FeedUp OTP sending
      RegExp(r'^/feedup/auth/verify-otp'), // FeedUp OTP verification
      RegExp(r'^/feedup/auth/password-login'), // FeedUp password login
      RegExp(r'^/feedup/auth/password-register'), // FeedUp password registration
      RegExp(r'^/views/request-otp'), // UniApp OTP request
      RegExp(r'^/views/verify-otp'),  // UniApp OTP verification
      RegExp(r'^/views/register'),    // UniApp registration
      RegExp(r'^/views/departments'),       // UniApp departments
      RegExp(r'^/views/token/refresh'),// Token refresh endpoint
      RegExp(r'^/feedup/articles'),   // Public article list
    ];
    return publicPatterns.any((pattern) => pattern.hasMatch(path));
  }
}



