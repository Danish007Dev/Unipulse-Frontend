import 'package:flutter/material.dart';
import 'package:flutter_app/feedUpApp/services/google_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthProvider with ChangeNotifier {
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;
  bool get isLoggedIn => _user != null;

  String? get name => _user?.displayName;
  String? get email => _user?.email;
  String? get photoUrl => _user?.photoUrl;

  Future<void> checkAuthStatus() async {
    _user = await GoogleAuthService.getCurrentUser();
    notifyListeners();
  }

  Future<void> login() async {
    final success = await GoogleAuthService.signInWithGoogle();
    if (success) {
      _user = await GoogleAuthService.getCurrentUser();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await GoogleAuthService.signOut();
    _user = null;
    notifyListeners();
  }
}