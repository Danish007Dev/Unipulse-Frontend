import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:synchronized/synchronized.dart';
import 'logger.dart';

/// Manages storing, retrieving, and refreshing authentication tokens.
/// This class is the single source of truth for token state.
class TokenManager {
  static final _storage = FlutterSecureStorage();
  static final _lock = Lock(); // For simple read/write operations
  static final _refreshLock = Lock(); // To prevent concurrent token refreshes
  static bool _isRefreshing = false;

  /// Saves all authentication details to secure storage.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userType,
    required String email,
  }) async {
    await _lock.synchronized(() async {
      appLogger.i("💾 Saving tokens for user: $email, role: $userType");
      await Future.wait([
        _storage.write(key: 'accessToken', value: accessToken),
        _storage.write(key: 'refreshToken', value: refreshToken),
        _storage.write(key: 'userType', value: userType),
        _storage.write(key: 'userEmail', value: email),
      ]);
    });
  }

  /// Retrieves the access token.
  static Future<String?> getAccessToken() async {
    return await _lock.synchronized(() => _storage.read(key: 'accessToken'));
  }

  /// Retrieves the refresh token.
  static Future<String?> getRefreshToken() async {
    return await _lock.synchronized(() => _storage.read(key: 'refreshToken'));
  }

  /// Retrieves the user's role.
  static Future<String?> getUserRole() async {
    return await _lock.synchronized(() => _storage.read(key: 'userType'));
  }

  /// Retrieves the user's email.
  static Future<String?> getCurrentUserEmail() async {
    return await _lock.synchronized(() => _storage.read(key: 'userEmail'));
  }

  /// Deletes all stored authentication data.
  static Future<void> clearAllTokens() async {
    await _lock.synchronized(() async {
      await _storage.deleteAll();
      appLogger.i('🧼 All tokens and user data cleared from secure storage.');
    });
  }

  /// Checks if the access token is missing, expired, or will expire soon.
  static Future<bool> isTokenExpiredOrExpiring({int bufferSeconds = 60}) async {
    final token = await getAccessToken();
    if (token == null) {
      return true; // Token is missing
    }
    // Check if expired OR will expire within the buffer time
    return JwtDecoder.isExpired(token) ||
        JwtDecoder.getRemainingTime(token).inSeconds <= bufferSeconds;
  }

  /// Refreshes both access and refresh tokens using the stored refresh token.
  /// Returns the new access token on success, or null on failure.
  /// This method is protected against concurrent execution.
  static Future<String?> refreshBothTokens() async {
    // Use a separate lock to handle concurrent refresh attempts gracefully.
    return await _refreshLock.synchronized(() async {
      // If a refresh is already happening, wait for it to finish and return its result.
      if (_isRefreshing) {
        appLogger.i("⏳ Another refresh is already in progress, waiting...");
        // This loop waits until the other process finishes.
        await Future.doWhile(() => _isRefreshing);
        return await getAccessToken(); // Return the newly fetched token
      }

      final refreshToken = await getRefreshToken();
      final userType = await getUserRole(); // <-- Get the user's role

      if (refreshToken == null || userType == null) {
        appLogger.e("❌ Cannot refresh: Refresh token or user type is missing.");
        await clearAllTokens();
        return null;
      }

      appLogger.i("🔄 Attempting to refresh tokens for user type: $userType...");

      try {
        final String baseUrl = dotenv.env['API_BASE_URL'] ??
            (Platform.isAndroid ? 'http://10.0.2.2:8000' : 'http://localhost:8000');

        // --- DYNAMIC REFRESH PATH LOGIC ---
        final String refreshPath;
        if (userType == 'student' || userType == 'faculty' || userType == 'admin') {
          // This is a UniPulse user
          refreshPath = '/views/token/refresh/';
        } else {
          // This includes 'feedup_user' and 'google_user'
          refreshPath = '/feedup/auth/token/refresh/';
        }
        appLogger.i("--> Using refresh path: $refreshPath");
        // --- END OF DYNAMIC LOGIC ---

        final dio = Dio(BaseOptions(baseUrl: baseUrl));
        final response = await dio.post(
          refreshPath, // Use the dynamically selected path
          data: {'refresh': refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access'];
          // Some refresh endpoints might return a new refresh token as well
          final newRefreshToken = response.data['refresh'] ?? refreshToken;

          await saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            userType: userType, // Persist the user type
            email: (await getCurrentUserEmail()) ?? '',
          );
          appLogger.i("✅ Tokens refreshed successfully.");
          return newAccessToken;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Token refresh failed with status ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        appLogger.e("⛔ Dio error during token refresh: ${e.message}");
        await clearAllTokens(); // Critical failure, log the user out
        return null;
      } finally {
        _isRefreshing = false;
      }
    });
  }

  /// Prints all stored values for debugging purposes.
  static Future<void> debugPrintStoredValues() async {
    final values = await _storage.readAll();
    appLogger.d("--- 🧪 DEBUG: Stored Token Values ---");
    appLogger.d("accessToken: ${values['accessToken'] ?? 'null'}");
    appLogger.d("refreshToken: ${values['refreshToken'] ?? 'null'}");
    appLogger.d("userType: ${values['userType'] ?? 'null'}");
    appLogger.d("userEmail: ${values['userEmail'] ?? 'null'}");
    appLogger.d("------------------------------------");
  }
}
