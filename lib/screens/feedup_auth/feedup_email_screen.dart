import 'package:flutter/material.dart';
import '../../services/feedup_auth_service.dart';
import 'feedup_otp_screen.dart';
import 'feedup_password_login_screen.dart'; // 👈 Import this

class FeedUpEmailLoginScreen extends StatefulWidget {
  const FeedUpEmailLoginScreen({super.key});

  @override
  State<FeedUpEmailLoginScreen> createState() => _FeedUpEmailLoginScreenState();
}

class _FeedUpEmailLoginScreenState extends State<FeedUpEmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final email = _emailController.text;
    final userExists = await FeedUpAuthService().checkUserExists(email);

    setState(() => _isLoading = false);

    if (userExists == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
      return;
    }

    if (userExists) {
      // User exists, go directly to password screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedUpPasswordLoginScreen(email: email),
        ),
      );
    } else {
      // New user, proceed with OTP flow
      _sendOtp(email);
    }
  }

  Future<void> _sendOtp(String email) async {
    setState(() => _isLoading = true);
    final success = await FeedUpAuthService().sendOtp(email);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FeedUpOtpScreen(email: email),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send verification code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Continue with Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleContinue, // 👈 Use the new handler
                      child: const Text('Continue'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}