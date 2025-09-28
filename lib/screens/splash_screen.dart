import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../../main.dart';
import '../../utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Attempt to load any existing session from storage
    try {
      await authProvider.loadSessionIfNeeded();
      appLogger.i("✅ Session loaded successfully from splash screen.");
    } catch (e) {
      appLogger.e("❌ Error loading session from splash screen: $e. Continuing as logged out.");
    }

    // After initialization, always navigate to the AppShell.
    // The AppShell will then decide what to show based on the auth state.
    if (mounted) {
      navigatorKey.currentState?.pushReplacementNamed('/app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initializing UniPulse...'),
          ],
        ),
      ),
    );
  }
}
