import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/dio_client.dart';
import 'package:synchronized/synchronized.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();
  static final _lock = Lock();
  static final _refreshLock = Lock();
  static bool _isInitialized = false;
  static bool _isRefreshing = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = true; // Nothing async to do now but can be extended later
      appLogger.i("🔑 TokenManager initialized.");
    }
  }

  static Future<void> _ensureInit() async {
    if (!_isInitialized) {
      await init();
    }
  }

  static Future<void> saveTokens(
    String? accessToken,
    String? refreshToken,
    String? userType, 
    String? email,
  ) async {
    await _ensureInit();
    await _lock.synchronized(() async {   
      final futures = <Future<void>>[];
      appLogger.i("🌀 saveTokens called with: access=$accessToken, refresh=$refreshToken, role=$userType, email=$email");

      if (accessToken != null) {
        futures.add(_storage.write(key: 'accessToken', value: accessToken.trim()));
      } else {
        appLogger.w('⚠️ accessToken is null when saving.');
      }

      if (refreshToken != null) {
        futures.add(_storage.write(key: 'refreshToken', value: refreshToken));
      } else {
        appLogger.w('⚠️ refreshToken is null when saving.');
      }

      if (userType != null) {
        futures.add(_storage.write(key: 'userType', value: userType));
      } else {
        appLogger.w('⚠️ userType is null when saving.');
      }

      if (email != null) {
        futures.add(_storage.write(key: 'userEmail', value: email));
      } else {
        appLogger.w('⚠️ userEmail is null when saving.');
      }

      await Future.wait(futures);
      appLogger.i('✅ TM-Tokens saved successfully for role and email: $userType and $email');
    });
  }

  static Future<void> debugPrintStoredValues() async {
    await _ensureInit();
    final access = await _storage.read(key: 'accessToken');
    final refresh = await _storage.read(key: 'refreshToken');
    final type = await _storage.read(key: 'userType');
    final email = await _storage.read(key: 'userEmail');

    appLogger.i("🧪 values read from storage:");
    appLogger.i("🧪 accessToken: ${access ?? 'null'}");
    appLogger.i("🧪 refreshToken: ${refresh ?? 'null'}");
    appLogger.i("🧪 userType: ${type ?? 'null'}");
    appLogger.i("🧪 userEmail: ${email ?? 'null'}");
  }

  static Future<String?> getAccessToken() async {
    await _ensureInit();
    return _lock.synchronized(() async {
      final token = await _storage.read(key: 'accessToken');
      appLogger.i('🔐 getAccessToken(): ${token != null ? "FOUND (length: ${token.length})" : "null"}');
      return token;
    });
  }

  Future<void> debugTestTokenSave() async {
  const testAccessToken = 'test123';
  await _storage.write(key: 'accessToken', value: testAccessToken);
  final readToken = await _storage.read(key: 'accessToken');
  print('🔍 Test accessToken read back: $readToken');
}


  static Future<String?> getRefreshToken() async {
    await _ensureInit();
    return _lock.synchronized(() async {
      final token = await _storage.read(key: 'refreshToken');
      appLogger.i('🔄 getRefreshToken(): ${token != null ? "FOUND (length: ${token.length})" : "null"}');
      return token;
    });
  }

  static Future<String?> getUserRole() async {
    await _ensureInit();
    return _lock.synchronized(() async {
      final role = await _storage.read(key: 'userType');
      appLogger.i('👤 getUserRole(): ${role ?? "null"}');
      return role;
      // String? role = await _storage.read(key: 'userRole');

      // if (role == null) {
      //   final accessToken = await _storage.read(key: 'accessToken');
      //   if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
      //     final decoded = JwtDecoder.decode(accessToken);
      //     role = decoded['user_type'];  // Adjust if your payload key is different
      //     appLogger.w('⚠️ userRole missing from storage, using token payload: $role');
      //     if (role != null) {
      //       await _storage.write(key: 'userRole', value: role);
      //     }
      //   }
      // }

      // appLogger.i('👤 getUserRole(): ${role ?? "null"}');
      // return role;
    });
  }

  static Future<String?> getCurrentUserEmail() async {
    await _ensureInit();
    return _lock.synchronized(() async {
      final email = await _storage.read(key: 'userEmail');
      appLogger.i('📧 getCurrentUserEmail(): ${email ?? "null"}');
      return email;
    });
  }

  static Future<void> saveAccessToken(String saveNewAccessToken) async {
    await _ensureInit();
    await _lock.synchronized(() => _storage.write(key: 'accessToken', value: saveNewAccessToken));
  }

  static Future<void> saveRefreshToken(String saveNewRefreshToken) async {
    await _ensureInit();
    await _lock.synchronized(() => _storage.write(key: 'refreshToken', value: saveNewRefreshToken));
  }

  // static Future<void> removeTokens() async { //**redundant**
  //   await _ensureInit();
  //   await _lock.synchronized(() async {
  //     await _storage.delete(key: 'accessToken');
  //     await _storage.delete(key: 'refreshToken');
  //   });
  // }

  static Future<void> clearAllTokens() async {
    await _ensureInit();
    await _lock.synchronized(() async {
      //await _storage.deleteAll();
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      await _storage.delete(key: 'userType');
      await _storage.delete(key: 'userEmail');
      appLogger.i('🧼 Cleared all tokens from secure storage');
    });
  }

  static Future<bool> isTokenExpiredOrExpiring({int bufferSeconds = 60}) async {
    await _ensureInit();
    return _lock.synchronized(() async {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) return true;

      return JwtDecoder.isExpired(token) ||
          JwtDecoder.getRemainingTime(token).inSeconds <= bufferSeconds;
    });
  }

  static Future<String?> refreshBothTokens() async {
    await _ensureInit();
    return await _refreshLock.synchronized(() async {
      if (_isRefreshing) {
        appLogger.i("⏳ Another refresh is already in progress, waiting...");
        await Future.delayed(const Duration(milliseconds: 500));
        return await getAccessToken();
      }

      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        appLogger.w('🚫 No refresh token available.');
        return null;
      }

      _isRefreshing = true;

      try {
        final dio = DioClient().client;
        final response = await dio.post(
          '/views/token/refresh/',
          data: {'refresh': refreshToken},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        final newAccessToken = response.data['access'];
        final newRefreshToken = response.data['refresh'];

        await saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await saveRefreshToken(newRefreshToken);
        }

        appLogger.i('🔁 Access and Refresh tokens refreshed');
        return newAccessToken;
      } catch (e) {
        appLogger.e("🔥 Refresh token error: $e");
        return null;
      } finally {
        _isRefreshing = false;
      }
    });
  }
}


// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:dio/dio.dart';
// import 'logger.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import '../services/dio_client.dart';
// import 'package:synchronized/synchronized.dart';


// class TokenManager {
//   static final _storage = FlutterSecureStorage();
//   static final _lock = Lock();
//   static final _refreshLock = Lock();
//   static bool _isRefreshing = false;

//   static Future<void> saveTokens(
//   String? accessToken,
//   String? refreshToken,
//   String? userRole, {
//   String? email,
// }) async {
//   await _lock.synchronized(() async {
//     final futures = <Future<void>>[];


//     if (accessToken != null) {
//       futures.add(_storage.write(key: 'accessToken', value: accessToken));
//     } else {
//       appLogger.w('⚠️ accessToken is null when saving.');
//     }

//     if (refreshToken != null) {
//       futures.add(_storage.write(key: 'refreshToken', value: refreshToken));
//     } else {
//       appLogger.w('⚠️ refreshToken is null when saving.');
//     }

//     if (userRole != null) {
//       futures.add(_storage.write(key: 'userRole', value: userRole));
//     } else {
//       appLogger.w('⚠️ userRole is null when saving.');
//     }

//     if (email != null) {
//       futures.add(_storage.write(key: 'userEmail', value: email));
//     } else {
//       appLogger.w('⚠️ userEmail is null when saving.');
//     }

//     await Future.wait(futures);

//     appLogger.i('✅ Tokens saved successfully for role and email: $userRole and $email');
//   });
// }
//   static Future<void> debugPrintStoredValues() async {
//   final access = await _storage.read(key: 'accessToken');
//   final refresh = await _storage.read(key: 'refreshToken');
//   final role = await _storage.read(key: 'userRole');
//   final email = await _storage.read(key: 'userEmail');

//   appLogger.i("🧪 accessToken: ${access ?? 'null'}");
//   appLogger.i("🧪 refreshToken: ${refresh ?? 'null'}");
//   appLogger.i("🧪 userRole: ${role ?? 'null'}");
//   appLogger.i("🧪 userEmail: ${email ?? 'null'}");
// }



