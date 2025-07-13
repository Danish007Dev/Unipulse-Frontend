import 'package:flutter/material.dart';
import 'package:flutter_app/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'FeedUpApp/models/article.dart';
import 'screens/student_dashboard/stu_dashboard_provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_provider.dart';
import 'screens/faculty_dashboard/fac_dashboard_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'FeedUpApp/auth/feedup_auth_provider.dart';
import 'widgets/app_shell.dart';
import 'FeedUpApp/providers/bookmark_provider.dart';
import '../screens/role_selection.dart';
import 'widgets/auth_state_listener.dart';
import 'FeedUpApp/providers/feed_provider.dart';
import 'package:dio/dio.dart';
import 'services/dio_client.dart';
import 'askAI/models/ai_response_bookmark.dart'; 
import 'askAI/providers/ai_bookmark_provider.dart'; 
import 'askAI/models/chat_model.dart';
import 'askAI/models/chat_history_session.dart';

late final AuthProvider globalAuthProvider;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Ensure Flutter is ready for async operations
   WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Hive ---
  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(AiResponseBookmarkAdapter());
  Hive.registerAdapter(ChatMessageTypeAdapter()); // Add this
  Hive.registerAdapter(ChatMessageAdapter());     // Add this
  Hive.registerAdapter(ChatHistorySessionAdapter());// Add this
  await Hive.openBox<Article>('bookmarks');
  await Hive.openBox<AiResponseBookmark>('ai_bookmarks'); // Open the new box
  await Hive.openBox<ChatHistorySession>('chat_history'); // Open the new box
  // --- End Hive Initialization ---

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


  // ✅ Create your AuthProvider ONCE
  final authProvider = AuthProvider();
  await authProvider.loadStoredTokens(); // ✅ Load tokens before app starts
  globalAuthProvider = authProvider;


  runApp(
    MultiProvider(
      providers: [
        // ✅ Provide the single instance of AuthProvider you already created
        ChangeNotifierProvider.value(value: authProvider),

        // ✅ Provide the singleton Dio instance from our robust DioClient
        Provider<Dio>.value(value: DioClient().dio),
        
        // ✅ Keep all your other existing providers
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => FeedUpAuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => FacultyDashboardProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => AiBookmarkProvider()), 
      ],
      // ✅ Wrap the app with our new listener
      child: AuthStateListener(child: const MyApp()),
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
        '/app': (context) => const AppShell(), // The main app experience
        '/role-selection': (context) => RoleSelectionScreen(),
        // Other routes like login/otp can be pushed as needed
      },
    );
  }
}
