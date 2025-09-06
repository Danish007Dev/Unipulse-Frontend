import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userType;
  String? _userEmail;
  bool _isAuthenticated = false;

  // Public getters
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _userType;
  String? get token => _token;
  String? get email => _userEmail;

  AuthProvider();

  /// Load data from secure storage 
 Future<void> loadStoredTokens() async {
  final storedAccessToken = await TokenManager.getAccessToken();
  final storedRefreshToken = await TokenManager.getRefreshToken();
  final storedRole = await TokenManager.getUserRole();
  final storedEmail = await TokenManager.getCurrentUserEmail();

  _isAuthenticated = false;

  if (storedRefreshToken != null) {
    final isAccessExpiredOrMissing = storedAccessToken == null ||
        await TokenManager.isTokenExpiredOrExpiring();

    if (isAccessExpiredOrMissing) {
      appLogger.w("⚠️ Access token missing/expired. Attempting refresh...");

      final newAccessToken = await TokenManager.refreshBothTokens();
      if (newAccessToken != null) {
        _token = newAccessToken;
        _userType = storedRole;
        _userEmail = storedEmail;
        _isAuthenticated = true;

        appLogger.i("🔁 Token refresh successful.");
      } else {
        appLogger.w("❌ Token refresh failed. Logging out.");
        await logout();
        return;
      }
    } else {
      _token = storedAccessToken;
      _userType = storedRole;
      _userEmail = storedEmail;
      _isAuthenticated = true;

      appLogger.i("✅ Valid access token found.");
    }
  } else {
    appLogger.w("🔒 No refresh token found. Login required.");
  }

  appLogger.i('🔐 Final AuthProvider state → token=$_token, role=$_userType, email=$_userEmail');
  notifyListeners();
  }




  /// Login and persist all auth data
  Future<void> login(String accessToken, String refreshToken, String userType, String email) async {
    _token = accessToken;
    _userType = userType;
    _userEmail = email;
    _isAuthenticated = true;

    // ✅ FIX: Use named parameters to match the updated TokenManager.saveTokens method.
    await TokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userType: userType,
      email: email,
    );
    await TokenManager.debugPrintStoredValues(); 
    notifyListeners();
  }

  /// Silently clears the in-memory state without clearing storage.
  /// This is used when another auth method (like FeedUp) is used, to ensure states are mutually exclusive.
  void clearState() {
    _token = null;
    _userType = null;
    _userEmail = null;
    _isAuthenticated = false;
    notifyListeners();
    appLogger.i('🧹 Silently cleared AMU AuthProvider in-memory state.');
  }

  /// Clears all state and secure storage
  Future<void> logout() async {
    _token = null;
    _userType = null;
    _userEmail = null;
    _isAuthenticated = false;

    await TokenManager.clearAllTokens();
    appLogger.i('👋 Logged out and cleared session');
    
    // ❌ REMOVE NAVIGATION LOGIC FROM THE PROVIDER
    // The UI should react to the state change, not be forced to navigate.
    // if (navigatorKey.currentState?.mounted ?? false) {
    //   navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/role-selection',
    //     (_) => false,
    //   );
    // } else {
    //   appLogger.w('⚠️ navigatorKey not mounted during logout');
    // }

    notifyListeners(); // The UI will rebuild automatically
  }

  /// Loads session if not already available in memory
  Future<void> loadSessionIfNeeded() async {
    if (_token == null || _userType == null || _userEmail == null) {
      await loadStoredTokens();
    } else {
      _isAuthenticated = true;
      notifyListeners();
    }
  }
}



// 🔁 What Happens After This Refactor
// AuthProvider becomes the single source of truth for session state.

// TokenManager handles secure storage.

// Dio interceptors will still rely on TokenManager.getAccessToken() — perfect.

