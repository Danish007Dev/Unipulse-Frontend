import 'package:flutter/material.dart';

import '../main.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _logout(BuildContext context) async {
    //await TokenManager.clearTokens(); // Clear saved tokens
    // Only trigger logout from the global auth provider
    globalAuthProvider.logout();
    // Navigate to role selection screen and remove all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () => _logout(context),
      tooltip: 'Logout',
    );
  }
}


