import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
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
      if (refreshToken == null) {
        appLogger.w('🚫 No refresh token available. Cannot refresh.');
        return null;
      }

      _isRefreshing = true;
      appLogger.i("🔄 Attempting to refresh tokens...");

      try {
        // Use a new, clean Dio instance to avoid interceptor loops.
        // IMPORTANT: Replace with your actual API base URL.
        final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

        final response = await dio.post(
          '/views/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = response.data['access'] as String?;
        final newRefreshToken = response.data['refresh'] as String?;

        if (newAccessToken == null) {
          throw Exception("Refresh response did not contain a new access token.");
        }

        // Atomically save the new tokens.
        await _lock.synchronized(() async {
          await _storage.write(key: 'accessToken', value: newAccessToken);
          if (newRefreshToken != null) {
            await _storage.write(key: 'refreshToken', value: newRefreshToken);
            appLogger.i("✅ New refresh token (rotated) was saved.");
          }
        });

        appLogger.i('✅ Tokens refreshed successfully.');
        return newAccessToken;
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          appLogger.e('🚫 Refresh token is invalid or expired (401). User must log in again.');
        } else {
          appLogger.e("🔥 Dio error during token refresh: ${e.message}");
        }
        // If refresh fails for any reason, the session is invalid.
        await clearAllTokens();
        return null;
      } catch (e) {
        appLogger.e("🔥 Unexpected error refreshing token: $e");
        await clearAllTokens();
        return null;
      } finally {
        _isRefreshing = false; // Release the lock for other requests.
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
