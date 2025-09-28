// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:dio/dio.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../../services/dio_client.dart';
// import '../../../utils/logger.dart';

// class GoogleAuthService {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'profile'],
//   );

//   static final _storage = const FlutterSecureStorage();
//   static final Dio _dio = DioClient().client;

//   static Future<bool> signInWithGoogle() async {
//     try {
//       final account = await _googleSignIn.signIn();
//       if (account == null) return false;

//       final auth = await account.authentication;
//       final idToken = auth.idToken;
//       if (idToken == null) return false;

//       final response = await _dio.post(
//         '/api/feedup/google-login/',
//         data: {'id_token': idToken},
//       );

//       final accessToken = response.data['access'];
//       final refreshToken = response.data['refresh'];

//       await _storage.write(key: 'feedup_access_token', value: accessToken);
//       await _storage.write(key: 'feedup_refresh_token', value: refreshToken);
//       appLogger.i("✅ Google sign-in success for: ${response.data['user']['email']}");
//       return true;
//     } catch (e) {
//       appLogger.e("❌ Google sign-in failed: $e");
//       return false;
//     }
//   }

//   static Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _storage.delete(key: 'feedup_access_token');
//     await _storage.delete(key: 'feedup_refresh_token');
//   }

//   static Future<String?> getAccessToken() async {
//     return await _storage.read(key: 'feedup_access_token');
//   }

//   static GoogleSignInAccount? getCurrentUser() {
//     return _googleSignIn.currentUser;
//   }
// }
