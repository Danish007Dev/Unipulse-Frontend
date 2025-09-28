import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart'; // For Google Sign-In
import 'login_screen.dart';
import 'feedup_auth/feedup_email_screen.dart'; 

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to UniPulse'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Section for AMU Members ---
            _buildSectionCard(
              context,
              title: 'For AMU Students & Faculty',
              children: [
                _buildRoleButton(
                  context,
                  'Login as Student',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(user_type: 'student'))),
                ),
                const SizedBox(height: 12),
                _buildRoleButton(
                  context,
                  'Login as Faculty',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen(user_type: 'faculty'))),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // --- Section for Public FeedUp Users ---
            _buildSectionCard(
              context,
              title: 'For Public FeedUp Access',
              children: [
                _buildGoogleSignInButton(context, authProvider),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Continue with Email'),
                  onPressed: () {
                    // Navigate to the new FeedUp email login screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedUpEmailLoginScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, AuthProvider authProvider) {
    return ElevatedButton.icon(
      icon: Image.asset('assets/images/google_logo.png', height: 24.0), // Make sure you have this asset
      label: const Text('Sign in with Google'),
      onPressed: () async {
        // final success = await authProvider.signInWithGoogle();
        // if (success && context.mounted) {
        //   Navigator.of(context).popUntil(ModalRoute.withName('/app'));
        // } else if (context.mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Google Sign-In Failed. Please try again.')),
        //   );
        // }
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In coming soon!')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}
