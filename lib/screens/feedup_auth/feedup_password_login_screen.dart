import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/feedup_auth_service.dart';
import '../../FeedUpApp/auth/feedup_auth_provider.dart';
import '../../services/auth_provider.dart'; // Import the main AuthProvider


class FeedUpPasswordLoginScreen extends StatefulWidget {
  final String email;
  const FeedUpPasswordLoginScreen({super.key, required this.email});

  @override
  State<FeedUpPasswordLoginScreen> createState() => _FeedUpPasswordLoginScreenState();
}

class _FeedUpPasswordLoginScreenState extends State<FeedUpPasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

    Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await FeedUpAuthService().loginWithPassword(
      email: widget.email,
      password: _passwordController.text,
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
      Provider.of<FeedUpAuthProvider>(context, listen: false).loginAsFeedUpUser(context, widget.email);

      Navigator.of(context).pushNamedAndRemoveUntil('/app', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome back! Enter the password for ${widget.email}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}