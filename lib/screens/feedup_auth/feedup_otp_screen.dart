import 'package:flutter/material.dart';
import '../../services/feedup_auth_service.dart'; // Import the service
import 'feedup_password_screen.dart';

class FeedUpOtpScreen extends StatefulWidget {
  final String email;
  const FeedUpOtpScreen({super.key, required this.email});

  @override
  State<FeedUpOtpScreen> createState() => _FeedUpOtpScreenState();
}

class _FeedUpOtpScreenState extends State<FeedUpOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Use the actual service now
    final result = await FeedUpAuthService().verifyOtp(widget.email, _otpController.text);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      if (result['is_new_user'] == true) {
        // New user needs to set a password
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => FeedUpPasswordScreen(
              email: widget.email,
              verificationToken: result['verification_token'],
            ),
          ),
          (route) => route.isFirst, // Remove all previous screens in this flow
        );
      } else {
        // This case should ideally not be hit, but if it is, guide the user.
        Navigator.of(context).popUntil(ModalRoute.withName('/role-selection'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This account already exists. Please log in with your password.')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter the code sent to ${widget.email}'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Verification Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Please enter the 6-digit code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      child: const Text('Verify & Continue'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}