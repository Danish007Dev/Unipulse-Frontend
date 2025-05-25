import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/auth_provider.dart';
import '../../utils/logger.dart';

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

        final routeMap = {
          'student': '/student-dashboard',
          'faculty': '/faculty-dashboard',
          'admin': '/admin-dashboard',
        };
        final route = routeMap[userType.toLowerCase()];
        if (route != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown user type')),
          );
        }
      } else {
        appLogger.e("❌ One or more token fields were null. Aborting login.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Incomplete token data.')),
        );
      }
    } 
  }



    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //   await authProvider.login(accessToken!,refreshToken!, widget.userType, widget.email);

    //   final routeMap = {
    //     'student': '/student-dashboard',
    //     'faculty': '/faculty-dashboard',
    //     'admin': '/admin-dashboard',
    //   };
    //   final route = routeMap[widget.userType.toLowerCase()];
    //   if (route != null) {
    //     Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Unknown user type')),
    //     );
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Invalid OTP, try again')),
    //   );
    // }
  

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




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_service.dart';
// import '../services/auth_provider.dart';
// // import '../../utils/token_manager.dart';
// import '../../utils/logger.dart';



// class OTPVerificationScreen extends StatefulWidget {
//   final String email;
//   final String user_type;

//   const OTPVerificationScreen({super.key, required this.email, required this.user_type});

//   @override
//   OTPVerificationScreenState createState() => OTPVerificationScreenState();
// }

// class OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final TextEditingController otpController = TextEditingController();

//   void verifyOTP() async {
//     String otp = otpController.text.trim();

//     // Call API to verify OTP and get token
//     final tokenData = await AuthService.verifyOTP(
//       email: widget.email,
//       otp: otp,
//       userType: widget.user_type,
// );

//     if (!mounted) return;

//     if (tokenData != null) {
//       final accessToken = tokenData['accessToken'];
//       final refreshToken = tokenData['refreshToken'];
//       appLogger.i("Received accessToken: $accessToken");
//       appLogger.i("Received refreshToken: $refreshToken");

//       // ✅ Pass both `token` and `role` to `AuthProvider.login()`
//       Provider.of<AuthProvider>(context, listen: false).login(accessToken!, widget.user_type, widget.email);
  


//       // ✅ Map user types to routes
//       final routeMap = {
//         "student": "/student-dashboard",
//         "faculty": "/faculty-dashboard",
//         "admin": "/admin-dashboard",
//     };

//     final route = routeMap[widget.user_type];
//     if (route != null) {
//       Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Unknown user type')),
//       );
//     }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid OTP, try again')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Enter OTP')),
//       body: Column(
//         children: [
//           TextField(controller: otpController, decoration: const InputDecoration(labelText: 'OTP')),
//           ElevatedButton(onPressed: verifyOTP, child: const Text('Verify OTP')),
//         ],
//       ),
//     );
//   }
// }



// pushReplacementNamed | pushNamedAndRemoveUntil
// Replaces current screen only (OTP) | Removes all previous screens (OTP + Login + RoleSelect)
// Can still go back if LoginScreen was before OTP | Cannot go back at all, fresh dashboard entry ✅