import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/feedup_auth_service.dart';
import '../../FeedUpApp/auth/feedup_auth_provider.dart'; // 👈 Import the FeedUp provider
import '../../services/auth_provider.dart'; // Import the main AuthProvider

class FeedUpPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationToken;

  const FeedUpPasswordScreen({
    super.key,
    required this.email,
    required this.verificationToken,
  });

  @override
  State<FeedUpPasswordScreen> createState() => _FeedUpPasswordScreenState();
}

class _FeedUpPasswordScreenState extends State<FeedUpPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await FeedUpAuthService().registerWithPassword(
      email: widget.email,
      password: _passwordController.text,
      token: widget.verificationToken,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      final accessToken = result['access'] as String;
      final refreshToken = result['refresh'] as String;

      // ✅ FIX: Update the main AuthProvider. This is the single source of truth.
      await Provider.of<AuthProvider>(context, listen: false).login(
        accessToken,
        refreshToken,
        'feedup_user', // The user's role
        widget.email,
      );

      // This call is now redundant but harmless. Can be removed later.
      Provider.of<FeedUpAuthProvider>(context, listen: false).loginAsFeedUpUser(context,widget.email);

      Navigator.of(context).pushNamedAndRemoveUntil('/app', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
  
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Create a password for your account: ${widget.email}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerUser,
                      child: const Text('Complete Registration'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}