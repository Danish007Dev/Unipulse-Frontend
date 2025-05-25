
// import 'package:flutter/material.dart';
// import '../utils/secure_storage.dart';
// import '../utils/token_manager.dart';

// class AuthProvider extends ChangeNotifier {
//   String? _token;
//   String? user_type;
//   bool _isAuthenticated = false;

//   bool get isAuthenticated => _isAuthenticated;
//   String? get role => user_type;

//   AuthProvider() {
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     _token = await SecureStorage.getToken();
//     user_type = await SecureStorage.getRole();
//     _isAuthenticated = _token != null;
//     notifyListeners();
//   }

//   Future<void> login(String token, String role) async {
//     _token = token;
//     user_type = role;
//     _isAuthenticated = true;
//     await SecureStorage.storeToken(token);
//     await SecureStorage.storeRole(role);
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     _token = null;
//     user_type = null;
//     _isAuthenticated = false;
//     await SecureStorage.deleteToken();
//     await SecureStorage.deleteRole();
//     notifyListeners();
//   }

// refactor your AuthProvider to use TokenManager instead of SecureStorage, and remove any duplication in token/role handling.
import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import '../utils/logger.dart';

import '../main.dart'; // Import your main.dart to access navigatorKey

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

   // await TokenManager.debugTestTokenSave(); // Debugging line to test token saving
    await TokenManager.saveTokens(accessToken, refreshToken, userType, email);//Positional parameters → must be passed in order without naming
    await TokenManager.debugPrintStoredValues(); 
    notifyListeners();
    //appLogger.i('✅ AuthProvider login(): saved access token+saved refresh token, role, email to storage');
    await loadStoredTokens(); // Refresh from storage for consistency
  }

  /// Clears all state and secure storage
  Future<void> logout() async {
    _token = null;
    _userType = null;
    _userEmail = null;
    _isAuthenticated = false;

    await TokenManager.clearAllTokens();
    appLogger.i('👋 Logged out and cleared session');
    notifyListeners();
    // Handle navigation
    if (navigatorKey.currentState?.mounted ?? false) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/role-selection',
        (_) => false,
      );
    } else {
      appLogger.w('⚠️ navigatorKey not mounted during logout');
    }
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

