import 'package:flutter/material.dart';
import '../../utils/logger.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.loadSessionIfNeeded();
    } catch (e) {
      appLogger.e("❌ Error during session loading: $e");
      _goToRoleSelection();
      return;
    }

    appLogger.i("🔍 Splash check → isAuthenticated: ${authProvider.isAuthenticated}");

    if (!mounted) {
      appLogger.w("⚠️ Widget is no longer mounted. Aborting navigation.");
      return;
    }

    if (authProvider.isAuthenticated) {
      _navigateToDashboard(authProvider.role);
    } else {
      _goToRoleSelection();
    }
  }

  void _navigateToDashboard(String? role) {
    final routeMap = {
      'student': '/student-dashboard',
      'faculty': '/faculty-dashboard',
      'admin': '/admin-dashboard',
    };

    if (!routeMap.containsKey(role?.toLowerCase())) {
      appLogger.w("⚠️ Unexpected role: $role. Redirecting to role selection.");
    }

    final route = routeMap[role?.toLowerCase()] ?? '/role-selection';
    navigatorKey.currentState?.pushReplacementNamed(route);
  }

  void _goToRoleSelection() {
    navigatorKey.currentState?.pushReplacementNamed('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}




// Got it — you prefer the method `refreshBothTokens()` to **return a `String?` (new access token)** instead of a `bool`, and you'd like to adjust your **Splash screen logic** accordingly.

// Let’s walk through how to do this **cleanly** with `String?` return type instead of `bool`.

// ---

// ### ✅ Updated `TokenManager.refreshBothTokens()` Method (returns `String?`):

// ```dart
// static Future<String?> refreshBothTokens() async {
//   return await _refreshLock.synchronized(() async {
//     if (_isRefreshing) {
//       appLogger.i("⏳ Another refresh is already in progress, waiting...");
//       await Future.delayed(const Duration(milliseconds: 500));
//       return getAccessToken(); // Return latest
//     }

//     final refreshToken = await getRefreshToken();
//     if (refreshToken == null) {
//       appLogger.w('🚫 No refresh token available.');
//       return null;
//     }

//     _isRefreshing = true;

//     try {
//       final dio = DioClient().client;
//       final response = await dio.post(
//         '/views/token/refresh/',
//         data: {'refresh': refreshToken},
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       final newAccessToken = response.data['access'];
//       final newRefreshToken = response.data['refresh'];

//       await saveAccessToken(newAccessToken);
//       if (newRefreshToken != null) {
//         await saveRefreshToken(newRefreshToken);
//       }

//       appLogger.i('🔁 Access and Refresh tokens refreshed');
//       return newAccessToken;
//     } catch (e) {
//       appLogger.e("🔥 Refresh token error: $e");
//       return null;
//     } finally {
//       _isRefreshing = false;
//     }
//   });
// }
// ```

// ---

// ### ✅ Updated `SplashScreen` Logic:

// Here’s how you change the logic to use `String?` instead of `bool`:

// ```dart
// final newAccessToken = await TokenManager.refreshBothTokens();

// if (newAccessToken != null) {
//   final refreshToken = await TokenManager.getRefreshToken();

//   if (refreshToken != null) {
//     await authProvider.login(newAccessToken, refreshToken, role, email!);
//     _navigateToDashboard(role);
//   } else {
//     await authProvider.logout();
//     _goToRoleSelection();
//   }
// } else {
//   await authProvider.logout();
//   _goToRoleSelection();
// }
// ```

// ---

// ### 💡 Summary

// * ✅ Your `refreshBothTokens()` method returns the **new access token as a `String?`**.
// * ✅ If it’s `null`, refresh failed.
// * ✅ If it’s not `null`, you retrieve the updated refresh token and proceed to `authProvider.login(...)`.

// Let me know if you want help **refining `authProvider.login()`** to expect both tokens cleanly.




// import 'package:flutter/material.dart';
// import '../../utils/token_manager.dart';
// import '../../main.dart';
// import '../../utils/logger.dart';
// import 'package:provider/provider.dart';
// import '../services/auth_provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkSession();
//   }

//   Future<void> _checkSession() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.loadSessionIfNeeded();

//     final token = authProvider.token;
//     final role = authProvider.role;
//     final email = authProvider.email;

//     final isExpired = await TokenManager.isTokenExpiredOrExpiring();

//     appLogger.i("🪪 Access Token: $token");
//     appLogger.i("👤 Role: $role");
//     appLogger.i("⏳ Is token expired/expiring: $isExpired");

//     if (!mounted) return;

//     if (token != null && role != null && !isExpired && email != null) {
//       _navigateToDashboard(role);
//     } else if (token != null && role != null && isExpired) {
//       final newToken = await TokenManager.refreshAccessToken();

//       if (!mounted) return;

//       if (newToken != null) {
//         // ✅ Refresh token successfully, now update provider properly
//         await authProvider.login(newToken, role, email!);
//         authProvider.loadSessionIfNeeded(); // will reload state internally
//         _navigateToDashboard(role);
//       } else {
//         await authProvider.logout();
//         _goToRoleSelection();
//       }
//     } else {
//       _goToRoleSelection();
//     }
//   }

//   void _navigateToDashboard(String? role) {
//     final normalizedRole = role?.toLowerCase();

//     switch (normalizedRole) {
//       case 'student':
//         navigatorKey.currentState?.pushReplacementNamed('/student-dashboard');
//         break;
//       case 'faculty':
//         navigatorKey.currentState?.pushReplacementNamed('/faculty-dashboard');
//         break;
//       case 'admin':
//         navigatorKey.currentState?.pushReplacementNamed('/admin-dashboard');
//         break;
//       default:
//         _goToRoleSelection();
//     }
//   }

//   void _goToRoleSelection() {
//     navigatorKey.currentState?.pushReplacementNamed('/role-selection');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }



// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkSession();
//   }


//   Future<void> _checkSession() async {
//   final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   await authProvider.loadSessionIfNeeded(); // Ensures _token and user_type are loaded

//   final token = authProvider.token;
//   final role = authProvider.role;
//   final isExpired = await TokenManager.isTokenExpiredOrExpiring();

//   appLogger.i("🪪 Access Token: $token");
//   appLogger.i("👤 Role: $role");
//   appLogger.i("⏳ Is token expired/expiring: $isExpired");

//   if (!mounted) return;

//   if (token != null && role != null && !isExpired) {
//     _navigateToDashboard(role);
//   } else if (token != null && role != null && isExpired) {
//     final newToken = await TokenManager.refreshAccessToken();

//     if (!mounted) return;

//     if (newToken != null) {
//       authProvider.login(newToken, role); // ✅ Update provider after refresh
//       _navigateToDashboard(role);
//     } else {
//       await TokenManager.clearTokens();
//       authProvider.logout();
//       _goToRoleSelection();
//     }
//   } else {
//     _goToRoleSelection();
//   }
// }



//   void _navigateToDashboard(String? role) {
//     final normalizedRole = role?.toLowerCase();

//     switch (normalizedRole) {
//       case 'student':
//         navigatorKey.currentState?.pushReplacementNamed('/student-dashboard');
//         break;
//       case 'faculty':
//         navigatorKey.currentState?.pushReplacementNamed('/faculty-dashboard');
//         break;
//       case 'admin':
//         navigatorKey.currentState?.pushReplacementNamed('/admin-dashboard');
//         break;
//       default:
//         _goToRoleSelection();
//     }
//   }

  

// void _goToRoleSelection() {
//   navigatorKey.currentState?.pushReplacementNamed('/role-selection');
// }


//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../../utils/session_manager.dart';
// import 'role_selection.dart';
// import 'student_dashboard/stu_dashboard.dart';
// import 'faculty_dashboard/fac_dashboard.dart';
// import 'admin_dashboard/admin_dashboard.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _handleStartup();
//   }

//   Future<void> _handleStartup() async {
//     final role = await SessionManager.validateAndRefreshTokens();

//     if (!mounted) return;

//     switch (role) {
//       case 'student':
//         _goTo(const StudentDashboardScreen());
//         break;
//       case 'faculty':
//         _goTo(const FacultyDashboardScreen());
//         break;
//       case 'admin':
//         _goTo(const AdminDashboardScreen());
//         break;
//       default:
//         _goTo( RoleSelectionScreen());
//     }
//   }

//   void _goTo(Widget screen) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => screen),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }




// 11/5/25 Refactoring SplashScreen to Use SessionManager
// Outcome
// Token refresh logic is centralized and cleaner.

// SplashScreen now just decides navigation, not token logic.

// This paves the way for background refresh or other logic later.



// import 'package:flutter/material.dart';
// import '../../utils/token_manager.dart';
// import 'role_selection.dart';
// import 'student_dashboard/stu_dashboard.dart';
// import 'faculty_dashboard/fac_dashboard.dart';
// import 'admin_dashboard/admin_dashboard.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   void _navigateToRoleSelection() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) =>  RoleSelectionScreen()),
//     );
//   }


//   Future<void> _checkLoginStatus() async {
//     try {
//     final accessToken = await TokenManager.getAccessToken();
//     final role = await TokenManager.getUserRole(); // 🔐 No token or role? Go to role selection
//     if (accessToken == null || role == null) {
//       await TokenManager.clearTokens();
//       _navigateToRoleSelection();
//       return;
//     }
    
//     // 🔄 Attempt to refresh token in case it's expired
//     final newAccessToken = await TokenManager.refreshAccessToken();

    
//     // ❌ If refresh fails, treat as logged out
//     if (newAccessToken == null) {
//       await TokenManager.clearTokens();
//       _navigateToRoleSelection();
//       return;
//     }
   






//       switch (role) {
//         case 'student':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
//           );
//           break;
//         case 'faculty':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const FacultyDashboardScreen()),
//           );
//           break;
//         case 'admin':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
//           );
//           break;
//         default:
//          _navigateToRoleSelection();
          
//       }
//     } catch (e) {
//     // 🔥 Any unexpected error, treat as logged out
//     await TokenManager.clearTokens();
//     _navigateToRoleSelection();
//   }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import '../../utils/token_manager.dart';
// import 'role_selection.dart';
// import 'student_dashboard/stu_dashboard.dart';
// import 'faculty_dashboard/fac_dashboard.dart';
// import 'admin_dashboard/admin_dashboard.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final accessToken = await TokenManager.getAccessToken();
//     final role = await TokenManager.getUserRole();
    

//     if (accessToken != null && role != null) {
//       switch (role) {
//         case 'student':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
//           );
//           break;
//         case 'faculty':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const FacultyDashboardScreen()),
//           );
//           break;
//         case 'admin':
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
//           );
//           break;
//         default:
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
//           );
//       }
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => RoleSelectionScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
