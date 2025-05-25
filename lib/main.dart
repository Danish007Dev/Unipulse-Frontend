import 'package:flutter/material.dart';
import 'package:flutter_app/utils/logger.dart';
import 'package:provider/provider.dart';

import 'screens/role_selection.dart';
import 'screens/student_dashboard/stu_dashboard.dart';
import 'screens/faculty_dashboard/fac_dashboard.dart';
import 'screens/admin_dashboard/admin_dashboard.dart';
import 'screens/student_dashboard/stu_dashboard_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/student_dashboard/stu_saved_posts_screen.dart';
import 'services/auth_provider.dart';
import 'screens/faculty_dashboard/fac_dashboard_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


late final AuthProvider globalAuthProvider;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Ensure Flutter is ready for async operations
   WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  // // Load the correct .env file
  // await dotenv.load(fileName: '.env.$env');
  
  try {
    await dotenv.load(fileName: '.env.$env');
    appLogger.i('🌍 Loaded .env.$env');
  } catch (e) {
    appLogger.e('⚠️ Could not load .env.$env: $e');
  }

  appLogger.i('ENV BASE_URL: ${dotenv.env['API_BASE_URL']}');


  final authProvider = AuthProvider();
  await authProvider.loadStoredTokens(); // ✅ Load tokens before app starts
  globalAuthProvider = authProvider;




  runApp(
    MultiProvider(
      providers: [
        //ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: authProvider), // ✅ reuse same instance
        ChangeNotifierProvider(create: (_) => FacultyDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
      ],
      child: const MyApp(), // ✅ <--- THIS is the correct child!
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'UniPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
        '/faculty-dashboard': (context) => const FacultyDashboardScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/role-selection': (context) => RoleSelectionScreen(),
        '/saved-posts': (context) => const SavedPostsScreen(), // Optional: use named route
      },
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'screens/role_selection.dart';
// import 'screens/student_dashboard/stu_dashboard.dart';
// import 'screens/faculty_dashboard/fac_dashboard.dart';
// import 'screens/admin_dashboard/admin_dashboard.dart';
// //import 'utils/toast_util.dart';
// import 'screens/splash_screen.dart'; // ⬅️ import
// import 'providers/auth_provider.dart';
// import 'screens/faculty_dashboard/fac_dashboard_provider.dart'; // Ensure this is imported
// //import 'services/dio_client.dart';
// late final AuthProvider globalAuthProvider;
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   final authProvider = AuthProvider();
//   globalAuthProvider = authProvider;

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => FacultyDashboardProvider()), // ✅ Add this
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'UniPulse',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),

//       initialRoute: '/',
//       routes: {
//         '/': (context) => const SplashScreen(), // ⬅️ Now Splash first
//         '/student-dashboard': (context) => const StudentDashboardScreen(),
//         '/faculty-dashboard': (context) => const FacultyDashboardScreen(),
//         '/admin-dashboard': (context) => const AdminDashboardScreen(),
//         '/role-selection': (context) => RoleSelectionScreen(),
//       },
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'screens/role_selection.dart';
// import 'screens/student_dashboard/student_dashboard.dart';
// import 'screens/faculty_dashboard/faculty_dashboard.dart';
// import 'screens/admin_dashboard.dart';
// import 'providers/auth_provider.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => AuthProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'UniPulse',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),

//       // Use only initialRoute and routes
//       initialRoute: '/',
//       routes: {
//         '/': (context) => RoleSelectionScreen(),
//         '/student-dashboard': (context) => const StudentDashboardScreen(),
//         '/faculty-dashboard': (context) => const FacultyDashboardScreen(),
//         '/admin-dashboard': (context) => const AdminDashboardScreen(),
//       },
//     );
//   }
// }
