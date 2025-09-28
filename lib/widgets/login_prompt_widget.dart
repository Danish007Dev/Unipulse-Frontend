import 'package:flutter/material.dart';

class LoginPromptWidget extends StatelessWidget {
  final String message;

  const LoginPromptWidget({
    super.key,
    this.message = 'You need to be logged in to see this page.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Login Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to the role selection screen to start the login flow
                Navigator.of(context).pushNamed('/role-selection');
              },
              child: const Text('Login / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}