import 'package:flutter/material.dart';
import 'package:flutter_app/feedUpApp/services/google_auth_service.dart';

class FeedUpSignInScreen extends StatefulWidget {
  const FeedUpSignInScreen({super.key});

  @override
  State<FeedUpSignInScreen> createState() => _FeedUpSignInScreenState();
}

class _FeedUpSignInScreenState extends State<FeedUpSignInScreen> {
  bool _loading = false;
  String? _error;

  void _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await GoogleAuthService.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      // Notify previous screen of success
      Navigator.pop(context, true);
    } else {
      setState(() {
        _error = "Login failed. Please try again.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FeedUp Login")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sign in to access FeedUp"),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text("Sign in with Google"),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                ],
              ),
      ),
    );
  }
}