//   // // Save all tokens + user role/email at once
//   // static Future<void> saveTokens(
//   //     String? accessToken, String? refreshToken, 
//   //     String? userRole,
//   //     {String? email}) async {
//   //   await _lock.synchronized(() async {
//   //     await Future.wait([
//   //       _storage.write(key: 'accessToken', value: accessToken),
//   //       _storage.write(key: 'refreshToken', value: refreshToken),
//   //       _storage.write(key: 'userRole', value: userRole),
//   //       if (email != null) _storage.write(key: 'userEmail', value: email),
//   //     ]);
//   //     appLogger.i('✅ Tokens saved successfully for role and email: $userRole and $email');
//   //   });
//   // }

//   // static Future<String?> getAccessToken() async {
//   //   return _lock.synchronized(() => _storage.read(key: 'accessToken'));
//   // }

//   // static Future<String?> getRefreshToken() async {
//   //   return _lock.synchronized(() => _storage.read(key: 'refreshToken'));
//   // }

//   // static Future<String?> getUserRole() async {
//   //   return _lock.synchronized(() => _storage.read(key: 'userRole'));
//   // }

//   // static Future<String?> getCurrentUserEmail() async {
//   //   return _lock.synchronized(() => _storage.read(key: 'userEmail'));
//   // }

//   static Future<String?> getAccessToken() async {
//     return _lock.synchronized(() async {
//       final token = await _storage.read(key: 'accessToken');
//       appLogger.i('🔐 getAccessToken(): ${token != null ? "FOUND (length: ${token.length})" : "null"}');
//       return token;
//     });
//   }

//   static Future<String?> getRefreshToken() async {
//     return _lock.synchronized(() async {
//       final token = await _storage.read(key: 'refreshToken');
//       appLogger.i('🔄 getRefreshToken(): ${token != null ? "FOUND (length: ${token.length})" : "null"}');
//       return token;
//     });
//   }

//   static Future<String?> getUserRole() async {
//     return _lock.synchronized(() async {
//       final role = await _storage.read(key: 'userRole');
//       appLogger.i('👤 getUserRole(): ${role ?? "null"}');
//       return role;
//     });
//   }

//   static Future<String?> getCurrentUserEmail() async {
//     return _lock.synchronized(() async {
//       final email = await _storage.read(key: 'userEmail');
//       appLogger.i('📧 getCurrentUserEmail(): ${email ?? "null"}');
//       return email;
//     });
//   }


//   static Future<void> saveAccessToken(String accessToken) async {
//     await _lock.synchronized(() =>
//         _storage.write(key: 'accessToken', value: accessToken));
//   }

//   static Future<void> removeTokens() async {
//     await _lock.synchronized(() async {
//       await _storage.delete(key: 'accessToken');
//       await _storage.delete(key: 'refreshToken');
//     });
//   }

//   static Future<void> clearTokens() async {
//     await _lock.synchronized(() async {
//       await _storage.deleteAll();
//       appLogger.i('🧼 Cleared all tokens from secure storage');
//     });
//   }

//   static Future<bool> isTokenExpiredOrExpiring({int bufferSeconds = 60}) async {
//     return _lock.synchronized(() async {
//       final token = await _storage.read(key: 'accessToken');
//       if (token == null) return true;

//       return JwtDecoder.isExpired(token) ||
//           JwtDecoder.getRemainingTime(token).inSeconds <= bufferSeconds;
//     });
//   }

//   static Future<void> saveRefreshToken(String token) async {
//     const storage = FlutterSecureStorage();
//     await storage.write(key: 'refreshToken', value: token);
//   }

  

//    static Future<String?> refreshBothTokens() async {
//     return await _refreshLock.synchronized(() async {
//       if (_isRefreshing) {
//         appLogger.i("⏳ Another refresh is already in progress, waiting...");
//         await Future.delayed(const Duration(milliseconds: 500));
//         return await getAccessToken(); // Return current token if already refreshed
//       }

//       final refreshToken = await getRefreshToken();
//       if (refreshToken == null) {
//         appLogger.w('🚫 No refresh token available.');
//         return null;
//       }

//       _isRefreshing = true;

//       try {
//         final dio = DioClient().client;
//         final response = await dio.post(
//           '/views/token/refresh/',
//           data: {'refresh': refreshToken},
//           options: Options(headers: {'Content-Type': 'application/json'}),
//         );

//         final newAccessToken = response.data['access'];
//         final newRefreshToken = response.data['refresh'];

//         await saveAccessToken(newAccessToken);
//         if (newRefreshToken != null) {
//           await saveRefreshToken(newRefreshToken);
//         }

