import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart'; // Import the main AuthProvider
import '../auth/feedup_auth_provider.dart';
import '../../askAI/screens/ask_ai_screen.dart';
import '../models/article.dart';
import '../screens/webview_screen.dart';
import '../providers/bookmark_provider.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final bool isBookmarked = bookmarkProvider.isBookmarked(article.id);

    // Get both auth providers
    final authProvider = context.watch<AuthProvider>();
    final feedUpAuthProvider = context.watch<FeedUpAuthProvider>();

    // Use the same consolidated check as in AppShell
    final bool isAuthenticated = authProvider.isAuthenticated || feedUpAuthProvider.isFeedUpUserAuthenticated;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  onPressed: () {
                    if (isAuthenticated) {
                      // If logged in, toggle the bookmark
                      bookmarkProvider.toggleBookmark(article);
                    } else {
                      // If logged out, show a login prompt
                      _showLoginPrompt(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("• ${article.summary}"),
            if (article.generatedPrompt != null) ...[
              const SizedBox(height: 12),
              Text(
                "💡 ${article.generatedPrompt!}",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: article.sourceUrl,
                      title: article.title,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(article.sourceName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.smart_toy_outlined, color: Colors.deepPurpleAccent),
                  tooltip: 'Ask AI about this article',
                  onPressed: () {
                    // Use the consolidated 'isAuthenticated' flag
                    if (isAuthenticated) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AskAiScreen(article: article),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to use the AI Assistant.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper method to show a login dialog
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please log in to save articles to your bookmarks.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                // Dismiss the dialog and navigate to the login options screen
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/role-selection');
              },
            ),
          ],
        );
      },
    );
  }
}
