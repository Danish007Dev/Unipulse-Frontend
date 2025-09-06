import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
// This file will now manage FeedUp-only authentication state.
// We will add email/password logic here later if needed.

class FeedUpAuthProvider extends ChangeNotifier {
  // We can add properties for email/pass users if we expand this.
  bool _isFeedUpUserAuthenticated = false;
  String? _feedUpUserEmail;


  bool get isFeedUpUserAuthenticated => _isFeedUpUserAuthenticated;
  String? get feedUpUserEmail => _feedUpUserEmail;

  // Example method for a FeedUp-only login
  void loginAsFeedUpUser(BuildContext context, String email) {
    // 1. Silently clear the AMU auth state to prevent conflicts.
    context.read<AuthProvider>().clearState();

    // 2. Set the FeedUp user state.
    _isFeedUpUserAuthenticated = true;
    _feedUpUserEmail = email;
    notifyListeners();
  }

  void logout() {
    // This logout is specific to FeedUp-only users.
    // It does NOT clear UniPulse tokens.

    _isFeedUpUserAuthenticated = false;
    _feedUpUserEmail = null;
    // Potentially clear FeedUp-specific tokens if you store them separately.
    notifyListeners();
  }
  
}
