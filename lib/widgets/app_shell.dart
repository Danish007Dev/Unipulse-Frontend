import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../screens/student_dashboard/stu_dashboard.dart';
import '../screens/faculty_dashboard/fac_dashboard.dart';
import '../screens/faculty_dashboard/create_fac_post_modal.dart';
import '../FeedUpApp/screens/feed_main_screen.dart';
import '../FeedUpApp/screens/bookmarks_screen.dart';
import 'login_prompt_widget.dart';
import 'profile_screen.dart';
import 'package:flutter_app/FeedUpApp/auth/feedup_auth_provider.dart';
import '../askAI/screens/ask_ai_landing_screen.dart'; 
import '../screens/role_selection.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final feedUpAuthProvider = context.watch<FeedUpAuthProvider>();

    // Consolidate authentication check
    final bool isUniPulseUser = authProvider.isAuthenticated && (authProvider.role == 'student' || authProvider.role == 'faculty');
    final bool isAuthenticated = authProvider.isAuthenticated || feedUpAuthProvider.isFeedUpUserAuthenticated;

    // Build pages directly in the build method for clarity
    final List<Widget> pages = [
      const FeedUpScreen(),
      if (isUniPulseUser)
        authProvider.role == 'student'
            ? const StudentDashboardScreen()
            : const FacultyDashboardScreen(),
      isAuthenticated
          ? const BookmarksScreen()
          : const LoginPromptWidget(message: 'Log in to view and manage your bookmarks.'),
      isAuthenticated
          ? const AskAiLandingScreen()
          : const LoginPromptWidget(message: 'Log in to use the AI Assistant.'),
    ];

    final List<String> titles = [
      'FeedUp',
      if (isUniPulseUser) 'Dashboard',
      'Bookmarks',
      'Ask AI', 
    ];

    // This check is important for when logout happens and tabs disappear
    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          // Show profile icon for ALL users
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (isAuthenticated) {
                // If logged in, go to profile
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else {
                // If not logged in, go to the role selection/login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: authProvider.isAuthenticated &&
              isUniPulseUser &&
              _selectedIndex == 1 && // Dashboard tab
              authProvider.role == 'faculty'
          ? FloatingActionButton(
              onPressed: () => _openCreatePostModal(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'FeedUp',
          ),
          if (isUniPulseUser)
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Bookmarks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined), // 🔵 Update icon for AI
            label: 'Ask AI', // 🔵 Update label for AI
          ),
        ],
      ),
    );
  }

  void _openCreatePostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateFacPostModal(),
    );
  }
}