//         appLogger.i('🔁 Access and Refresh tokens refreshed');
//         return newAccessToken;
//       } catch (e) {
//         appLogger.e("🔥 Refresh token error: $e");
//         return null;
//       } finally {
//         _isRefreshing = false;
//       }
//     });
//   }
// }





// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:dio/dio.dart';
// import 'logger.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import '../services/dio_client.dart';


// import 'package:synchronized/synchronized.dart';

// class TokenManager {
//   static final _storage = FlutterSecureStorage();
//   static final _lock = Lock();

//   static Future<void> saveTokens(
//       String? accessToken, String? refreshToken, String? userRole) async {
//     await _lock.synchronized(() async {
//       await Future.wait([
//         _storage.write(key: 'accessToken', value: accessToken),
//         _storage.write(key: 'refreshToken', value: refreshToken),
//         _storage.write(key: 'userRole', value: userRole),
//       ]);
//     });
//   }
//   //   static Future<void> saveTokens(String? accessToken, String? refreshToken, String? userRole) async {
//   //   final futures = <Future<void>>[];

//   //   if (accessToken != null) {
//   //     futures.add(_storage.write(key: 'accessToken', value: accessToken));
//   //   }
//   //   if (refreshToken != null) {
//   //     futures.add(_storage.write(key: 'refreshToken', value: refreshToken));
//   //   }
//   //   if (userRole != null) {
//   //     futures.add(_storage.write(key: 'userRole', value: userRole));
//   //   }

//   //   await Future.wait(futures);
//   // }

//   static Future<String?> getAccessToken() async {
//     return _lock.synchronized(() => _storage.read(key: 'accessToken'));
//   }

//   static Future<String?> getRefreshToken() async {
//     return _lock.synchronized(() => _storage.read(key: 'refreshToken'));
//   }

//   static Future<String?> getUserRole() async {
//     return _lock.synchronized(() => _storage.read(key: 'userRole'));
//   }

//   static Future<void> clearTokens() async {
//     await _lock.synchronized(() async {
//       await _storage.deleteAll();
//     });
//   }

//   static Future<void> saveAccessToken(String accessToken) async {
//     await _lock.synchronized(() =>
//         _storage.write(key: 'accessToken', value: accessToken));
//   }

//   static Future<void> removeTokens() async {
//     await _lock.synchronized(() async {
//       await _storage.delete(key: 'accessToken');
//       await _storage.delete(key: 'refreshToken');
//     });
//   }

//  static Future<bool> isTokenExpiredOrExpiring({int bufferSeconds = 60}) async {
//   return _lock.synchronized(() async {
//     final token = await _storage.read(key: 'accessToken');
//     if (token == null) return true;

//     return JwtDecoder.isExpired(token) ||
//         JwtDecoder.getRemainingTime(token).inSeconds <= bufferSeconds;
//   });
// }


// // class TokenManager {
// //   static final _storage = FlutterSecureStorage();


// //   static Future<void> saveTokens(String? accessToken, String? refreshToken, String? userRole) async {
// //     final futures = <Future<void>>[];

// //     if (accessToken != null) {
// //       futures.add(_storage.write(key: 'accessToken', value: accessToken));
// //     }
// //     if (refreshToken != null) {
// //       futures.add(_storage.write(key: 'refreshToken', value: refreshToken));
// //     }
// //     if (userRole != null) {
// //       futures.add(_storage.write(key: 'userRole', value: userRole));
// //     }

// //     await Future.wait(futures);
// //   }


// //   static Future<String?> getAccessToken() async {
// //     final token= await _storage.read(key: 'accessToken');
// //     if (token == null) {
// //     appLogger.w('⚠️ Access token not found!');
// //     }
// //     return token;
// //   }

// //   static Future<String?> getRefreshToken() async {
// //   return await _storage.read(key: 'refreshToken');
// //   }

// //   static Future<String?> getUserRole() async {
// //     return await _storage.read(key: 'userRole');
// //   }

// //   static Future<void> clearTokens() async {
// //     appLogger.i("🧹 Clearing all secure storage...");
// //   await Future.delayed(const Duration(milliseconds: 200));
// //     //await _storage.deleteAll();
// //     await _storage.delete(key: 'accessToken');
// //     await _storage.delete(key: 'refreshToken');
// //     await _storage.delete(key: 'userRole');
// //     appLogger.i("✅ Secure storage cleared.");
// //   }

