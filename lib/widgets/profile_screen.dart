import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../FeedUpApp/auth/feedup_auth_provider.dart';
import '../widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to both providers
    final amuAuthProvider = context.watch<AuthProvider>();
    final feedUpAuthProvider = context.watch<FeedUpAuthProvider>();

    final bool isAmuUser = amuAuthProvider.isAuthenticated;
    final bool isFeedUpUser = feedUpAuthProvider.isFeedUpUserAuthenticated;
    
    String email = isAmuUser ? amuAuthProvider.email ?? 'AMU User' : feedUpAuthProvider.feedUpUserEmail?? 'FeedUp User';
    String userType = isAmuUser ? amuAuthProvider.role ?? 'AMU' : 'FeedUp';

    // This function will handle both logout and navigation
    void handleLogout(BuildContext context, {bool isAmu = false}) {
      // Use the correct provider to log out
      if (isAmu) {
        context.read<AuthProvider>().logout();
      } else {
        context.read<FeedUpAuthProvider>().logout();
      }
      
      // After logging out, just pop the profile screen. The AppShell will rebuild automatically.
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: const Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                email,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Chip(label: Text('Role: ${userType.toUpperCase()}')),
              const SizedBox(height: 40),
              // This logic now works perfectly because only one state can be true.
              if (isAmuUser)
                LogoutButton(
                  onLogout: () => handleLogout(context, isAmu: true),
                )
              else if (isFeedUpUser)
                LogoutButton(
                  onLogout: () => handleLogout(context, isAmu: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}