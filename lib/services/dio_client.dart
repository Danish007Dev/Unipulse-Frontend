// import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/token_manager.dart';
import '../utils/logger.dart';
import '../main.dart'; // for navigatorKey
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    appLogger.i('DioClient initialized with baseUrl: $baseUrl');
    
    // Uncomment the following lines if you want to use platform-specific base URLs
    // final String baseUrl = Platform.isAndroid
    //     ? 'http://192.168.159.34:8000' // Android emulator
    //     : 'http://localhost:8000';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    /// ✅ Logging interceptor
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => appLogger.d(obj),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;

          // ✅ Skip token logic for public endpoints
          if (_isPublicEndpoint(path)) {
            return handler.next(options);
          }

          // ✅ Proactive refresh if token is about to expire
          final shouldRefresh = await TokenManager.isTokenExpiredOrExpiring();
          if (shouldRefresh) {
            appLogger.i('🛠 Token about to expire — refreshing proactively...');
            final newAccessToken = await TokenManager.refreshBothTokens();

            if (newAccessToken != null) {
              options.headers['Authorization'] = 'Bearer $newAccessToken';
            } else {
              appLogger.w('❌ Proactive refresh failed. Logging out...');
              await _handleLogout();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.unknown,
                  error: 'Token expired and refresh failed.',
                ),
              );
            }
          } else {
            final accessToken = await TokenManager.getAccessToken();
            if (accessToken != null) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          return handler.next(options);
        },

        onError: (DioException error, handler) async {
          final isUnauthorized = error.response?.statusCode == 401;
          final isRefreshEndpoint = error.requestOptions.path.contains('/token/refresh');
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (isUnauthorized && !isRefreshEndpoint && !alreadyRetried) {
            appLogger.i('🔄 Token expired unexpectedly. Attempting fallback refresh...');
            final newAccessToken = await TokenManager.refreshBothTokens();

            if (newAccessToken != null) {
              appLogger.i('✅ Token refreshed. Retrying request...');

              final clonedRequest = await dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken',
                  },
                  extra: {'retried': true},
                ),
              );

              return handler.resolve(clonedRequest);
            } else {
              appLogger.w('❌ Token refresh failed. Logging out.');
              await _handleLogout();
              return handler.reject(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => dio;

  /// ✅ Detects public (unauthenticated) API endpoints
  // bool _isPublicEndpoint(String path) {
  //   return path.contains('/request-otp/') ||
  //          path.contains('/verify-otp/') ||
  //          path.contains('/views/departments/')||
  //          path.contains('/token/refresh');
  // }
  bool _isPublicEndpoint(String path) {
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  final publicPatterns = [
    RegExp(r'^/views/request-otp/?$'),
    RegExp(r'^/views/verify-otp/?$'),
    RegExp(r'^/views/departments/?$'),
    RegExp(r'^/token/refresh/?$'),
  ];

  return publicPatterns.any((pattern) => pattern.hasMatch(normalizedPath));
}


  /// ✅ Logs out and navigates to role selection
  Future<void> _handleLogout() async {
    globalAuthProvider.logout(); // Delegate logout to AuthProvider
    // if (navigatorKey.currentState?.mounted ?? false) {
    //   navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/role-selection',
    //     (_) => false,
    //   );
    // } else {
    //   appLogger.w('⚠️ navigatorKey not mounted during logout');
    // }
  }
}




// import 'dart:io';
// import 'package:dio/dio.dart';
// import '../utils/token_manager.dart';
// import '../utils/logger.dart';
// import '../main.dart'; // for navigatorKey

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   late final Dio dio;

//   factory DioClient() => _instance;

//   DioClient._internal() {
//     final String baseUrl = Platform.isAndroid
//         ? 'http://10.0.2.2:8000'
//         : 'http://localhost:8000';

//     dio = Dio(
//       BaseOptions(
//         baseUrl: baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final path = options.path;

//     // 🧠 Bypass token check for unauthenticated endpoints
//     final isPublicEndpoint = path.contains('/request-otp/') ||
//         path.contains('/verify-otp/') ||
//         path.contains('/token/refresh/');

//     if (isPublicEndpoint) {
//       return handler.next(options);
//     }
    

//      final shouldRefresh = await TokenManager.isTokenExpiredOrExpiring();
//             if (shouldRefresh) {
//               appLogger.i('🛠 Token about to expire — refreshing proactively...');
//               final newToken = await TokenManager.refreshAccessToken();
//               if (newToken != null) {
//                 options.headers['Authorization'] = 'Bearer $newToken';
//               } else {
//                 appLogger.w('❌ Failed proactive refresh. User should log in again.');
//                 await _handleLogout();
//                 return handler.reject(
//                   DioException(
//                     requestOptions: options,
//                     type: DioExceptionType.unknown,
//                     error: 'Token expired and refresh failed.',
//                   ),
//                 );
//               }
//             } else {
//               final accessToken = await TokenManager.getAccessToken();
//               if (accessToken != null) {
//                 options.headers['Authorization'] = 'Bearer $accessToken';
//               }
//             }

//             return handler.next(options);
//           },       

//         onError: (DioException error, handler) async {
//           final isUnauthorized = error.response?.statusCode == 401;
//           final isRefreshEndpoint = error.requestOptions.path.contains('/views/token/refresh/');
//           final alreadyRetried = error.requestOptions.extra['retried'] == true;

//           if (isUnauthorized && !isRefreshEndpoint && !alreadyRetried) {
//             appLogger.i('🔄 Token expired unexpectedly. Attempting fallback refresh...');
//             final newToken = await TokenManager.refreshAccessToken();
//             if (newToken != null) {
//               appLogger.i('✅ Token refreshed. Retrying request...');

//               final clonedRequest = await dio.request(
//                 error.requestOptions.path,
//                 data: error.requestOptions.data,
//                 queryParameters: error.requestOptions.queryParameters,
//                 options: Options(
//                   method: error.requestOptions.method,
//                   headers: {
//                     ...error.requestOptions.headers,
//                     'Authorization': 'Bearer $newToken',
//                   },
//                   extra: {'retried': true},
//                 ),
//               );

//               return handler.resolve(clonedRequest);
//             } else {
//               appLogger.w('❌ Token refresh failed. Logging out.');
//               await _handleLogout();
//               return handler.reject(error);
//             }
//           }

//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Dio get client => dio;

//   Future<void> _handleLogout() async {
//     await TokenManager.clearTokens();
//     if (navigatorKey.currentState?.mounted ?? false) {
//   navigatorKey.currentState?.pushNamedAndRemoveUntil(
//     '/role-selection',
//     (_) => false,
//   );
// } else {
//   appLogger.w('⚠️ navigatorKey not mounted during logout');
// }
//   }
// }




// import 'dart:io';
// import 'package:dio/dio.dart';
// import '../utils/token_manager.dart';
// import '../utils/logger.dart';
// import '../main.dart'; // for navigatorKey

// class DioClient {
//   static final DioClient _instance = DioClient._internal();
//   late final Dio dio;

//   factory DioClient() => _instance;

//   DioClient._internal() {
//     final String baseUrl = Platform.isAndroid
//         ? 'http://10.0.2.2:8000' // Android emulator
//         : 'http://localhost:8000'; // iOS/desktop/web

//     dio = Dio(
//       BaseOptions(
//         baseUrl: baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = await TokenManager.getAccessToken();
//           if (token != null) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },

//         onError: (DioException error, handler) async {
//           final isUnauthorized = error.response?.statusCode == 401;
//           final isRefreshEndpoint = error.requestOptions.path.contains('/views/token/refresh/');
//           final alreadyRetried = error.requestOptions.extra['retried'] == true;

//           if (isUnauthorized && !isRefreshEndpoint && !alreadyRetried) {
//             appLogger.i('🔄 Access token expired. Attempting refresh...');

//             try {
//               final newToken = await TokenManager.refreshAccessToken();
//               if (newToken != null) {
//                 appLogger.i('✅ Token refreshed. Retrying request...');

//                 final clonedRequest = await dio.request(
//                   error.requestOptions.path,
//                   data: error.requestOptions.data,
//                   queryParameters: error.requestOptions.queryParameters,
//                   options: Options(
//                     method: error.requestOptions.method,
//                     headers: {
//                       ...error.requestOptions.headers,
//                       'Authorization': 'Bearer $newToken',
//                     },
//                     extra: {'retried': true},
//                   ),
//                 );

//                 return handler.resolve(clonedRequest);
//               } else {
//                 appLogger.w('❌ Refresh token expired or invalid.');
//                 await _handleLogout();
//                 return handler.reject(error);
//               }
//             } catch (e, stackTrace) {
//               appLogger.e('🔥 Refresh token failed: $e', error: e, stackTrace: stackTrace);
//               await _handleLogout();
//               return handler.reject(error);
//             }
//           }

//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   Dio get client => dio;

//   Future<void> _handleLogout() async {
//     await TokenManager.clearTokens();
//     globalAuthProvider.logout();

//     navigatorKey.currentState?.pushNamedAndRemoveUntil(
//       '/role-selection',
//       (_) => false,
//     );
//   }
// }
// Feature | ✅ Status
// Platform-aware baseUrl | ✅ Correctly handles Android vs others
// Singleton pattern | ✅ Using _instance and factory constructor
// Global Dio instance | ✅ dio stored with BaseOptions
// Access token injection | ✅ On every request via onRequest
// 401 interceptor | ✅ Refresh logic, retry with extra['retried']
// Refresh token protection | ✅ Avoids retry loops on /token/refresh/
// Auto logout on refresh fail | ✅ Clears tokens, calls globalAuthProvider.logout() and navigates
// Logging | ✅ Uses appLogger throughout (not print)