// //   static Future<void> saveAccessToken(String accessToken) async {
// //     await _storage.write(key: 'accessToken', value: accessToken);
// //   }

// //   //If later you want to remove only tokens and not other data like settings/preferences:
// //   static Future<void> removeTokens() async {
// //   await _storage.delete(key: 'accessToken');
// //   await _storage.delete(key: 'refreshToken');
// //   }


// //   /// 🔍 Check if token is expired or will expire in next [bufferSeconds]
// //   static Future<bool> isTokenExpiredOrExpiring({int bufferSeconds = 60}) async {
// //     final token = await getAccessToken();
// //     if (token == null) return true;

// //     return JwtDecoder.isExpired(token) ||
// //         JwtDecoder.getRemainingTime(token).inSeconds <= bufferSeconds;
// //   }

//   // 🔄  method for use inside the Dio interceptor
//   // ✅ Critical Improvement — Handle 401 in refreshAccessToken() i.e. 🔄 Refresh access token proactively
//   // If the refresh request fails with a 401, it's not explicitly handled, so your interceptor will keep trying or behave unexpectedly.
//   // static Future<String?> refreshAccessToken() async {
//   // final refreshToken = await getRefreshToken();
//   // if (refreshToken == null) return null;

//   // try {
//   //     final dio = DioClient().client;
//   //       final response = await dio.post(
//   //         '/views/token/refresh/',
    
//   //   // final response = await Dio().post(
//   //   //   'http://127.0.0.1:8000/views/token/refresh/',
//   //     data: {'refresh': refreshToken},
//   //     options: Options(headers: {'Content-Type': 'application/json'}),
//   //   );

//   //   if (response.statusCode == 401) {
//   //     appLogger.w('🚫 Refresh token is invalid or expired (401)');
//   //     return null;
//   //   }

//   //   if (response.data == null || !response.data.containsKey('access')) {
//   //     appLogger.e("❌ No 'access' token in refresh response");
//   //     return null;
//   //   }

//   //   final newAccessToken = response.data['access'];
//   //   await saveAccessToken(newAccessToken);
//   //   appLogger.i('🔁 Access token refreshed successfully');
//   //   return newAccessToken;

//   // } on DioException catch (e) {
//   //   if (e.response?.statusCode == 401) {
//   //     appLogger.w('🚫 Refresh token rejected with 401');
//   //     return null;
//   //   }
//   //   appLogger.e("🔥 Dio error during token refresh: $e");
//   //   return null;

//   // } catch (e) {
//   //   appLogger.e("🔥 Unexpected error refreshing token: $e");
//   //   return null;
//   // }
//   // }

//   static String? _pendingRefreshToken;
//   static final _refreshLock = Lock();

//   static Future<String?> refreshAccessToken() async {
//     return await _refreshLock.synchronized(() async {
//       if (_pendingRefreshToken != null) {
//         return _pendingRefreshToken;
//       }

//       final refreshToken = await getRefreshToken();
//       if (refreshToken == null) {
//         appLogger.w('🚫 No refresh token available.');
//         return null;
//       }

//       try {
//         final dio = DioClient().client;
//         final response = await dio.post(
//           '/views/token/refresh/',
//           data: {'refresh': refreshToken},
//           options: Options(headers: {'Content-Type': 'application/json'}),
//         );

//         if (response.statusCode == 401) {
//           appLogger.w('🚫 Refresh token is invalid or expired (401)');
//           return null;
//         }

//         if (response.data == null || !response.data.containsKey('access')) {
//           appLogger.e("❌ No 'access' token in refresh response");
//           return null;
//         }

//         final newAccessToken = response.data['access'];
//         await saveAccessToken(newAccessToken);
//         _pendingRefreshToken = newAccessToken;

//         // clear token after short cooldown (prevents unnecessary rapid refreshes)
//         Future.delayed(const Duration(seconds: 1), () {
//           _pendingRefreshToken = null;
//         });

//         appLogger.i('🔁 Access token refreshed successfully');
//         return newAccessToken;
//       } on DioException catch (e) {
//         if (e.response?.statusCode == 401) {
//           appLogger.w('🚫 Refresh token rejected with 401');
//         }
//         appLogger.e("🔥 Dio error during token refresh: $e");
//         _pendingRefreshToken = null;
//         return null;
//       } catch (e) {
//         appLogger.e("🔥 Unexpected error refreshing token: $e");
//         _pendingRefreshToken = null;
//         return null;
//       }
//     });
//   }


// }
