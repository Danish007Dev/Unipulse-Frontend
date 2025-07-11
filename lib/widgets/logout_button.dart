import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      onPressed: () {
        // Schedule the logout to occur after the current build frame.
        // This prevents the "setState() or markNeedsBuild() called during build" error.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onLogout();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}


