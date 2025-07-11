import 'package:flutter/material.dart';
import 'package:flutter_app/utils/logger.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../FeedUpApp/auth/feedup_auth_provider.dart';
import '../FeedUpApp/providers/bookmark_provider.dart';

/// A widget that listens to authentication state changes and triggers
/// corresponding data loading or clearing operations.
/// This should be placed high in the widget tree, e.g., wrapping MaterialApp.
class AuthStateListener extends StatefulWidget {
  final Widget child;
  const AuthStateListener({super.key, required this.child});

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  bool? _wasAuthenticated;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final uniPulseAuth = context.watch<AuthProvider>();
    final feedUpAuth = context.watch<FeedUpAuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    final isAuthenticated = uniPulseAuth.isAuthenticated || feedUpAuth.isFeedUpUserAuthenticated;

    // Initialize the first state
    _wasAuthenticated ??= isAuthenticated;

    // Check if the authentication state has actually changed
    if (isAuthenticated != _wasAuthenticated) {
      // Schedule the side-effect for after the build is complete.
      // This prevents the "setState() or markNeedsBuild() called during build" error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Ensure the widget is still in the tree
          if (isAuthenticated) {
            // User just logged in
            appLogger.i('🔄 Auth state changed to LOGGED IN. Syncing data.');
            bookmarkProvider.syncBookmarksFromServer();
          } else {
            // User just logged out
            appLogger.i('🔄 Auth state changed to LOGGED OUT. Clearing data.');
            bookmarkProvider.clearAllBookmarks();
          }
        }
      });
    }
    
    // Update the state for the next check
    _wasAuthenticated = isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}