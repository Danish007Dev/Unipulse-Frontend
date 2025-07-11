import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/auth_provider.dart';
import '../../utils/logger.dart';
import '../services/dio_client.dart';
import '../widgets/create_feedup_password_dialog.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String userType;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.userType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) return;

    setState(() => isVerifying = true);

    final tokenData = await AuthService.verifyOTP(
      email: widget.email,
      otp: otp,
      userType: widget.userType,
    );

    if (!mounted) return;

    setState(() => isVerifying = false);

    if (tokenData != null) {
      final accessToken = tokenData['accessToken'];
      final refreshToken = tokenData['refreshToken'];

      appLogger.i("Received accessToken: $accessToken");
      appLogger.i("Received refreshToken: $refreshToken");
      final userType = tokenData['user_type'];
      final email = tokenData['email'];

      appLogger.i("✅ tokenData from AuthService.verifyOTP():");
      appLogger.i("🔐 accessToken: $accessToken");
      appLogger.i("🔁 refreshToken: $refreshToken");
      appLogger.i("👤 userType: $userType");
      appLogger.i("📧 email: $email");

      if (accessToken != null &&
          refreshToken != null &&
          userType != null &&
          email != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(accessToken, refreshToken, userType, email);

        // --- 🚀 Trigger SSO and Check for Password Requirement ---
        bool requiresPasswordSetup = false;
        try {
          final response = await DioClient().client.post('/feedup/auth/sync-unipulse-user/');
          if (response.data['requires_password_setup'] == true) {
            requiresPasswordSetup = true;
          }
          appLogger.i("✅ Successfully synced user with FeedUp backend.");
        } catch (e) {
          appLogger.e("⚠️ Failed to sync user with FeedUp backend: $e");
        }
        // --- End SSO Trigger ---

        if (mounted) {
          // ❌ INCORRECT: This assumes /app is on the stack.
          // Navigator.of(context).popUntil(ModalRoute.withName('/app'));

          // ✅ CORRECT: This removes all previous screens and makes /app the new root.
          Navigator.of(context).pushNamedAndRemoveUntil('/app', (route) => false);

          // If a password is required, show the creation screen as a dialog
          if (requiresPasswordSetup) {
            showDialog(
              context: context,
              barrierDismissible: false, // User must interact with the dialog
              builder: (_) => const CreateFeedUpPasswordDialog(),
            );
          }
        }
      } else {
        appLogger.e("❌ One or more token fields were null. Aborting login.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Incomplete token data.')),
        );
      }
    } 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerifying ? null : verifyOTP,
              child: isVerifying
                  ? const CircularProgressIndicator()
                  : const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}



// pushReplacementNamed | pushNamedAndRemoveUntil
// Replaces current screen only (OTP) | Removes all previous screens (OTP + Login + RoleSelect)
// Can still go back if LoginScreen was before OTP | Cannot go back at all, fresh dashboard entry ✅